//
//  ExerciseToolbar.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct ExerciseToolbar: View {
    @Environment(\.modelContext) var context
    @Binding var exerciseName: String
    var exercisesSelected: [String]
    var onExerciseSelected: (String) -> Void
    @State private var exerciseList = ExerciseList()

    var body: some View {
        Menu {
            ForEach(exerciseList.categories) { category in
                Menu {
                    ForEach(category.exercises, id: \.id) { exercise in
                        Button {
                            exerciseName = exercise.name
                            onExerciseSelected(exercise.name)
                        } label: {
                            Label(exercise.name, systemImage: "plus.circle.fill")
                        }
                    }
                } label: {
                    Text(category.name) // Use the category name for the menu label
                }
            }
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .foregroundColor(Color.white)
        }
    }
}

#Preview {
    ExerciseToolbar(
        exerciseName: .constant(""), // Example binding
        exercisesSelected: ["Push Up", "Squat"], // Example selected exercises
        onExerciseSelected: { selectedExercise in
            print("Selected exercise: \(selectedExercise)") // Example action
        }
    )
}
