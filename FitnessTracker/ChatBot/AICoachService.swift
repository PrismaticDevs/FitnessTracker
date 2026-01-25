//
//  ChatViewModel.swift
//  FitnessTracker
//
//  Created by Matt on 1/23/26.
//

import FirebaseAILogic
import SwiftUI

struct AICoachService {
    private let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    
    private var model: GenerativeModel {
        ai.generativeModel(modelName: "gemini-3-flash")
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
    
    func sendMessage(_ text: String, workoutContext: String) async {
        let userMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // 1. Add user message to UI
        messages.append((text: userMessage, isUser: true))
        isLoading = true
        
        do {
            // 2. Get AI Response
            let response = try await coachService.getWorkoutAdvice(context: workoutContext, userQuery: userMessage)
            messages.append((text: response, isUser: false))
        } catch {
            messages.append((text: "Sorry, I'm having trouble connecting to my fitness brain.", isUser: false))
        }
        
        isLoading = false
    }
}

struct FloatingChatView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var isExpanded = false
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
            // Header
            HStack {
                Text("AI Coach").bold()
                Spacer()
                Button(action: { withAnimation { isExpanded = false }}) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(0..<vm.messages.count, id: \.self) { i in
                            ChatBubble(text: vm.messages[i].text, isUser: vm.messages[i].isUser)
                                .id(i)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: vm.messages.count) { _ in
                    withAnimation { proxy.scrollTo(vm.messages.count - 1) }
                }
            }
            
            Divider()

            // Input
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
        }
        .frame(width: 280, height: 400)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 15)
    }

    private func sendMessage() {
        let text = inputText
        guard !text.isEmpty else { return }
        inputText = ""
        Task { await vm.sendMessage(text, workoutContext: workoutContext) }
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

