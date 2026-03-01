//
//  MobilityHistorySection.swift
//  FitnessTracker
//
//  Created by Matt on 2/27/26.
//

import SwiftUI
import SwiftData

struct MobilityHistorySection: View {
    let exerciseName: String
    @Query private var allMobility: [MobilityEntry]

    var filteredHistory: [MobilityEntry] {
        allMobility
            .filter { $0.exercise == exerciseName }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(filteredHistory.prefix(3)) { entry in
                HStack {
                    Text(entry.date.formatted(.dateTime.month().day()))
                        .font(.caption2).bold()
                    Spacer()
                    Text("\(Int(entry.holdTime))s x \(entry.rounds)")
                        .font(.caption2)
                }
                .padding(8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }
        }
    }
}
