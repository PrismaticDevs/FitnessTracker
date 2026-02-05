//
//  ChatViewModel.swift
//  FitnessTracker
//
//  Created by Matt on 1/23/26.
//

import FirebaseAILogic
import SwiftUI
import FirebaseFirestore

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

final class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0

    private var willShow: NSObjectProtocol?
    private var willHide: NSObjectProtocol?

    init() {
        willShow = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            self?.height = frame.height
        }
        willHide = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.height = 0
        }
    }

    deinit {
        if let willShow { NotificationCenter.default.removeObserver(willShow) }
        if let willHide { NotificationCenter.default.removeObserver(willHide) }
    }
}

@Observable
class AIContextManager {
    // This is what the AI will read before answering
    var currentContext: String = "User is browsing the main menu."

    // Call this whenever you navigate to a new screen
    func updateContext(screen: String, details: String) {
        self.currentContext = "Location: \(screen). Context: \(details)"
        print("DEBUG: AI Context is now: \(currentContext)")
    }
}

struct AICoachService {
    private let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    
    private var model: GenerativeModel {
        ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func getWorkoutAdvice(context: String, userQuery: String) async throws -> String {
        // Create a detailed prompt combining your Session data and the user's question
        let prompt = """
            You are an expert fitness coach. Use the following workout data to answer:
            \(context)
            
            User Question: \(userQuery)
            """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "I'm not sure how to answer that based on your current sets."
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [(text: String, isUser: Bool)] = []
    @Published var isLoading = false
    private let coachService = AICoachService()
    private let db = Firestore.firestore()
    
    func loadHistory(for userId: String) async {
        isLoading = true
        
        // 1. Clear current messages so the user sees something is happening
        self.messages.removeAll()
        
        do {
            let snapshot = try await db.collection("users").document(userId)
                .collection("chat_history")
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            let fetchedMessages = snapshot.documents.compactMap { doc -> (text: String, isUser: Bool)? in
                let data = doc.data()
                
                // DEBUG: This will print every message to your Xcode console
                print("DEBUG: Firestore Data -> \(data)")
                
                // We use '??' to provide defaults so the message doesn't get skipped (nil)
                let text = data["text"] as? String ?? "[Empty Message]"
                let isUser = data["isUser"] as? Bool ?? false // Defaults to Coach if missing
                
                return (text: text, isUser: isUser)
            }
            
            // 2. Use withAnimation so the history "slides" in
            withAnimation(.easeInOut) {
                self.messages = fetchedMessages
            }
            
            print("DEBUG: Successfully loaded \(messages.count) messages.")
            
        } catch {
            // Look for a URL in this print statement in your console!
            print("❌ Firestore Error: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func saveToFirestore(text: String, isUser: Bool, userId: String) {
        db.collection("users").document(userId).collection("chat_history").addDocument(data: [
            "text": text,
            "isUser": isUser,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }
    
    func sendMessage(_ text: String, workoutContext: String, userId: String) async {
        let userMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }

        // --- 1. SAVE USER MESSAGE (This part is working) ---
        self.messages.append((text: userMessage, isUser: true))
        self.saveToFirestore(text: userMessage, isUser: true, userId: userId)
        
        self.isLoading = true
        
        do {
            // --- 2. GET THE AI RESPONSE ---
            let response = try await coachService.getWorkoutAdvice(context: workoutContext, userQuery: userMessage)
            
            // --- 3. SAVE THE AI RESPONSE (This is likely the missing part!) ---
            self.messages.append((text: response, isUser: false))
            self.saveToFirestore(text: response, isUser: false, userId: userId) // SAVE TO CLOUD
            
        } catch {
            print("❌ AI Error: \(error)")
            let errorMsg = "Service error."
            self.messages.append((text: errorMsg, isUser: false))
            // IF THIS LINE BELOW IS MISSING, NOTHING SAVES ON FAILURE
            self.saveToFirestore(text: errorMsg, isUser: false, userId: userId)
        }
        
        self.isLoading = false
    }
}

struct FloatingChatView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(AIContextManager.self) var aiManager
    @StateObject private var vm = ChatViewModel()
    @StateObject private var keyboard = KeyboardObserver()
    @State private var isExpanded = false
    @State private var isFullScreen = false
    @State private var inputText = ""
    let workoutContext: String
    
    // Position tracking
    @State private var position: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    
    // --- DYNAMIC POSITIONING LOGIC ---
    
    private var currentTotalOffset: CGSize {
        CGSize(
            width: position.width + dragOffset.width,
            height: position.height + dragOffset.height
        )
    }

    private var isAtTop: Bool {
        let screenHeight = UIScreen.main.bounds.height
        // Since we start bottom-right, a Y offset < -screenHeight/2 means we're in the top half
        return currentTotalOffset.height < -(screenHeight / 2)
    }

    private var isAtLeft: Bool {
        let screenWidth = UIScreen.main.bounds.width
        return currentTotalOffset.width < -(screenWidth / 2)
    }

    private var expansionAlignment: Alignment {
        if isAtTop {
            return isAtLeft ? .topLeading : .topTrailing
        } else {
            return isAtLeft ? .bottomLeading : .bottomTrailing
        }
    }

    // --- BODY ---

    var body: some View {
        chatButton
                .overlay(alignment: expansionAlignment) {
                    if isExpanded {
                        chatWindowView
                            .offset(y: isAtTop ? 75 : -75)
                            .transition(.asymmetric(
                                // FIX: Use expansionAnchor here
                                insertion: .scale(scale: 0.1, anchor: expansionAnchor).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .offset(currentTotalOffset)
                .fullScreenCover(isPresented: $isFullScreen) {
                    chatWindowView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
    }
    // --- SUBVIEWS ---
    
    private var expansionAnchor: UnitPoint {
        if isAtTop {
            return isAtLeft ? .topLeading : .topTrailing
        } else {
            return isAtLeft ? .bottomLeading : .bottomTrailing
        }
    }

    private var chatButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                Image(systemName: isExpanded ? "chevron.down" : "sparkles")
                    .font(.title2).foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    position.width += value.translation.width
                    position.height += value.translation.height
                    snapToHorizontalEdges()
                }
        )
    }

    private var chatWindowView: some View {
        VStack(spacing: 0) {
            // The ScrollView will now naturally respect the Safe Area
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<vm.messages.count, id: \.self) { i in
                            ChatBubble(text: vm.messages[i].text, isUser: vm.messages[i].isUser)
                                .id(i)
                        }
                        if vm.isLoading {
                            loadingIndicator.id("loadingIndicator")
                        }
                    }
                    .padding(.vertical)
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    headerView // The button is now inside here
                }
            }
            
            Divider()
            inputBar
        }
        .background(Color(.systemBackground))
        .if(!isFullScreen) { view in
            view
                .frame(width: 280, height: 400)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 15)
        }
        // REMOVED: .ignoresSafeArea from here to prevent the freeze and the "floating" button
    }
    
    // MARK: - Sub-properties

    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .tint(.purple)
                .scaleEffect(0.8)
            Text("Coach is thinking...")
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .id("loadingIndicator")
    }

