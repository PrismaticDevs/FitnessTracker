import SwiftUI
import Combine

// Gradient Background Modifier
struct GradientBackground: ViewModifier {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)

    func body(content: Content) -> some View {
        ZStack {
            gradient
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills the entire view
                .edgesIgnoringSafeArea(.all) // Make the gradient fill the entire screen
            content
                .foregroundColor(.white) // Set the default text color to white
        }
    }
}

extension View {
    func applyGradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
}

// Global data for workout programs
class WorkoutProgramsData: ObservableObject {
    @Published var workoutPrograms: [WorkoutProgram] = [
        WorkoutProgram(title: "Big and Strong Advanced", sessions: [
            Session(name: "Push Power Day", exercises: [
                Exercise(name: "Military Press"),
                Exercise(name: "Incline Bench Press"), // Fixed typo
                Exercise(name: "Dumbbell Bench Press"), // Fixed typo
                Exercise(name: "Tricep Dip"),
                Exercise(name: "Overhead Z Bar Tricep Extension")
            ]),
            Session(name: "Legs Power Day", exercises: [ // Fixed capitalization
                Exercise(name: "Front Squat"),
                Exercise(name: "Pause Hack Squat"),
                Exercise(name: "Back Squat or Leg Press"),
                Exercise(name: "Walking Lunges"),
                Exercise(name: "Leg Curl")
            ])
        ]), WorkoutProgram(title: "Other", sessions: [Session(name: "Test", exercises: [Exercise(name: "Test")])])
    ]

    func addWorkoutProgram(title: String) {
        let newProgram = WorkoutProgram(title: title, sessions: [])
        workoutPrograms.append(newProgram)
    }

    func addSession(to program: WorkoutProgram, sessionName: String) {
        let newSession = Session(name: sessionName, exercises: [])
        if let index = workoutPrograms.firstIndex(where: { $0.id == program.id }) {
            workoutPrograms[index].sessions.append(newSession)
        }
    }

    func addExercise(to session: Session, exerciseName: String) {
        let newExercise = Exercise(name: exerciseName)
        if let programIndex = workoutPrograms.firstIndex(where: { $0.sessions.contains(where: { $0.id == session.id }) }) {
            if let sessionIndex = workoutPrograms[programIndex].sessions.firstIndex(where: { $0.id == session.id }) {
                workoutPrograms[programIndex].sessions[sessionIndex].exercises.append(newExercise)
            }
        }
    }
}

// Create workout program// Create workout program
struct AddWorkoutProgramView: View {
    @EnvironmentObject var workoutHistory: WorkoutHistory
    @EnvironmentObject var workoutProgramsData: WorkoutProgramsData
    @State private var programTitle: String = ""
    @State private var sessionName: String = ""
    @State private var exerciseName: String = ""
    @State private var isAddingSession: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // Apply gradient background
                Color.clear
                    .applyGradientBackground() // Use the gradient background modifier
                    .edgesIgnoringSafeArea(.all) // Make the gradient fill the entire screen

