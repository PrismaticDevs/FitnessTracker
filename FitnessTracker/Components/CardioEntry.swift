//
//  CardioEntry.swift
//  FitnessTracker
//
//  Created by Matt on 3/29/25.
//

import SwiftUI
import SwiftData

struct CardioEntryView: View {
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    @State var id: UUID = UUID()
    @State var exercise: String
    @State var duration: String = "" // Duration in minutes
    @State var elevation: String = "" // Elevation in meters
    @State var heartRate: String = "" // Heart rate in bpm
    @State var note: String = ""
    @State var caloriesBurned: Double = 0.0
    @State var showDeleteConfirmation = false
    var onDelete: () -> Void

    var body: some View {
        VStack {
            Section {
                HStack {
                    Text(exercise)
                        .foregroundColor(.white)
                        .font(.headline)
                }
                
                VStack {
                    HStack {
                        VStack {
                            Text("Duration (min)")
                                .font(.subheadline)
                            TextField("Duration", text: $duration)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .onChange(of: duration) { oldValue, newValue in
                                    duration = newValue
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Elevation (m)")
                                .font(.subheadline)
                            TextField("Elevation", text: $elevation)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .onChange(of: elevation) { oldValue, newValue in
                                    elevation = newValue
                                    calculateCaloriesBurned()
                                }
                        }
                        VStack {
                            Text("Heart Rate (bpm)")
                                .font(.subheadline)
                            TextField("Heart Rate", text: $heartRate)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
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
                    }
                    
                    VStack {
                        Text("Note")
                            .font(.subheadline)
                        TextField("Note", text: $note)
                            .padding()
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
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
                            onDelete()
                        },
                              secondaryButton: .cancel()
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets()) // Remove default insets
        }
        .background(.clear)
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
    CardioEntryView(exercise: "Running", onDelete: {})
}
