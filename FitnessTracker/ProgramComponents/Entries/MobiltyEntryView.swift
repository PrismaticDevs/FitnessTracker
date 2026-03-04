//
//  MobiltyEntryView.swift
//  FitnessTracker
//
//  Created by Matt on 12/31/25.
//

import SwiftUI
import SwiftData

struct MobilityEntryView: View {
    @Binding var isCompleted: Bool
    var exercise: Exercise
    var deleteExercise: (UUID) -> Void
    
    @ObservedObject var theme = ThemeManager.shared
    
    // Local state for the inputs
    @State private var holdTime: String = ""
    @State private var rounds: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // --- Header: Name and Delete ---
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
            // --- Input Fields ---
            HStack(spacing: 15) {
                // Hold Time Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOLD (SEC)")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $holdTime)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
                }
                
                // Rounds Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROUNDS")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    
                    TextField("0", text: $rounds)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
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
        let savedHold = UserDefaults.standard.integer(forKey: "\(exercise.name)_last_hold")
        let savedRounds = UserDefaults.standard.integer(forKey: "\(exercise.name)_last_rounds")
        
        // Only set if they aren't zero
        if savedHold > 0 { holdTime = "\(savedHold)" }
        if savedRounds > 0 { rounds = "\(savedRounds)" }
    }
    
    private func saveToDefaults() {
        if let h = Int(holdTime), let r = Int(rounds) {
            UserDefaults.standard.set(h, forKey: "\(exercise.name)_last_hold")
            UserDefaults.standard.set(r, forKey: "\(exercise.name)_last_rounds")
        }
    }
}

// Custom styling to keep the UI tight
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
    // 1. Setup SwiftData mock container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    
    // 2. Create mock exercise
    let mockExercise = Exercise(
        userId: "user_123",
        name: "Pigeon Pose",
        type: .mobility
    )
    
    return ZStack {
        Color.black.ignoresSafeArea()
        MobilityEntryView(
            isCompleted: .constant(false),
            exercise: mockExercise,
            deleteExercise: { id in print("Deleted \(id)") }
        )
        .padding()
    }
    .modelContainer(container) // 3. Inject container
}
