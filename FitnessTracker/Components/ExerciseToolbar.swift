//
//  ExerciseToolbar.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct ExerciseToolbar: View {
    @Binding var exerciseName: String
    var onExerciseSelected: (String) -> Void
    
    // Create a single instance of ExerciseList
    @State private var exerciseList = ExerciseList()
    
    var body: some View {
        Menu {
            // Abdominals Menu
            Menu {
                ForEach(exerciseList.Abdominals, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Abdominals")
            }
            
            // Arms Menu
            Menu {
                ForEach(exerciseList.Arms, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Arms")
            }
            
            // Chest Menu
            Menu {
                ForEach(exerciseList.Chest, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Chest")
            }
            
            // Shoulders Menu
            Menu {
                ForEach(exerciseList.Shoulders, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Shoulders")
            }
            
            // Legs Menu
            Menu {
                ForEach(exerciseList.Legs, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Legs")
            }
            
            // Back Menu
            Menu {
                ForEach(exerciseList.Back, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Back")
            }
            
            // Full Body Menu
            Menu {
                ForEach(exerciseList.FullBody, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Full Body")
            }
            
            // Cardio Menu
            Menu {
                ForEach(exerciseList.Cardio, id: \.self) { exercise in
                    Button {
                        exerciseName = exercise
                        onExerciseSelected(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Text("Cardio")
            }
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .foregroundColor(Color.white)
        }
    }
}

#Preview {
    ExerciseToolbar(exerciseName: .constant(""), onExerciseSelected: { _ in })
}
