//
//  ExerciseListSection.swift
//  FitnessTracker
//
//  Created by Matt on 2/23/26.
//
import SwiftUI

struct ExerciseListSection: View {
    var session: Session
    @Binding var editMode: EditMode
    @Binding var completedExerciseIds: Set<UUID>
    var onMove: (IndexSet, Int) -> Void
    var onDelete: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(session.exercises) { exercise in
                    StrengthEntryView(
                        isCompleted: Binding(
                            get: { completedExerciseIds.contains(exercise.id) },
                            set: { if $0 { completedExerciseIds.insert(exercise.id) } else { completedExerciseIds.remove(exercise.id) } }
                        ),
                        exercise: exercise,
                        allExercises: session.exercises,
                        deleteExercise: { _ in onDelete(exercise.name) }
                    )
                    .id(exercise.id)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onMove(perform: onMove)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.editMode, $editMode)
        }
    }
}
