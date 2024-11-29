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
                Text("Abdominals")
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
                Text("Arms")
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
               Text("Chest")
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
                Text("Shoulders")
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
                Text("Legs")
            }
        } label: {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .foregroundColor(Color.white)
        }
    }
}

#Preview {
    ExerciseToolbar()
}
