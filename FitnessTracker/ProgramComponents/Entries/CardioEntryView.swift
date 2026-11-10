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
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    @Binding var isCompleted: Bool

    var exercise: String
    var keyScope: DefaultsKeyScope

    @State var duration: String = ""    // minutes
    @State var distance: String = ""    // km / miles
    @State var heartRate: String = ""   // bpm (used for calorie estimate, not persisted to model)
    @State var note: String = ""
    @State var caloriesBurned: Double = 0.0
    @State var showDeleteConfirmation = false
    var deleteExercise: (UUID) -> Void

    var body: some View {
        VStack {
            Section {
                HStack {
                    Text(exercise)
                        .foregroundColor(.white)
                        .font(.headline)
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
                VStack(spacing: 15) {
                    HStack {
                        VStack {
                            Text("Duration (min)")
                                .font(.caption)
                            TextField("Duration", text: $duration)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: duration) { _, newValue in
                                    defaults.set(newValue, forKey: keyScope.scoped("cardioDuration\(exercise)"))
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Distance (km)")
                                .font(.caption)
                            TextField("Distance", text: $distance)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: distance) { _, newValue in
                                    defaults.set(newValue, forKey: keyScope.scoped("cardioDistance\(exercise)"))
                                }
                        }
                        VStack {
                            Text("Heart Rate (bpm)")
                                .font(.caption)
                            TextField("Heart Rate", text: $heartRate)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: heartRate) { _, _ in
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
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                        }
                        VStack {
                            Text("Note")
                                .font(.subheadline)
                            TextField("Note", text: $note)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: note) { _, newValue in
                                    defaults.set(newValue, forKey: keyScope.scoped("cardioNote\(exercise)"))
                                }
                        }
                        Button(action: { showDeleteConfirmation = true }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                        .confirmationDialog("Remove Exercise", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) { deleteExercise(UUID()) }
                            Button("Cancel", role: .cancel) {}
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
        .onAppear(perform: loadFromDefaults)
    }

    private func loadFromDefaults() {
        duration    = defaults.string(forKey: keyScope.scoped("cardioDuration\(exercise)")) ?? ""
        distance    = defaults.string(forKey: keyScope.scoped("cardioDistance\(exercise)")) ?? ""
        note        = defaults.string(forKey: keyScope.scoped("cardioNote\(exercise)")) ?? ""
        calculateCaloriesBurned()
    }

    private func calculateCaloriesBurned() {
        let durationInMinutes = Double(duration) ?? 0
        let heartRateValue    = Double(heartRate) ?? 0
        let distanceKm        = Double(distance) ?? 0
        let metValue          = 8.0
        caloriesBurned = (metValue * 3.5 * heartRateValue * durationInMinutes) / 200 + (distanceKm * 60)
        defaults.set(Int(caloriesBurned), forKey: keyScope.scoped("cardioCalories\(exercise)"))
    }
}

#Preview {
    CardioEntryView(
        isCompleted: .constant(false),
        exercise: "5k",
        keyScope: .from(previewUserID: "preview", liveUserID: nil),
        deleteExercise: { id in print("Deleted \(id)") }
    )
}