                Form {
                    Section(header: Text("Workout Program")) {
                        TextField("Program Title", text: $programTitle)
                        Button("Add Program") {
                            if !programTitle.isEmpty {
                                workoutProgramsData.addWorkoutProgram(title: programTitle)
                                programTitle = ""
                                printWorkoutPrograms() // Print all workout programs after adding
                            }
                        }
                    }

                    if isAddingSession {
                        Section(header: Text("Session")) {
                            TextField("Session Name", text: $sessionName)
                            Button("Add Session") {
                                if let lastProgram = workoutProgramsData.workoutPrograms.last {
                                    if !sessionName.isEmpty {
                                        workoutProgramsData.addSession(to: lastProgram, sessionName: sessionName)
                                        sessionName = ""
                                        printWorkoutPrograms() // Print all workout programs after adding a session
                                    }
                                }
                            }
                        }

                        Section(header: Text("Exercise")) {
                            TextField("Exercise Name", text: $exerciseName)
                            Button("Add Exercise") {
                                if let lastProgram = workoutProgramsData.workoutPrograms.last,
                                   let lastSession = lastProgram.sessions.last {
                                    if !exerciseName.isEmpty {
                                        workoutProgramsData.addExercise(to: lastSession, exerciseName: exerciseName)
                                        exerciseName = ""
                                        printWorkoutPrograms() // Print all workout programs after adding an exercise
                                    }
                                }
                            }
                        }
                    }

                    Button(isAddingSession ? "Done Adding" : "Add Session") {
                        isAddingSession.toggle()
                    }
                }
                .background(Color.clear) // Set the background of the Form to clear
            }
            .navigationTitle("Add Workout Program")
            .navigationBarTitleDisplayMode(.inline) // Optional: Adjust title display mode
        }
    }
    // Function to print all workout programs
    private func printWorkoutPrograms() {
        for program in workoutProgramsData.workoutPrograms {
            print("Workout Program: \(program.title)")
            for session in program.sessions {
                print("  Session: \(session.name)")
                for exercise in session.exercises {
                    print("    Exercise: \(exercise.name)")
                }
            }
        }
    }
}


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
                        NavigationLink("\(program.title)", destination: WorkoutProgramDetailView(program: program))
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
        .accentColor(.white)
        .applyGradientBackground() // Apply the gradient background
    }
}

// Custom Back Button
struct CustomBackButton: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left") // Use a chevron icon
                .foregroundColor(.white) // Set chevron color to white
            Text("Back")
                .foregroundColor(.white) // Set text color to white
        }
    }
}

// Workout Program Detail View
struct WorkoutProgramDetailView: View {
    @ObservedObject var program: WorkoutProgram

    var body: some View {
        VStack {
            Text(program.title)
                .font(.title)

            NavigationLink(destination: WeeklyRoutinesView()) {
                Text("View Weekly Routines")
                    .font(.headline)
                    .padding()
            }

            List {
                ForEach(program.sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        Text(session.name)
                    }
                    .background(Color.clear)
                    .padding()
                    .listStyle(PlainListStyle())
                }
                .listRowBackground(Color.blue)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .bold()
            .font(.system(size: 24))
            .padding()
            .foregroundColor(.white)
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Sessions")
        .applyGradientBackground() // Apply the gradient background
    }
}

// Session detail view
struct SessionDetailView: View {
    var defaults = UserDefaults.standard
    @EnvironmentObject var workoutHistory: WorkoutHistory // Ensure this is provided in the environment
    var session: Session

    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
                .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    ScrollView { // Wrap the content in a ScrollView
                    Text(session.name)
                        .font(.largeTitle)
                        .padding()
                    
                    ForEach(session.exercises) { exercise in
                        // Ensure WeightInput is defined and accepts the correct parameters
                        WeightInput(
                            Exercise: exercise.name,
                            WeightLeft: defaults.integer(forKey: exercise.name + "WeightLeft"),
                            WeightRight: defaults.integer(forKey: exercise.name + "WeightRight"),
                            Weight: defaults.integer(forKey: exercise.name + "Weight"),
                            Note: defaults.string(forKey: exercise.name + "Note") ?? "",
                            Iso: false
                        )
                        .padding(.bottom) // Add some spacing between exercises
                    }
                }
                .navigationTitle("Exercises")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar) // Hide the navigation bar background
                .padding()
                .applyGradientBackground() // Apply the gradient background
            }
        }
    }
}

// Weekly Routines View
struct WeeklyRoutinesView: View {
    var body: some View {
        Text("Weekly Routines")
            .font(.largeTitle)
            .navigationTitle("Weekly Routines")
            .applyGradientBackground() // Apply the gradient background
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Create an instance of WorkoutProgramsData for the preview
        let workoutProgramsData = WorkoutProgramsData()
        
        // Optionally, you can add some sample data to the workoutProgramsData for better preview
        workoutProgramsData.workoutPrograms.append(WorkoutProgram(title: "Sample Program", sessions: []))
        
        return ContentView()
            .environmentObject(WorkoutHistory()) // Provide a WorkoutHistory instance for the preview
            .environmentObject(workoutProgramsData) // Provide the WorkoutProgramsData instance for the preview
    }
}
