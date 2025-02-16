import SwiftUI
import Combine

// Main ContentView
struct ContentView: View {
    @EnvironmentObject var workoutHistory: WorkoutHistory
    @ObservedObject var workoutProgramsData = WorkoutProgramsData()

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)
                List {
                    ForEach(workoutProgramsData.workoutPrograms) { program in
                        NavigationLink("\(program.title)", destination: SessionsView(program: program))
                            .bold()
                            .font(.system(size: 24))
                            .padding()
                            .foregroundColor(.white) // Set text color to white
                    }
                    .listRowBackground(Color.blue)
                }
                .background(Color.clear)
                .padding()
                .navigationTitle("Programs")
                .listStyle(PlainListStyle())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddWorkoutProgramView()) {
                            Text("Add Program") // Text label
                            Image(systemName: "plus") // Plus icon
                        }
                    }
                }
            }
        }
        .modifier(NavigationBarModifier())
        .accentColor(.white)
        .applyGradientBackground() // Apply the gradient background
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of WorkoutProgramsData for the preview
        let workoutProgramsData = WorkoutProgramsData()
        
        return ContentView()
            .environmentObject(WorkoutHistory()) // Provide a WorkoutHistory instance for the preview
            .environmentObject(workoutProgramsData) // Provide the WorkoutProgramsData instance for the preview
    }
}
