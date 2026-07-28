//
//  MobiltyEntryView.swift
//  FitnessTracker
//
//  Created by Matt on 12/31/25.
//

import SwiftUI
import SwiftData

struct MobilityEntryView: View {
    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard
    @EnvironmentObject var auth: AuthManager

    @Binding var isCompleted: Bool
    var exercise: Exercise
    var workoutProgram: WorkoutProgram
    var session: Session
    var deleteExercise: () -> Void // Changed to no-argument closure
    
    // Explicit initializer
    init(isCompleted: Binding<Bool>, exercise: Exercise, workoutProgram: WorkoutProgram, session: Session, deleteExercise: @escaping () -> Void) {
        self._isCompleted = isCompleted
        self.exercise = exercise
        self.workoutProgram = workoutProgram
        self.session = session
        self.deleteExercise = deleteExercise
    }

    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(
            previewUserID: auth.previewUserID,
            liveUserID: auth.user?.uid,
            programID: workoutProgram.id.uuidString,
            sessionID: session.id.uuidString
        )
    }

    @State private var holdTimeInput: String = ""
    @State private var roundsInput: String = ""
    @State private var note: String = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(exercise.type?.rawValue ?? "Type") exercise")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            isCompleted.toggle()
                            saveToDefaults()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Exercise Complete")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                        }
                        .foregroundColor(isCompleted ? .green : .white.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(isCompleted ? Color.green.opacity(0.15) : Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOLD (SEC)")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $holdTimeInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
                        .onChange(of: holdTimeInput) { oldValue, newValue in
                            saveToDefaults()
                        }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROUNDS")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $roundsInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
                        .onChange(of: roundsInput) { oldValue, newValue in
                            saveToDefaults()
                        }
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("NOTE")
                    .font(.caption2.bold())
                        .foregroundColor(.secondary)
                
                TextField("Add a note...", text: $note)
                    .textFieldStyle(MobilityTextFieldStyle())
                    .onChange(of: note) { oldValue, newValue in
                        saveToDefaults()
                    }
            }
            
            HStack {
                Spacer()
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .alert("Delete Mobility Entry", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        deleteExercise() // No argument needed, parent will identify
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to remove this entry?")
                }
            }
        }
        .padding()
        .background(theme.currentTheme.accent.opacity(0.2))
        .cornerRadius(15)
        .onAppear(perform: loadFromDefaults)
    }
    
    // MARK: - Persistence Logic
    
    private func loadFromDefaults() {
        holdTimeInput = "\(defaults.integer(forKey: keyScope.scoped("holdTime\(exercise.name)")))"
        roundsInput = "\(defaults.integer(forKey: keyScope.scoped("rounds\(exercise.name)")))"
        note = defaults.string(forKey: keyScope.scoped("note\(exercise.name)")) ?? ""
    }
    
    private func saveToDefaults() {
        defaults.set(Int(holdTimeInput) ?? 0, forKey: keyScope.scoped("holdTime\(exercise.name)"))
        defaults.set(Int(roundsInput) ?? 0, forKey: keyScope.scoped("rounds\(exercise.name)"))
        defaults.set(note, forKey: keyScope.scoped("note\(exercise.name)"))
    }
}

struct MobilityTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .font(.system(.body, design: .monospaced))
    }
}

#Preview {
    let mockAuthManager = AuthManager()
    let mockProgram = WorkoutProgram(title: "Preview Program", sessions: [])
    let mockSession = Session(name: "Preview Session", exercises: [])

    let mockExercise = Exercise(
        userId: "user_123",
        name: "Pigeon Pose",
        type: .mobility
    )
    
    ZStack {
        Color.black.ignoresSafeArea()
        MobilityEntryView(
            isCompleted: .constant(false),
            exercise: mockExercise,
            workoutProgram: mockProgram,
            session: mockSession,
            deleteExercise: { print("Deleted") } // Updated closure
        )
        .padding()
    }
    .environmentObject(mockAuthManager) // Provide AuthManager as an environment object
    .environment(\.modelContext, try! ModelContainer(for: Exercise.self, configurations: .init(isStoredInMemoryOnly: true)).mainContext) // Corrected ModelContainer initialization
}

