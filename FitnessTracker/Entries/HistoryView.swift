//
//  HistoryView.swift
//  FitnessTracker
//
//  Created by Matt on 10/15/25.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryList: View {
    @Query(sort: [SortDescriptor(\WorkoutHistory.date, order: .reverse)]) var histories: [WorkoutHistory]
    var body: some View {
        List {
            ForEach(histories) { h in
                NavigationLink(value: h) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(h.exercise).font(.headline)
                            Text(DateFormatter.localizedString(from: h.date, dateStyle: .short, timeStyle: .short))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(h.entries.count) entry\(h.entries.count == 1 ? "" : "ies")")
                            .font(.caption)
                    }
                }
            }
            .onDelete { idx in
                delete(at: idx)
            }
        }
        .navigationTitle("History")
    }

    @Environment(\.modelContext) private var context

    private func delete(at offsets: IndexSet) {
        for i in offsets {
            context.delete(histories[i])
        }
        try? context.save()
    }
}
#Preview {
    WorkoutHistoryList()
}
