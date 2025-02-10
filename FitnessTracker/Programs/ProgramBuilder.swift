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
                   Exercise(name: "Military Press", sets: "5", reps: "3-5", rest: "3 min"),
                   Exercise(name: "Incline Bench Press", sets: "4", reps: "3-5", rest: "3 min"),
                   Exercise(name: "Dumbbell Bench Press", sets: "3", reps: "5", rest: "2 min"),
                   Exercise(name: "Tricep Dip", sets: "3", reps: "5", rest: "2 min"),
                   Exercise(name: "Overhead EZ Bar Tricep Extension", sets: "3", reps: "5", rest: "2 min")
               ]),
               Session(name: "Legs Power Day", exercises: [
                   Exercise(name: "Front Squat", sets: "5", reps: "3-5", rest: "3 min"),
                   Exercise(name: "Pause Back Squat", sets: "4", reps: "3-5", rest: "3 min"),
                   Exercise(name: "Hack Squat or Leg Press", sets: "3", reps: "5", rest: "2 min"),
                   Exercise(name: "Seated Leg Curl", sets: "3", reps: "5", rest: "2 min"),
                   Exercise(name: "Leg Extension", sets: "3", reps: "5", rest: "2 min")
               ]),
               Session(name: "Pull Power Day", exercises: [
                   Exercise(name: "Trap Bar or Barbell Rack Pull", sets: "5", reps: "3-5", rest: "3 min"),
                   Exercise(name: "Pull Ups", sets: "4", reps: "3-5", rest: "3 min"),
                   Exercise(name: "One Arm Dumbbell Row", sets: "3", reps: "5, each side", rest: "2 min"),
                   Exercise(name: "Concentration Curl", sets: "3", reps: "5", rest: "2 min"),
                   Exercise(name: "Shrug (with hold)", sets: "3", reps: "5", rest: "2 min")
               ]),
               Session(name: "Lower Dynamic Day", exercises: [
                   Exercise(name: "Speed Front Squat", sets: "6", reps: "3", rest: "30 sec"),
                   Exercise(name: "Speed Pause Squat", sets: "6", reps: "3", rest: "30 sec"),
                   Exercise(name: "Leg Press", sets: "4", reps: "4", rest: "30 sec"),
                   Exercise(name: "Seated Calf Raise", sets: "2", reps: "6", rest: "30 sec"),
                   Exercise(name: "Lying Leg Raise", sets: "2", reps: "6", rest: "30 sec")
               ]),
               Session(name: "Upper Dynamic Day", exercises: [
                  Exercise(name: "Speed Barbell Press", sets: "6", reps: "3", rest: "30 sec"),
                  Exercise(name: "Speed Trap Bar or Barbell Rack Pull", sets: "6", reps: "3", rest: "30 sec"),
                  Exercise(name: "Lateral Raise", sets: "4", reps: "4", rest: "30 sec"),
                  Exercise(name: "Barbell Curl", sets: "2", reps: "6", rest: "30 sec"),
                  Exercise(name: "Tricep Extension", sets: "2", reps: "6", rest: "30 sec")
              ])
           ]),
           WorkoutProgram(title: "8 Week Mass Building Hypertrophy Workout", sessions: [ Session(name: "Chest and Side Delts", exercises: [
                           Exercise(name: "Incline Barbell Bench Press", sets: "3", reps: "12, 10, 12*", rest: "90 sec"),
                           Exercise(name: "Flat Dumbbell Bench Press", sets: "3", reps: "12, 10, 15+", rest: "90 sec"),
                           Exercise(name: "Cable Crossover", sets: "3", reps: "12, 12, 12^", rest: "90 sec"),
                           Exercise(name: "Seated Lateral Raise", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Single Arm Cable Lateral Raise", sets: "3", reps: "12, 12, 12", rest: "90 sec")
                       ]),
                       Session(name: "Upper Back and Rear Delts", exercises: [
                           Exercise(name: "Bent-Over Barbell Row", sets: "3", reps: "12, 10, 12*", rest: "90 sec"),
                           Exercise(name: "Dumbbell Pullover", sets: "3", reps: "12, 10, 15+", rest: "90 sec"),
                           Exercise(name: "Wide Grip Lat Pulldown", sets: "3", reps: "12, 12, 12^", rest: "90 sec"),
                           Exercise(name: "Dumbbell Rear Delt Fly", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Cable Face Pull", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Dumbbell Shrug", sets: "3", reps: "12, 12, 12", rest: "90 sec")
                       ]),
                       Session(name: "Arms and Abs", exercises: [
                           Exercise(name: "Close Grip Bench Press", sets: "3", reps: "12, 10, 12*", rest: "90 sec"),
                           Exercise(name: "Weighted Dip", sets: "3", reps: "12, 10, 12+", rest: "90 sec"),
                           Exercise(name: "Rope Tricep Extension", sets: "3", reps: "12, 12, 12^", rest: "90 sec"),
                           Exercise(name: "Lying Leg Raise", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Cable Crunch", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Barbell Curl", sets: "3", reps: "12, 12, 12*", rest: "90 sec"),
                           Exercise(name: "Hammer Curl", sets: "3", reps: "12, 10, 12+", rest: "90 sec"),
                           Exercise(name: "Cable Curl", sets: "3", reps: "12, 12, 12^", rest: "90 sec")
                       ]),
                       Session(name: "Legs", exercises: [
                           Exercise(name: "Deadlift", sets: "3", reps: "12, 10, 12*", rest: "90 sec"),
                           Exercise(name: "Lying Leg Curl", sets: "3", reps: "12, 10, 12+", rest: "90 sec"),
                           Exercise(name: "Walking Lunge", sets: "3", reps: "12, 12, 12", rest: "90 sec"),
                           Exercise(name: "Front Squat", sets: "3", reps: "12, 10, 12*", rest: "90 sec"),
                           Exercise(name: "Leg Extension", sets: "3", reps: "12, 12, 12+", rest: "90 sec"),
                           Exercise(name: "Dumbbell Side Lunge", sets: "3", reps: "12, 12, 12", rest: "90 sec")
                       ])
           ]),
           WorkoutProgram(title: "4 Day Maximum Mass Workout", sessions: [
               Session(name: "Back and Biceps", exercises: [
                   Exercise(name: "Deadlift", sets: "2", reps: "5", rest: "2 min"),
                   Exercise(name: "One Arm Dumbbell Row", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Wide Grip Pull Up or Lat Pull Down", sets: "3", reps: "10-12", rest: "1-2 min"),
                   Exercise(name: "Barbell Row", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Seated Cable Row or Machine Row", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "EZ Bar Preacher Curl", sets: "3", reps: "10-12", rest: "1-2 min"),
                   Exercise(name: "Concentration Curl", sets: "3", reps: "10-12", rest: "1-2 min"),
                   Exercise(name: "Seated Dumbbell Curl", sets: "5 Minutes", reps: "Burn", rest: "1 min")
               ]),
               Session(name: "Chest and Triceps", exercises: [
                   Exercise(name: "Bench Press", sets: "3", reps: "6-10", rest: "2 min"),
                   Exercise(name: "Incline Dumbbell Bench Press", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Chest Dip", sets: "3", reps: "AMRAP", rest: "1-2 min"),
                   Exercise(name: "Cable Crossover or Pec Dec", sets: "3", reps: "12-15", rest: "1-2 min"),
                   Exercise(name: "Machine Press or Dumbbell Bench Press", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "EZ Bar Skullcrusher", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Two Arm Seated Dumbbell Extension", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Cable Tricep Extension", sets: "5 Minutes", reps: "Burn", rest: "1 min")
               ]),
               Session(name: "Quads, Hamstrings, and Calves", exercises: [
                   Exercise(name: "Squat", sets: "3", reps: "6-10", rest: "2 min"),
                   Exercise(name: "Leg Press", sets: "3", reps: "15-20", rest: "1-2 min"),
                   Exercise(name: "Hack Squat or Dumbbell Lunge", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Leg Extension", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "Stiff Leg Deadlift", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Leg Curl", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "Standing Calf Raise", sets: "3", reps: "10-15", rest: "1-2 min"),
                   Exercise(name: "Seated Calf Raise", sets: "5 Minutes", reps: "Burn", rest: "1 min")
               ]),
               Session(name: "Shoulders, Traps, and Forearms", exercises: [
                   Exercise(name: "Seated Barbell Press", sets: "3", reps: "6-10", rest: "2 min"),
                   Exercise(name: "Seated Arnold Press", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Dumbbell Lateral Raise", sets: "3", reps: "10-15", rest: "1-2 min"),
                   Exercise(name: "Hammer Strength Press or Smith Press", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "Upright Row", sets: "3", reps: "8-12", rest: "1-2 min"),
                   Exercise(name: "Barbell Shrug or Dumbbell Shrug", sets: "5 Minutes", reps: "Burn", rest: "1 min"),
                   Exercise(name: "Seated Barbell Wrist Curl", sets: "3", reps: "12-15", rest: "1-2 min"),
                   Exercise(name: "Barbell Static Hold", sets: "5 Minutes", reps: "Hold", rest: "1 min")
                   ])
               ])
           
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

    func addExercise(to session: Session, exerciseName: String, sets: String, reps: String, rest: String) {
        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, rest: rest)
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
    @State private var sets: String = ""
    @State private var reps: String = ""
    @State private var rest: String = ""
    @State private var isAddingSession: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)
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
                            TextField("Sets", text: $sets)
                            TextField("Reps", text: $reps)
                            TextField("Rest", text: $rest)
                            Button("Add Exercise") {
                                if let lastProgram = workoutProgramsData.workoutPrograms.last,
                                   let lastSession = lastProgram.sessions.last {
                                    if !exerciseName.isEmpty {
                                        workoutProgramsData.addExercise(to: lastSession, exerciseName: exerciseName, sets: sets, reps: reps, rest: rest)
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
                .navigationTitle("Session Detail")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar) // Hide the navigation bar background
                .padding()
                .applyGradientBackground() // Apply the gradient background
            }
        }
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
