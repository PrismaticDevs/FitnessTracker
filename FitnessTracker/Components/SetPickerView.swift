//
//  SetPickerView.swift
//  FitnessTracker
//
//  Created by Matt on 9/20/25.
//

import SwiftUI
import SwiftData

struct SetPickerView: View {
    @Environment(\.modelContext) var context
    @Binding var selectedId: UUID?
    @Query(sort: [SortDescriptor<WorkoutEntry>(\.date, order: .reverse)])
    private var savedEntries: [WorkoutEntry]
    var body: some View {
        VStack {
            Picker("Set", selection: $selectedId) {
                ForEach(savedEntries) { e in
                    Text(e.exercise).tag(e.id as UUID?)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
