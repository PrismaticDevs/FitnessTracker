////
////  WorkoutHistory.swift
////  FitnessTracker
////
////  Created by Matt on 3/3/25.
import SwiftUI
import SwiftData

struct ExerciseHistorySection: View {
    let exercise: Exercise
    @Query private var masterHistories: [CompletedSession]
    
    var body: some View {
        // Grab the singleton document for the user
        let master = masterHistories.first
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent History")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
            
            Group {
                switch exercise.type {
                case .strength:
                    let strengthData = master?.strengthEntries
                        .filter { $0.exercise == exercise.name }
                        .sorted(by: { $0.date > $1.date }) ?? []
                    
                    if strengthData.isEmpty { emptyState }
                    else {
                        ForEach(strengthData.prefix(3)) { entry in
                            StrengthHistoryRow(entry: entry)
                        }
                    }
                    
                case .cardio:
                    let cardioData = master?.cardioEntries
                        .filter { $0.exercise == exercise.name }
                        .sorted(by: { $0.date > $1.date }) ?? []
                    
                    if cardioData.isEmpty { emptyState }
                    else {
                        ForEach(cardioData.prefix(3)) { entry in
                            CardioHistoryRow(entry: entry)
                        }
                    }
                    
                case .mobility:
                    let mobilityData = master?.mobilityEntries
                        .filter { $0.exercise == exercise.name }
                        .sorted(by: { $0.date > $1.date }) ?? []
                    
                    if mobilityData.isEmpty { emptyState }
                    else {
                        ForEach(mobilityData.prefix(3)) { entry in
                            MobilityHistoryRow(entry: entry)
                        }
                    }
                case .none:
                    emptyState
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var emptyState: some View {
        Text("No previous data for \(exercise.name)")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
    }
}
