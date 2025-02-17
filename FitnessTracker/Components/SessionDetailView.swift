import SwiftUI

struct SessionDetailView: View {
    var defaults = UserDefaults.standard
    @EnvironmentObject var workoutHistory: WorkoutHistory // Ensure this is provided in the environment
    var session: Session
    @State var viewHistory: Bool = false
    
    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                ScrollView { // Wrap the content in a ScrollView
                    Text(session.name)
                        .font(.largeTitle)
                    ForEach(session.exercises) { exercise in
                        // Ensure WeightInput is defined and accepts the correct parameters
                        WeightInput(
                            Exercise: exercise.name,
                            WeightLeft: defaults.string(forKey: exercise.name + "WeightLeft") ?? "",
                            WeightRight: defaults.string(forKey: exercise.name + "WeightRight") ?? "",
                            Weight: defaults.string(forKey: exercise.name + "Weight") ?? "",
                            Note: defaults.string(forKey: exercise.name + "Note") ?? "",
                            Sets: defaults.string(forKey: exercise.name + "Sets") ?? "",
                            Reps: defaults.string(forKey: exercise.name + "Reps") ?? "",
                            Rest: defaults.string(forKey: exercise.name + "Rest") ?? "",
                            Iso: false
                        )
                        .padding(.bottom) // Add some spacing between exercises
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar) // Hide the navigation bar background
                .padding()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Session Detail")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    let workoutHistory = WorkoutHistory()
    
    let session = Session(name: "Test Session", exercises: [
        Exercise(name: "Test Exercise"),
        Exercise(name: "Test Exercise 2"),
        Exercise(name: "Test Exercise 3")
    ])
    
    SessionDetailView(session: session)
        .environmentObject(workoutHistory)
}
