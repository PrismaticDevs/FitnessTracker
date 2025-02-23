import SwiftUI

struct AddWorkoutProgramView: View {
    @EnvironmentObject var workoutProgramsData: WorkoutProgramsData
    @State private var programTitle: String = ""
    @State private var newSessions: [Session] = [] // Array to hold new sessions
    @State private var navigateToContentView: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    ScrollView {
                        Section(header: Text("Workout Program").font(.headline)) {
                            TextField("Program Title", text: $programTitle)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .overlay(
                                    Button(action: {
                                        programTitle = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(programTitle.isEmpty ? 0 : 1).padding()
                                    }
                                        .foregroundColor(Color.white)
                                        .padding(),
                                    alignment: .trailing
                                )
                        }
                        .padding(.horizontal)
                        
                        // Display new sessions
                        ForEach(newSessions.indices, id: \.self) { index in
                            VStack(spacing: 16) {
                                Text("Session")
                                    .font(.headline)
                                    .padding(.top)
                                
                                // Create a binding for the session name
                                TextField("Session Name", text: Binding(
                                    get: { newSessions[index].name },
                                    set: { newSessions[index].name = $0 }
                                ))
                                .onChange(of: newSessions[index].name) { newValue, oldValue in
                                        // Update the session name directly in the array
                                        newSessions[index].name = newValue
                                    }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .overlay(
                                    Button(action: {
                                        newSessions[index].name = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(newSessions[index].name.isEmpty ? 0 : 1).padding()
                                    }
                                        .foregroundColor(Color.white)
                                        .padding(),
                                    alignment: .trailing
                                )
                                
                                Text("Exercises")
                                    .font(.headline)
                                    .padding(.top)
                                
                                // Display selected exercises for the session
                                VStack(spacing: 8) {
                                    ForEach(newSessions[index].exercises) { exercise in
                                        ZStack(alignment: .trailing) {
                                            Text(exercise.name)
                                                .padding(.trailing, 40)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(8)
                                            
                                            // Minus button to remove exercise
                                            Button(action: {
                                                if let exerciseIndex = newSessions[index].exercises.firstIndex(where: { $0.id == exercise.id }) {
                                                    newSessions[index].exercises.remove(at: exerciseIndex)
                                                }
                                            }) {
                                                Image(systemName: "minus.circle")
                                                    .foregroundColor(.red)
                                                    .padding(.trailing, 8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                                // ExerciseToolbar for selecting exercises
                                ExerciseToolbar(exerciseName: .constant(""), onExerciseSelected: { exerciseName in
                                    let exercise = Exercise(name: exerciseName)
                                    if !newSessions[index].exercises.contains(where: { $0.name == exercise.name }) {
                                        newSessions[index].exercises.append(exercise)
                                    }
                                })
                            }
                            .padding(.horizontal)
                        }
                        
                        // Button to add a new session
                        Button(action: {
                            addSession()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.white)
                                Text("Add Session")
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Add Workout Program")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
//                            createWorkoutProgram() // Call createWorkoutProgram when the button is pressed
                            saveWorkoutProgram()
                        }) {
                            Text("Create")
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToContentView) {
                ContentView()
            }
        }
    }

    private func addSession() {
        // Create a new session with an empty name and no exercises
        let newSession = Session(name: "", exercises: [])
        newSessions.append(newSession)
    }
    
    private func createWorkoutProgram() {
        // Create a new WorkoutProgram instance
        let newProgram = WorkoutProgram(title: programTitle, sessions: newSessions)

       if !programTitle.isEmpty {
           // Add the new program to the workoutProgramsData
           workoutProgramsData.workoutPrograms.append(newProgram)
           workoutProgramsData.saveWorkoutProgram(program: newProgram)
       } else {
           showAlert = true
       }
        
        print(workoutProgramsData.workoutPrograms.count)

        // Optionally reset the fields
        programTitle = ""
        newSessions = []

        navigateToContentView = true
    }
    
    private func saveWorkoutProgram() {
        // Create a new WorkoutProgram instance
        let newProgram = WorkoutProgram(title: programTitle, sessions: newSessions)

        if !programTitle.isEmpty {
            // Add the new program to the workoutProgramsData
            workoutProgramsData.workoutPrograms.append(newProgram)
            
            // Encode the workoutPrograms array to JSON
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(workoutProgramsData.workoutPrograms) {
                // Save the JSON data to UserDefaults
                UserDefaults.standard.set(encoded, forKey: "workoutPrograms")
            }
        } else {
            showAlert = true
        }
        
        print(workoutProgramsData.workoutPrograms.count)

        // Optionally reset the fields
        programTitle = ""
        newSessions = []

        navigateToContentView = true
    }

    
}

#Preview {
    AddWorkoutProgramView()
        .environmentObject(WorkoutProgramsData())
}
