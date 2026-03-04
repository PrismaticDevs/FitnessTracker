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
    @State var duration: String = "" // Duration in minutes
    @State var elevation: String = "" // Elevation in meters
    @State var heartRate: String = "" // Heart rate in bpm
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
                VStack(spacing: 15) {
                    HStack {
                        VStack {
                            Text("Duration (min)")
                                .font(.caption)
                            TextField("Duration", text: $duration)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: duration) { oldValue, newValue in
                                    duration = newValue
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Elevation (m)")
                                .font(.caption)
                            TextField("Elevation", text: $elevation)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: elevation) { oldValue, newValue in
                                    elevation = newValue
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Heart Rate (bpm)")
                                .font(.caption)
                            TextField("Heart Rate", text: $heartRate)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                                .onChange(of: heartRate) { oldValue, newValue in
                                    heartRate = newValue
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
                        }
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(title: Text("Delete Cardio Entry"),
                                  message: Text("Are you sure you want to remove this entry?"),
                                  primaryButton: .destructive(Text("Delete")) {
                            },
                                  secondaryButton: .cancel()
                            )
                        }
                }
                }
            }
            .listRowInsets(EdgeInsets()) // Remove default insets
        }
        .padding()
        .background(theme.currentTheme.accent.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .cornerRadius(15)
    }
    
    private func calculateCaloriesBurned() {
        let durationInMinutes = Double(duration) ?? 0
        let elevationInMeters = Double(elevation) ?? 0
        let heartRateValue = Double(heartRate) ?? 0
        
        // Example calculation: (duration * MET value) - this is a placeholder
        let metValue = 8.0 // MET value for running, adjust as needed
        // You can adjust the formula to include elevation if needed
        caloriesBurned = (metValue * 3.5 * heartRateValue * durationInMinutes) / 200 + (elevationInMeters * 0.1) // Example adjustment
    }
}

#Preview {
    CardioEntryView(isCompleted: .constant(false),exercise: "5k", deleteExercise: { id in print("Deleted \(id)") })
}
