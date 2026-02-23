import SwiftUI
import SwiftData

struct SessionsView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Environment(AIContextManager.self) var aiManager
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss // Correctly access the dismiss environment
    @EnvironmentObject var auth: AuthManager
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @State var program: WorkoutProgram
    @State private var showDeleteAlert: Bool = false
    @State private var sessionToDeleteIndex: Int? = nil
    @State private var showRenameSheet: Bool = false
    @State private var newProgramTitle: String = ""
    @State private var dragOffset: CGFloat = 0
    private var keyScope: DefaultsKeyScope { DefaultsKeyScope.from(previewUserID: auth.previewUserID, liveUserID: auth.user?.uid) }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                List {
                    ForEach(program.sessions.sorted(by: { $0.name < $1.name })) { session in
                        // Custom Row Styling to match ProgramRowView
                        HStack {
                            NavigationLink(destination: SessionDetailView(session: session, workoutProgram: program, exercises: session.exercises)) {
                                Text(session.name)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .tint(.white)
                        }
                        .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1)) // Subtle glass effect
                                    .padding(.vertical, 4)
                            )
                        .listRowSeparator(.hidden) // Removes the thin lines between rows
                        .padding()
                    }
                    .onDelete(perform: confirmDeleteSession)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden) // Crucial: hides the default grey List background
                .padding(.top, 130)
                .padding(.horizontal, 12)
            }
            .offset(x: dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
            .onAppear {
                if let userId = auth.user?.uid {
                    // Ensure local UserDefaults are up to date with the cloud for all exercises in this program
                    SyncManager.shared.fetchAllFromCloud(userId: userId, keyScope: keyScope)
                }
                
                aiManager.updateContext(
                    screen: "Sessions List",
                    details: "User is viewing the sessions for program: \(program.title)",
                    preferences: generateProgramOverview()
                )
            }
            FloatingActionBar {
                Spacer()
                // Rename Button
                Button(action: {
                    newProgramTitle = program.title
                    showRenameSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                }
                Spacer()
                // Add Session
                NavigationLink(destination: AddSessionView(program: program).environmentObject(theme)) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                }
                Spacer()
                // Star/Favorite
                Button(action: {
                    program.starred.toggle()
                    try? context.save()
                }) {
                    Image(systemName: program.starred ? "star.fill" : "star")
                        .foregroundColor(program.starred ? .yellow : .white)
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 50)
            .background(theme.currentTheme.accent) // Themed bar color
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    // Only respond to drags that start near the leading edge and move right
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
            }
            .applyAppBranding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .bottomBar)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Session"),
                    message: Text("Are you sure you want to delete this session?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let index = sessionToDeleteIndex {
                            deleteSession(at: IndexSet(integer: index))
                        }
                    },
                    secondaryButton: .cancel() {
                        // Reset the index when the alert is dismissed
                        sessionToDeleteIndex = nil
                    }
                )
            }
            .sheet(isPresented: $showRenameSheet) {
                VStack(spacing: 20) {
                    Text("Rename Program")
                        .font(.title3.bold()) // Slightly more prominent
                        .padding(.top)

                    TextField("New Program Title", text: $newProgramTitle, axis: .vertical)
                        .lineLimit(1...5)
                        .padding()
                        .background(theme.currentTheme.accent.opacity(0.8))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(.white)

                    HStack(spacing: 15) {
                        // Cancel Button: Secondary style
                        Button(role: .cancel) {
                            showRenameSheet = false
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity) // Makes both buttons equal width
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }

                        // Rename Button: Primary style (Clickable/Action oriented)
                        Button {
                            renameProgram()
                            showRenameSheet = false
                        } label: {
                            Text("Rename")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(theme.currentTheme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .shadow(color: theme.currentTheme.accent.opacity(0.3), radius: 5, y: 3)
                    }
                }
                .padding(25)
                .presentationDetents([.height(500)]) // Keeps the sheet compact
                .presentationDragIndicator(.visible)
            }
            .brandedBackButton(title: "\(program.title) Sessions",theme: theme.currentTheme, dismiss: dismiss)
        }
    
    private func generateProgramOverview() -> String {
        var summary = "Program: \(program.title)\n"
        summary += "Total Sessions: \(program.sessions.count)\n"
        
        for session in program.sessions {
            let exerciseNames = session.exercises.map { $0.name }.joined(separator: ", ")
            summary += "- \(session.name): [\(exerciseNames)]\n"
        }
        
        return summary
    }
    
    private func renameProgram() {
        // Update the program title
        program.title = newProgramTitle
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Failed to save context after renaming program: \(error)")
        }
    }
    
    private func confirmDeleteSession( at offsets: IndexSet) {
        if let index = offsets.first {
            sessionToDeleteIndex = index
            showDeleteAlert = true
        }
    }
    
    private func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            let sessionToDelete = program.sessions[index]
            context.delete(sessionToDelete)
            do {
                try context.save()
            } catch {
                print("Error deleting session: \(error)")
            }
        }
    }
}

#Preview {
    let program = WorkoutProgram(title: "Test", sessions: [Session(name: "Test", exercises: [Exercise(name: "Test")])])
    SessionsView(program: program)
}

