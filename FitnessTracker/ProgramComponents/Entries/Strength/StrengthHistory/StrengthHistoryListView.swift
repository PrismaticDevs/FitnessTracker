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
    // Entry History
    @Query private var history: [StrengthEntry]
    @State private var entryToDelete: StrengthEntry?
    @State private var showDeleteAlert = false
    
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
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    entryToDelete = entry
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .frame(minHeight: 300, maxHeight: 500) // Keeps it contained in your entry view
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .alert("Delete History?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    deleteEntry(entry)
                }
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        } message: {
            if let entry = entryToDelete {
                Text("Are you sure you want to delete the data for \(entry.date.formatted(.dateTime.month().day().hour().minute()))?")
            } else {
                Text("Are you sure you want to delete this record?")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func deleteEntry(_ entry: StrengthEntry) {
        // If this entry is part of a session, remove it from the session's list first
        if let session = entry.session {
            session.strengthEntries.removeAll(where: { $0.id == entry.id })
        }
        
        context.delete(entry)
        
        do {
            try context.save()
            print("Deleted entry for \(exerciseName)")
        } catch {
            print("Delete failed: \(error.localizedDescription)")
        }
    }
}
