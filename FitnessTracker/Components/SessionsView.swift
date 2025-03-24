import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss // Correctly access the dismiss environment
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @State var program: WorkoutProgram
    @State private var showDeleteAlert: Bool = false
    @State private var sessionToDeleteIndex: Int? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(program.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session, workoutProgram: program)) {
                                Text(session.name)
                            }
                        }
                        .onDelete(perform: confirmDeleteSession)
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
    let program = WorkoutProgram(title: "Test", sessions: [])
    SessionsView(program: program)
}
