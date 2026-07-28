//
//  CardioEntry.swift
//  FitnessTracker
//
//  Created by Matt on 3/29/25.
//

import SwiftUI
import SwiftData

struct CardioEntryView: View {
    @ObservedObject var theme = ThemeManager.shared
    let defaults = UserDefaults.standard // Changed from var to let
    @Environment(\.modelContext) var context
    @EnvironmentObject var auth: AuthManager // Required for keyScope

    // Properties passed from parent
    @Binding var isCompleted: Bool
    var exerciseName: String // Renamed from 'exercise' to avoid conflict with @State 'exercise'
    var workoutProgram: WorkoutProgram // NEW
    var session: Session // NEW
    var deleteExercise: () -> Void // Changed to no-argument closure

    // Explicit Initializer
    init(isCompleted: Binding<Bool>, exerciseName: String, workoutProgram: WorkoutProgram, session: Session, deleteExercise: @escaping () -> Void) {
        self._isCompleted = isCompleted
        self.exerciseName = exerciseName
        self.workoutProgram = workoutProgram
        self.session = session
        self.deleteExercise = deleteExercise
    }

    // Computed property for keyScope
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(
            previewUserID: auth.previewUserID,
            liveUserID: auth.user?.uid,
            programID: workoutProgram.id.uuidString,
            sessionID: session.id.uuidString
        )
    }

    // Internal @State properties
    @State private var durationInput: String = "" // Duration in minutes
    @State private var elevationInput: String = "" // Elevation in meters (assuming this is distance, or a separate metric)
    @State private var heartRateInput: String = "" // Heart rate in bpm
    @State private var distanceInput: String = "" // Added for explicit distance
    @State private var note: String = ""
    @State private var caloriesBurned: Double = 0.0
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            Section {
                HStack {
                    Text(exerciseName)
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            isCompleted.toggle()
                            saveToDefaults() // Save when toggling completion
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
                VStack(spacing: 15) {
                    HStack {
                        VStack {
                            Text("Duration (min)")
                                .font(.caption)
                            TextField("Duration", text: $durationInput)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: durationInput) { oldValue, newValue in
                                    saveToDefaults()
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Distance (mi/km)") // Updated label
                                .font(.caption)
                            TextField("Distance", text: $distanceInput) // Use distanceInput
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: distanceInput) { oldValue, newValue in
                                    saveToDefaults()
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Heart Rate (bpm)")
                                .font(.caption)
                            TextField("Heart Rate", text: $heartRateInput)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: heartRateInput) { oldValue, newValue in
                                    saveToDefaults()
                                    calculateCaloriesBurned()
                                }
                        }
                    }
                    HStack {
                        VStack {
                            Text("Calories Burned")
                                .font(.subheadline)
                            Text("\(caloriesBurned, specifier: "%.1f") cal")
                                .padding()
                                .background(Color.gray.opacity(0.3).cornerRadius(10))
                        }
                        VStack {
                            Text("Note")
                                .font(.subheadline)
                            TextField("Note", text: $note)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: note) { oldValue, newValue in
                                    saveToDefaults()
                                }
                        }
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .alert("Delete Cardio Entry", isPresented: $showDeleteConfirmation) {
                            Button("Delete", role: .destructive) {
                                self.deleteExercise() // No argument needed, parent will identify
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to remove this entry?")
                        }
                }
                }
            }
            .listRowInsets(EdgeInsets())
        }
        .padding()
        .background(theme.currentTheme.accent.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .cornerRadius(15)
        .onAppear(perform: loadFromDefaults)
    }
    
    // MARK: - Persistence Logic
    
    private func loadFromDefaults() {
        durationInput = "\(defaults.double(forKey: keyScope.scoped("duration\(exerciseName)")))".replacingOccidingZeroDecimal()
        distanceInput = "\(defaults.double(forKey: keyScope.scoped("distance\(exerciseName)")))".replacingOccidingZeroDecimal()
        elevationInput = "\(defaults.double(forKey: keyScope.scoped("elevation\(exerciseName)")))".replacingOccidingZeroDecimal()
        heartRateInput = "\(defaults.integer(forKey: keyScope.scoped("heartRate\(exerciseName)")))"
        note = defaults.string(forKey: keyScope.scoped("note\(exerciseName)")) ?? ""
        calculateCaloriesBurned()
    }
    
    private func saveToDefaults() {
        defaults.set(Double(durationInput) ?? 0, forKey: keyScope.scoped("duration\(exerciseName)"))
        defaults.set(Double(distanceInput) ?? 0, forKey: keyScope.scoped("distance\(exerciseName)"))
        defaults.set(Double(elevationInput) ?? 0, forKey: keyScope.scoped("elevation\(exerciseName)"))
        defaults.set(Int(heartRateInput) ?? 0, forKey: keyScope.scoped("heartRate\(exerciseName)"))
        defaults.set(note, forKey: keyScope.scoped("note\(exerciseName)"))
        defaults.set(caloriesBurned, forKey: keyScope.scoped("calories\(exerciseName)"))
    }

    private func calculateCaloriesBurned() {
        let durationInMinutes = Double(durationInput) ?? 0
        let heartRateValue = Double(heartRateInput) ?? 0
        
        let baseCaloriesPerMinute = 5.0
        let intensityFactor = heartRateValue > 0 ? (heartRateValue / 100.0) : 1.0
        
        caloriesBurned = (durationInMinutes * baseCaloriesPerMinute * intensityFactor)
    }
}

extension String {
    func replacingOccidingZeroDecimal() -> String {
        if self.hasSuffix(".0") {
            return String(self.dropLast(2))
        }
        return self
    }
}


#Preview {
    let mockAuthManager = AuthManager()
    let mockProgram = WorkoutProgram(title: "Preview Program", sessions: [])
    let mockSession = Session(name: "Preview Session", exercises: [])

    CardioEntryView( // Removed 'return'
        isCompleted: .constant(false),
        exerciseName: "Test",
        workoutProgram: mockProgram,
        session: mockSession,
        deleteExercise: { print("Deleted") } // Updated closure to no arguments
    )
    .environmentObject(mockAuthManager)
    // Fixed: Use configurations array for ModelConfiguration
    .environment(\.modelContext, try! ModelContainer(for: Exercise.self, configurations: .init(isStoredInMemoryOnly: true)).mainContext) // Corrected ModelContainer initialization
}

