//
//  ExerciseToolbar.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI
import SwiftData

struct ExerciseToolbar: View {
    // Global Context
    @Environment(\.modelContext) var context
    @ObservedObject var theme = ThemeManager.shared
    @EnvironmentObject var auth: AuthManager
    // Exercise Management
    @Binding var exerciseName: String
    @State private var showMangement = false
    var exercisesSelected: [String]
    var onExerciseSelected: (String) -> Void
    let title: String
    @State private var exerciseList = ExerciseList()

    
    @Query(sort: \ExerciseCategory.name) private var categories: [ExerciseCategory]
    
    init(title: String,
             exerciseName: Binding<String>,
             exercisesSelected: [String],
             onExerciseSelected: @escaping (String) -> Void) {
            self.title = title
            self._exerciseName = exerciseName
            self.exercisesSelected = exercisesSelected
            self.onExerciseSelected = onExerciseSelected
        }

    var body: some View {
        HStack {
            Menu {
                Section {
                    Button {
                        showMangement = true
                    } label: {
                        Label("Exit Exercises", systemImage: "pencil")
                    }
                }
                Section {
                    ForEach(categories) { category in
                        Menu {
                            ForEach(category.exercises.sorted(by: { $0.name.localizedStandardCompare($1.name) == .orderedAscending}), id: \.id) { exercise in
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
                }
            } label: {
                Label(title, systemImage: "plus.circle.fill")
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showMangement) {
            NavigationStack {
                ExerciseManagement(userId: auth.user?.uid ?? "")
            }
        }
    }
}

#Preview {
    let mockAuthManager = AuthManager()
    ExerciseToolbar(
        title: "Add Exercise",
        exerciseName: .constant(""), // Example binding
        exercisesSelected: ["Push Up", "Squat"], // Example selected exercises
        onExerciseSelected: { selectedExercise in
            print("Selected exercise: \(selectedExercise)") // Example action
        }
    )
    .environmentObject(mockAuthManager)
}
