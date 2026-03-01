//
//  Strength.swift
//  FitnessTracker
//
//  Created by Matt on 2/27/26.
//
import SwiftUI

struct StrengthHistoryRow: View {
    let entry: StrengthEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(entry.sets) { set in
                    Text("\(set.combined)lbs x \(set.reps)")
                        .font(.system(size: 12, design: .monospaced))
                        .padding(4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
    }
}
