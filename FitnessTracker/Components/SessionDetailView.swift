//
//  SessionDetailView.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    var defaults = UserDefaults.standard
    var session: Session
    @Environment(\.modelContext) var context
    @State private var showingAddExerciseView = false
    @State private var selectedExerciseName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(session.exercises) { exercise in
                            WorkoutEntryView(exercise: exercise.name, weight: defaults.integer(forKey: "weight\(exercise.name)"), left: defaults.integer(forKey: "left\(exercise.name)"), right: defaults.integer(forKey: "right\(exercise.name)"), sets: defaults.string(forKey: "sets\(exercise.name)") ?? "", reps: defaults.string(forKey: "reps\(exercise.name)") ?? "", rest: defaults.string(forKey: "rest\(exercise.name)") ?? "", note: defaults.string(forKey: "note\(exercise.name)") ?? "")
                        }
                    }
                }
                .padding(.top, 16)
            }
            .applyGradientBackground()
        }
        .navigationTitle("\(session.name) Exercises")
        .modifier(NavigationBarModifier())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ExerciseToolbar(
                    exerciseName: $selectedExerciseName,
                    exercisesSelected: session.exercises.map { $0.name },
                    onExerciseSelected: { exerciseName in
                        addExercise(named: exerciseName)
                    }
                )
            }
        }
    }
    
    private func addExercise(named exerciseName: String) {
        let newExercise = Exercise(name: exerciseName)
        session.exercises.append(newExercise)
    }
}

#Preview {
    // Create mock exercises
    let exercises = [
        Exercise(name: "Push Up"),
        Exercise(name: "Squat"),
        Exercise(name: "Lunge")
    ]
    
    // Create a mock session
    let session = Session(name: "Morning Workout", exercises: exercises)
    
    // Pass the mock session to the preview
    SessionDetailView(session: session)
}
