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
                            exerciseName = exercise.name // or exercise.exercise if that's the property
                            onExerciseSelected(exercise.name) // or exercise.exercise
                        } label: {
                            Label(exercise.name, systemImage: "plus.circle.fill") // or exercise.exercise
                        }
                    }
                } label: {
                    Text(category.name)
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
