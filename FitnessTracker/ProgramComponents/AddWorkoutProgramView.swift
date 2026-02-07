import SwiftUI
import SwiftData

struct AddWorkoutProgramView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var programTitle: String = ""
    @State private var newSessions: [Session] = []
    @State private var selectedExercises: [Exercise] = []
    @State private var navigateToContentView: Bool = false
    @State private var showAlert: Bool = false
    @StateObject private var exerciseList = ExerciseList() // Create a single instance
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    ScrollView {
                        Text("Add New Workout program")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Section(header: Text("Title").font(.headline).foregroundColor(.white)) {
                            TextField("Program Title", text: $programTitle, prompt: Text("Program Title").foregroundColor(.white.opacity(0.5)))
                                .padding()
                                .background(theme.currentTheme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .overlay(
                                    Button(action: {
                                        programTitle = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(programTitle.isEmpty ? 0 : 1).padding()
                                    }
                                        .foregroundColor(.white)
                                        .padding(),
                                    alignment: .trailing
                                )
                        }
                        .padding(.horizontal)
                            ForEach(newSessions.indices, id: \.self) { index in
                                Section(header: Text("Session").font(.headline).foregroundColor(.white)) {
                                    if newSessions.isEmpty {
                                        ContentUnavailableView(label: {
                                            Label("No sessions yet", systemImage: "list.bullet.rectangle.portrait")
                                                .foregroundColor(.white)
                                        }, description: {
                                            Text("Start adding sessions")
                                                .foregroundColor(.white)
                                        },actions: {
                                        })
                                    }
                                HStack {
                                    TextField("Session Name", text: $newSessions[index].name, prompt: Text("Session Name").foregroundColor(.white.opacity(0.5)))
                                        .onChange(of: newSessions[index].name) { newValue, oldValue in
                                            newSessions[index].name = newValue
                                        }
                                        .padding()
                                        .background(theme.currentTheme.accent)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    Button(action: {
                                        deleteSession(at: index)
                                   }) {
                                       Image(systemName: "minus.circle")
                                           .foregroundColor(.red)
                                           .padding(.leading, 8) // Add some space between the text field and the button
                                   }
                                }
                                if !newSessions[index].exercises.isEmpty {
                                    Section(header: Text("Exercises").font(.headline).foregroundColor(.white)) {
                                        ForEach(newSessions[index].exercises) { exercise in
                                            HStack {
                                                Text(exercise.name)
                                                    .padding()
                                                    .background(theme.currentTheme.accent)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                                
                                                Button(action: {
                                                    removeExercise(from: &newSessions[index], exercise: exercise)
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundColor(.red)
                                                        .padding(.trailing, 8)
                                                }
                                            }
                                        }
                                    }
                                }
                                // ExerciseToolbar for selecting exercises
                                ExerciseToolbar(
                                    exerciseName: .constant(""),
                                    exercisesSelected: newSessions[index].exercises.map { $0.name }, // Pass selected exercises
                                    onExerciseSelected: { exerciseName in
                                        let exercise = Exercise(name: exerciseName)
                                        addExercise(to: &newSessions[index], exercise: exercise)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print(programTitle)
                        saveWorkoutProgram()
                    }) {
                        HStack{
                            Text("Create Program")
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .disabled(!canCreateProgram) // Disable button if conditions are not met
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    private var canCreateProgram: Bool {
        !programTitle.isEmpty && newSessions.contains(where: { !$0.exercises.isEmpty }) && newSessions.contains(where: { !$0.name.isEmpty })
        }
    
    func addSession() {
        let newSession = Session(name: "", exercises: [])
        newSessions.append(newSession)
    }
    
    private func deleteSession(at index: Int) {
        guard index < newSessions.count else { return }
        newSessions.remove(at: index)
    }
    
    private func addExercise(to session: inout Session, exercise: Exercise) {
        session.exercises.append(exercise)
    }
    func removeExercise(from session: inout Session, exercise: Exercise) {
        if let index = session.exercises.firstIndex(where: { $0.id == exercise.id }) {
            session.exercises.remove(at: index)
        }
    }
    
    private func saveWorkoutProgram() {
        print("test")
        // Ensure the program title and sessions are not empty
        guard !programTitle.isEmpty, !newSessions.isEmpty else { return }
        
        let newProgram = WorkoutProgram(title: programTitle, sessions: newSessions)
        context.insert(newProgram)

        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    AddWorkoutProgramView()
}
