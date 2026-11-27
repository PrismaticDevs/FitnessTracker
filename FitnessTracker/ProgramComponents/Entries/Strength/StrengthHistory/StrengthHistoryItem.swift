//
//  StrengthEntryHistoryList.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/26.
//

import SwiftUI
import SwiftData

struct StrengthHistoryItem: View {
    @Environment(\.modelContext) var context
    let entry: StrengthEntry
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Date and Session Name
            HStack {
                Text(entry.date.formatted(date: .numeric, time: .shortened))
                    .font(.headline)
                Spacer()
                Text(entry.exercise)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.fillStrong)
                    .cornerRadius(5)
            }
            .foregroundColor(.textPrimary)

            // Dynamic Sets Display
            ForEach(entry.sets.indices, id: \.self) { index in
                let set = entry.sets[index]
                HStack {
                    Text("Set \(index + 1)")
                        .fontWeight(.semibold)
                    Spacer()
                    if set.left > 0 || set.right > 0 {
                        Text("L: \(set.left) R: \(set.right) × \(set.reps)")
                    } else {
                        Text("\(set.combined) lbs × \(set.reps)")
                    }
                    
                    if set.rest > 0 {
                        Text("(\(set.rest)s rest)")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            }

            if let note = entry.note, !note.isEmpty {
                Text("Note: \(note)")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                context.delete(entry)
                try? context.save()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove this exercise record from your history.")
        }
    }
}
