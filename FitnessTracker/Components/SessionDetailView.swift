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
    var workoutProgram: WorkoutProgram
    @Environment(\.modelContext) var context
    @State private var showingAddExerciseView = false
    @State private var selectedExerciseName: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(session.exercises) { exercise in
                            WorkoutEntryView(exercise: exercise.name, weight: defaults.integer(forKey: "weight\(exercise.name)"), left: defaults.integer(forKey: "left\(exercise.name)"), right: defaults.integer(forKey: "right\(exercise.name)"), sets: defaults.string(forKey: "sets\(exercise.name)") ?? "", reps: defaults.string(forKey: "reps\(exercise.name)") ?? "", rest: defaults.string(forKey: "rest\(exercise.name)") ?? "", note: defaults.string(forKey: "note\(exercise.name)") ?? "", onDelete: {
                                deleteExercise(named: exercise.name)
                            })
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
        
        // Save the updated session back to the workout program
        if let index = workoutProgram.sessions.firstIndex(where: { $0.id == session.id }) {
            workoutProgram.sessions[index] = session
        }
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func deleteExercise(named exerciseName: String) {
        // Find the index of the exercise to delete
        if let index = session.exercises.firstIndex(where: { $0.name == exerciseName }) {
            // Remove the exercise from the session's exercises array
            session.exercises.remove(at: index)
            
            // Remove associated data from UserDefaults
            defaults.removeObject(forKey: "weight\(exerciseName)")
            defaults.removeObject(forKey: "left\(exerciseName)")
            defaults.removeObject(forKey: "right\(exerciseName)")
            defaults.removeObject(forKey: "sets\(exerciseName)")
            defaults.removeObject(forKey: "reps\(exerciseName)")
            defaults.removeObject(forKey: "rest\(exerciseName)")
            defaults.removeObject(forKey: "note\(exerciseName)")
            
            // Update the workout program to reflect the changes
                  if let programIndex = workoutProgram.sessions.firstIndex(where: { $0.id == session.id }) {
                      workoutProgram.sessions[programIndex] = session
                  }
                  
                  // Save the context to persist changes
                  do {
                      try context.save()
                  } catch {
                      print("Failed to save context after deleting exercise: \(error)")
                  }
        }
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
    
    let workoutProgram = WorkoutProgram(title: "Test Program", sessions: [session])
    
    // Pass the mock session to the preview
    SessionDetailView(session: session, workoutProgram: workoutProgram)
}
