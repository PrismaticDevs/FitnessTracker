//
//  ExerciseHistoryView.swift
//  FitnessTracker
//
//  Created by Matt on 2/27/26.
//
import SwiftUI
import SwiftData

struct ExerciseHistoryView: View {
    let exerciseName: String
    let exerciseType: ExerciseType
    
    @Query private var masterHistories: [CompletedSession]
    
    var body: some View {
        // Since we are using the "One Document" approach:
        let master = masterHistories.first
        
        VStack(alignment: .leading, spacing: 10) {
            Text("History")
                .font(.headline)
                .padding(.top)

            // Logic to determine which array to filter
            switch exerciseType {
            case .strength:
                let entries = master?.strengthEntries.filter { $0.exercise == exerciseName }
                    .sorted(by: { $0.date > $1.date }) ?? []
                historyList(entries: entries, rowBuilder: StrengthHistoryRow.init)
                
            case .cardio:
                let entries = master?.cardioEntries.filter { $0.exercise == exerciseName }
                    .sorted(by: { $0.date > $1.date }) ?? []
                historyList(entries: entries, rowBuilder: CardioHistoryRow.init)
                
            case .mobility:
                let entries = master?.mobilityEntries.filter { $0.exercise == exerciseName }
                    .sorted(by: { $0.date > $1.date }) ?? []
                historyList(entries: entries, rowBuilder: MobilityHistoryRow.init)
            }
        }
        .padding(.horizontal)
    }

    // A generic helper to avoid code duplication
    @ViewBuilder
    private func historyList<T: Identifiable, V: View>(entries: [T], rowBuilder: @escaping (T) -> V) -> some View {
        if entries.isEmpty {
            Text("No history yet.")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            // Only show the last 5 sessions to keep it clean
            ForEach(entries.prefix(5)) { entry in
                rowBuilder(entry)
                Divider()
            }
        }
    }
}

