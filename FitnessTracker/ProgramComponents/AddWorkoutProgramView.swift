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
    @StateObject private var exerciseList = ExerciseList()
    @State private var showingPrebuiltSheet = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isFocused = false
                    }
                
                VStack(spacing: 16) {
                    customHeader
                    ScrollView {
                        Text("Add New Workout program")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                        Section {
                            Button(action: { showingPrebuiltSheet = true }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                    Text("Start from a Prebuilt Template")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption.bold())
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding()
                        Section(header: Text("Title").font(.headline).foregroundColor(.white)) {
                            TextField("Program Title", text: $programTitle, prompt: Text("Program Title").foregroundColor(.white.opacity(0.5)))
                                .focused($isFocused)
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
                                        .focused($isFocused)
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
                                    title: "Add Exercise",
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isFocused = false
                    }
                }
            }
            .sheet(isPresented: $showingPrebuiltSheet) {
                PrebuiltProgramsView {
                    showingPrebuiltSheet = false
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .brandedBackButton(title: "",theme: theme.currentTheme, dismiss: dismiss)
    }
    
    private var customHeader: some View {
        HStack {
            Spacer()
            Button(action: saveWorkoutProgram) {
                HStack {
                    Text("Ceate")
                    Image(systemName: "plus.circle.fill")
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(canCreateProgram ? theme.currentTheme.accent : Color.gray.opacity(0.3))
                .foregroundColor(canCreateProgram ? .white : .white.opacity(0.5))
                .cornerRadius(20)
            }
            .disabled(!canCreateProgram)
        }
        .padding(.horizontal)
        .padding(.top, 60)
        .padding(.bottom, 10)
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
