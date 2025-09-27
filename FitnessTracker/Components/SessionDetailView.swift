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
    @State private var showingRenameSheet = false
    @State private var newSessionName: String = ""


    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(session.exercises.sorted(by: { $0.exercise < $1.exercise })) { exercise in
                            WorkoutEntryView(
                                exercise: exercise.exercise,
                                weight: exercise.weight,
                                left: exercise.left,
                                right: exercise.right,
                                sets: exercise.sets,
                                reps: exercise.reps,
                                rest: exercise.rest,
                                note: exercise.note,
                                onDelete: {
                                    deleteExercise(named: exercise.exercise)
                                }
                            )
                        }
                    }
                }
            }
            .applyGradientBackground()
        }
        .navigationTitle("\(session.name) Exercises")
        .modifier(NavigationBarModifier())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button(action: {
                   newSessionName = session.name // Set the current session name as the default
                   showingRenameSheet = true // Show the alert to rename
               }) {
                   Image(systemName: "pencil")
               }
           }
            ToolbarItem(placement: .navigationBarTrailing) {
                ExerciseToolbar(
                    exerciseName: $selectedExerciseName,
                    exercisesSelected: session.exercises.map { $0.exercise },
                    onExerciseSelected: { exerciseName in
                        addExercise(named: exerciseName)
                    }
                )
            }
        }
        .sheet(isPresented: $showingRenameSheet) {
                    VStack {
                        Text("Rename Session")
                            .font(.headline)
                            .padding()

                        TextField("New Session Name", text: $newSessionName, prompt: Text("New Session Name").foregroundColor(ColorPalette.primary.opacity(0.5)))
                            .padding()
                            .background(Color.blue.opacity(0.8).cornerRadius(10))


                        Button("Rename") {
                            renameSession()
                            showingRenameSheet = false // Dismiss the sheet
                        }
                        .padding()
                    }
                    .padding()
                    .applyGradientBackground()
                }
    }
    
    private func addExercise(named exerciseName: String) {
        let newExercise = WorkoutEntry(
            exercise: exerciseName,
            date: Date(),
            weight: 0,
            left: 0,
            right: 0,
            sets: 0,
            reps: 0,
            rest: 0,
            note: ""
        )
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
        if let index = session.exercises.firstIndex(where: { $0.exercise == exerciseName }) {
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
    
    private func renameSession() {
        // Update the session name
        session.name = newSessionName
        
        // Update the workout program to reflect the changes
        if let programIndex = workoutProgram.sessions.firstIndex(where: { $0.id == session.id }) {
            workoutProgram.sessions[programIndex] = session
        }
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Failed to save context after renaming session: \(error)")
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
    let session = Session(name: "Morning Workout", exercises: exercises as! [WorkoutEntry])
    
    let workoutProgram = WorkoutProgram(title: "Test Program", sessions: [session])
    
    // Pass the mock session to the preview
    SessionDetailView(session: session, workoutProgram: workoutProgram)
}