    private var inputBar: some View {
        HStack {
            TextField("Ask...", text: $inputText)
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        // Moves the bar up when the keyboard appears
        .padding(.bottom, isFullScreen ? keyboard.height : 0)
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            // This spacer only exists in full screen to push content below the notch
            if isFullScreen {
                Color.clear.frame(height: 50) // Adjust height for notch/island
            }
            
            HStack {
                Text("AI Coach").bold()
                Spacer()
                
                // History Button ---
                Button(action: {
                    if let uid = auth.user?.uid {
                        Task { await vm.loadHistory(for: uid) }
                    }
                }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                // The Compress/Expand Button
                Button(action: { withAnimation { isFullScreen.toggle() } }) {
                    Image(systemName: isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(isFullScreen ? Color(.tertiarySystemBackground) : Color.clear)
                        .clipShape(Circle())
                }
                
                // The Close Button
                Button(action: { withAnimation { isExpanded = false; isFullScreen = false }}) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            .padding(.top, isFullScreen ? 0 : 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .onAppear {
            if let uid = auth.user?.uid {
                Task { await vm.loadHistory(for: uid) }
            }
        }
    }

    private func sendMessage() {
        guard let userId = auth.user?.uid else { return }
            let text = inputText
            guard !text.isEmpty else { return }
            
            // 2. Fetch the LIVE context string from the manager
            let liveContext = aiManager.currentContext
            print("DEBUG: Sending to AI with LIVE context: \(liveContext)")
            
            inputText = ""
            
            Task {
                // 3. Pass the fresh string to the VM
                await vm.sendMessage(text, workoutContext: liveContext, userId: userId)
            }
        }

    private func snapToHorizontalEdges() {
        let screenWidth = UIScreen.main.bounds.width
        withAnimation(.spring()) {
            if position.width < -(screenWidth / 2) {
                position.width = -(screenWidth - 80)
            } else {
                position.width = 0
            }
        }
    }
}

struct ChatBubble: View {
    let text: String
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            Text(text)
                .padding(10)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

