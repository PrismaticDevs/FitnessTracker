import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @State var program: WorkoutProgram

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Text(program.title)
                        .listRowBackground(Color.clear)
                    List {
                        ForEach(program.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                Text(session.name)
                            }
                        }
                        .listRowBackground(Color.blue)
                        .padding()
                        .navigationBarTitle("Sessions")
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
        }
    }
}

#Preview {
    let program = WorkoutProgram(title: "Test", sessions: [])
    SessionsView(program: program)
}
