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
    var onDelete: (UUID) -> Void

    // Tracking state for the dialog
    @State private var showDeleteConfirmation = false
    @State private var exerciseToInstance: Exercise?

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
                        deleteExercise: { _ in
                            // Stage THIS specific instance
                            self.exerciseToInstance = exercise
                            self.showDeleteConfirmation = true
                            print("confirm delete for \(exercise.name)")
                        }
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
            // THE DIALOG: Moved outside the List loop to ensure it has valid buttons
            .confirmationDialog(
                "Remove Exercise",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let id = exerciseToInstance?.id {
                        onDelete(id)
                    }
                }
                Button("Cancel", role: .cancel) {
                    exerciseToInstance = nil
                }
            } message: {
                Text("Are you sure you want to remove \(exerciseToInstance?.name ?? "this exercise") ?? from this session?")
            }
        }
    }
}
