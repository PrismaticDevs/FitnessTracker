//
//  MobilityHistoryRow.swift
//  FitnessTracker
//
//  Created by Matt on 2/27/26.
//
import SwiftUI

struct MobilityHistoryRow: View {
    let entry: MobilityEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Date Header
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 15) {
                // Hold Time Formatting
                Label(formatDuration(entry.holdTime), systemImage: "clock.arrow.circlepath")
                
                // Rounds
                Label("\(entry.rounds) rounds", systemImage: "repeat")
                
                Spacer()
                
                if let note = entry.note, !note.isEmpty {
                    Image(systemName: "note.text")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption)
            .padding(.vertical, 2)
        }
    }
    
    // Helper to format seconds into a readable "0:00" string
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: seconds) ?? "0:00"
    }
}
