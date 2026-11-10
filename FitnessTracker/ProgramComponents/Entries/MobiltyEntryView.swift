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
    var keyScope: DefaultsKeyScope
    var deleteExercise: (UUID) -> Void

    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard

    @State private var holdTime: String = ""
    @State private var rounds: String = ""
    @State private var note: String = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(exercise.type?.rawValue ?? "Type") exercise")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring()) { isCompleted.toggle() }
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

            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HOLD (SEC)")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    TextField("0", text: $holdTime)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
                        .onChange(of: holdTime) { _, newValue in
                            defaults.set(newValue, forKey: keyScope.scoped("mobilityHold\(exercise.name)"))
                        }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROUNDS")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    TextField("0", text: $rounds)
                        .keyboardType(.numberPad)
                        .textFieldStyle(MobilityTextFieldStyle())
                        .onChange(of: rounds) { _, newValue in
                            defaults.set(newValue, forKey: keyScope.scoped("mobilityRounds\(exercise.name)"))
                        }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("NOTE")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                    TextField("Note", text: $note)
                        .textFieldStyle(MobilityTextFieldStyle())
                        .onChange(of: note) { _, newValue in
                            defaults.set(newValue, forKey: keyScope.scoped("mobilityNote\(exercise.name)"))
                        }
                }
                Button(action: { showDeleteConfirmation = true }) {
                    Image(systemName: "trash").foregroundColor(.red)
                }
                .confirmationDialog("Remove Exercise", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) { deleteExercise(exercise.id) }
                    Button("Cancel", role: .cancel) {}
                }
            }
        }
        .padding()
        .background(theme.currentTheme.accent.opacity(0.2))
        .cornerRadius(15)
        .onAppear(perform: loadFromDefaults)
    }

    private func loadFromDefaults() {
        holdTime = defaults.string(forKey: keyScope.scoped("mobilityHold\(exercise.name)")) ?? ""
        rounds   = defaults.string(forKey: keyScope.scoped("mobilityRounds\(exercise.name)")) ?? ""
        note     = defaults.string(forKey: keyScope.scoped("mobilityNote\(exercise.name)")) ?? ""
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
            keyScope: .from(previewUserID: "preview", liveUserID: nil),
            deleteExercise: { id in print("Deleted \(id)") }
        )
        .padding()
    }
    .modelContainer(container) // 3. Inject container
}
