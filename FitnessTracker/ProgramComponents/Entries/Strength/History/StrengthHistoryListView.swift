//
//  StrengthHistoryListView.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/26.
//

import SwiftUI
import SwiftData

struct StrengthHistoryListView: View {
    @Environment(\.modelContext) var context
    @Query private var history: [StrengthEntry]
    let exerciseName: String

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        let name = exerciseName
        _history = Query(
            filter: #Predicate<StrengthEntry> { $0.exercise == name },
            sort: \StrengthEntry.date,
            order: .reverse
        )
    }

    var body: some View {
        ZStack {
            if history.isEmpty {
                ContentUnavailableView(label: {
                    Label("No history for \(exerciseName)", systemImage: "list.bullet.rectangle.portrait")
                        .foregroundColor(.white)
                }, description: {
                    Text("Complete a session to see your progress here.")
                        .foregroundColor(.white.opacity(0.7))
                })
            } else {
                List {
                    ForEach(history) { entry in
                        StrengthHistoryItem(entry: entry)
                            .listRowBackground(Color.blue.opacity(0.3)) // Matches your blue theme
                            .listRowSeparatorTint(.white.opacity(0.2))
                    }
                }
                .frame(minHeight: 300, maxHeight: 500) // Keeps it contained in your entry view
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
    }
}
