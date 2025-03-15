import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss // Correctly access the dismiss environment
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @State var program: WorkoutProgram
    @State private var showDeleteAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(program.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                Text(session.name)
                            }
                        }
                        .listRowBackground(Color.blue)
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
                        // Toggle the starred state
                        program.starred.toggle()
                        // Save the context if needed
                        try? context.save()
                    }) {
                        Image(systemName: program.starred ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Program"),
                            message: Text("Are you sure you want to delete this program? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteProgram() // Call the delete function
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
    }
    
    private func deleteProgram() {
        // Delete the program from the context
        context.delete(program)
        do {
                try context.save()
                dismiss()
            } catch {
                print("Failed to delete program: \(error)")
            }
    }
}

#Preview {
    let program = WorkoutProgram(title: "Test", sessions: [])
    SessionsView(program: program)
}
