//
//  ExerciseToolbar.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct ExerciseToolbar: View {
    var body: some View {
        Menu {
            Menu {
                ForEach(ExerciseList().Abdominals, id: \.self) { exercise in
                    Button {
                        print(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Label("Abdominals", systemImage: "plus.circle.fill")
            }
            Menu {
                ForEach(ExerciseList().Arms, id: \.self) { exercise in
                    Button {
                        print(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Label("Arms", systemImage: "plus.circle.fill")
            }
            Menu {
                ForEach(ExerciseList().Chest, id: \.self) { exercise in
                    Button {
                        print(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Label("Chest", systemImage: "plus.circle.fill")
            }
            Menu {
                ForEach(ExerciseList().Shoulders, id: \.self) { exercise in
                    Button {
                        print(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Label("Shoulders", systemImage: "plus.circle.fill")
            }
            Menu {
                ForEach(ExerciseList().Legs, id: \.self) { exercise in
                    Button {
                        print(exercise)
                    } label: {
                        Label(exercise, systemImage: "plus.circle.fill")
                    }
                }
            } label: {
                Label("Legs", systemImage: "plus.circle.fill")
            }
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
        }
    }
}

#Preview {
    ExerciseToolbar()
}
