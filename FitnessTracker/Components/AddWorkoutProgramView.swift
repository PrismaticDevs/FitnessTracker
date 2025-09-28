import SwiftUI
import SwiftData

struct SessionEditorView: View {
    @Binding var session: Session
    var onDelete: () -> Void
    var addExercise: (String) -> Void
    var removeExercise: (WorkoutEntry) -> Void

    var body: some View {
        Section(header: Text("Session").font(.headline).foregroundColor(ColorPalette.primary)) {
            HStack {
                TextField("Session Name", text: $session.name)
                    .padding()
                    .background(ColorPalette.accent)
                    .foregroundColor(ColorPalette.primary)
                    .cornerRadius(8)
                Button(action: onDelete) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(.red)
                        .padding(.leading, 8)
                }
            }
            if !session.exercises.isEmpty {
                Section(header: Text("Exercises").font(.headline).foregroundColor(ColorPalette.primary)) {
                    ForEach(session.exercises) { exercise in
                        HStack {
                            Text(exercise.exercise.name)
                                .padding()
                                .background(ColorPalette.accent)
                                .foregroundColor(ColorPalette.primary)
                                .cornerRadius(8)
                            Button(action: { removeExercise(exercise) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                }
            }
            ExerciseToolbar(
                exerciseName: .constant(""),
                exercisesSelected: session.exercises.map { $0.exercise.name },
                onExerciseSelected: addExercise
            )
        }
        .padding(.horizontal)
    }
}

struct AddWorkoutProgramView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var programTitle: String = ""
    @State private var newSessions: [Session] = []
    @State private var selectedExercises: [WorkoutEntry] = []
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
                            .foregroundColor(ColorPalette.primary)
                            .padding()
                        Section(header: Text("Title").font(.headline).foregroundColor(ColorPalette.primary)) {
                            TextField("Program Title", text: $programTitle, prompt: Text("Program Title").foregroundColor(ColorPalette.primary.opacity(0.5)))
                                .padding()
                                .background(ColorPalette.accent)
                                .foregroundColor(ColorPalette.primary)
                                .cornerRadius(8)
                                .overlay(
                                    Button(action: {
                                        programTitle = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(programTitle.isEmpty ? 0 : 1).padding()
                                    }
                                        .foregroundColor(ColorPalette.primary)
                                        .padding(),
                                    alignment: .trailing
                                )
                        }
                        .padding(.horizontal)
                        ForEach(newSessions.indices, id: \.self) { index in
                            SessionEditorView(
                                session: $newSessions[index],
                                onDelete: { deleteSession(at: index) },
                                addExercise: { exerciseName in
                                    let exerciseModel = Exercise(name: exerciseName)
                                    let entry = WorkoutEntry(
                                        exercise: exerciseModel,
                                        date: Date(),
                                        weight: 0,
                                        left: 0,
                                        right: 0,
                                        sets: 0,
                                        reps: 0,
                                        rest: 0,
                                        note: ""
                                    )
                                    addExercise(to: &newSessions[index], exercise: entry)
                                },
                                removeExercise: { exercise in
                                    removeExercise(from: &newSessions[index], exercise: exercise)
                                }
                            )
                        }
                        .padding(.horizontal)
                        
                        // Button to add a new session
                        Button(action: {
                            addSession()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(ColorPalette.primary)
                                Text("Add Session")
                                    .foregroundColor(ColorPalette.primary)
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
        .modifier(NavigationBarModifier())
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
    
    private func addExercise(to session: inout Session, exercise: WorkoutEntry) {
        session.exercises.append(exercise)
    }
    func removeExercise(from session: inout Session, exercise: WorkoutEntry) {
        if let index = session.exercises.firstIndex(where: { $0.id == exercise.id }) {
            session.exercises.remove(at: index)
        }
    }
    
    private func saveWorkoutProgram() {
        // Ensure the program title and sessions are not empty
        guard !programTitle.isEmpty, !newSessions.isEmpty else { return }
        
        let newProgram = WorkoutProgram(title: programTitle, sessions: newSessions)
        context.insert(newProgram)
        print(newProgram.sessions[0].exercises[0].exercise, 183)

        do {
            try context.save()
            dismiss()
            print("context saved")
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

#Preview {
    AddWorkoutProgramView()
}
