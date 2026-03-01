//
//  Cardio.swift
//  FitnessTracker
//
//  Created by Matt on 2/27/26.
//

import SwiftUI

struct CardioHistoryRow: View {
    let entry: CardioEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 15) {
                Label("\(Int(entry.duration / 60)) min", systemImage: "timer")
                if let hr = entry.heartRate {
                    Label("\(hr) bpm", systemImage: "heart.fill")
                }
                if let elev = entry.elevation {
                    Label("\(Int(elev))m", systemImage: "mountain.2")
                }
            }
            .font(.caption)
        }
    }
}
