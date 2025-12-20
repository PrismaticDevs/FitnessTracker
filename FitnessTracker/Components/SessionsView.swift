import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss // Correctly access the dismiss environment
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @Binding var program: WorkoutProgram
    @State private var showDeleteAlert: Bool = false
    @State private var sessionToDeleteIndex: Int? = nil
    @State private var showRenameSheet: Bool = false
    @State private var newProgramTitle: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(program.sessions.indices, id: \.self) { idx in
                            let sessionBinding = Binding(
                                get: { program.sessions[idx] },
                                set: { program.sessions[idx] = $0 }
                            )
                            NavigationLink(destination: SessionDetailView(session: sessionBinding, workoutProgram: program)) {
                                Text(program.sessions[idx].name)
                            }
                        }
                        .onDelete(perform: confirmDeleteSession)
                        .listRowBackground(ColorPalette.accent)
                        .padding()
                        .navigationBarTitle("\(program.title) Sessions")
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .padding()
                    .font(.system(size: 24))
                }
                .navigationBarTitleTextColor(.white)
                .navigationBarTitleDisplayMode(.inline)
            }
            .applyGradientBackground()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show the rename sheet
                        newProgramTitle = program.title // Set the current title as the default
                        showRenameSheet = true
                    }) {
                        Image(systemName: "pencil")
                    }
                    Button(action: {
                        // Toggle the starred state
                        program.starred.toggle()
                        // Save the context if needed
                        try? context.save()
                    }) {
                        Image(systemName: program.starred ? "star.fill" : "star")
                            .foregroundColor(ColorPalette.accent)
                    }
                }
            }
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
               VStack {
                   Text("Rename Program")
                       .font(.headline)
                       .padding()

                   TextField("New Program Title", text: $newProgramTitle, prompt: Text("New Program Title").foregroundColor(ColorPalette.primary.opacity(0.5)))
                       .padding()
                       .background(ColorPalette.accent.opacity(0.8).cornerRadius(10))

                   Button("Rename") {
                       renameProgram()
                       showRenameSheet = false // Dismiss the sheet
                   }
                   .padding()
               }
               .padding()
               .applyGradientBackground()
           }
        }
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
    @Previewable @State var program = WorkoutProgram(title: "Test", sessions: [Session(name: "Test", exercises: [Exercise(name: "Test")])])
    return SessionsView(program: $program)
}
