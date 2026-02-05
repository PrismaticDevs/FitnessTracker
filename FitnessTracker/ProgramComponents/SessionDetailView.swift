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
    @Environment(AIContextManager.self) var aiManager
    @State private var showingAddExerciseView = false
    @State private var selectedExerciseName: String = ""
    @State private var showingRenameSheet = false
    @State private var newSessionName: String = ""


    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack {
                    ForEach(session.exercises.sorted { lhs, rhs in lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending }) { exercise in
                        StrengthEntryView(

                                exercise: exercise,
                                // The child view will handle loading its own state via .onAppear
                                deleteExercise: { name in deleteExercise(named: name) }
                            )
                            
                            Text(exercise.type?.rawValue ?? "strength")
                                .font(.caption)
                                .foregroundColor(.secondary)
//                        switch exercise.type {
 //                       case .strength:
 //                           StrengthEntryView(exercise: exercise, combined: defaults.integer(forKey: "combined\(exercise.name)"), left: defaults.integer(forKey: "left\(exercise.name)"), right: defaults.integer(forKey: "right\(exercise.name)"), reps: defaults.integer(forKey: "reps\(exercise.name)"), rest: defaults.integer(forKey: "rest\(exercise.name)"), note: defaults.string(forKey: "note\(exercise.name)") ?? "", deleteExercise: { name in deleteExercise(named: name) })
 //                       case .cardio:
 //                           CardioEntryView(exercise: exercise, distance: defaults.integer(forKey: "distance\(exercise.name)"), duration: defaults.integer(forKey: "duration\(exercise.name)"), note: defaults.string(forKey: "note\(exercise.name)") ?? "", deleteExercise: { name in deleteExercise(named: name) })
 //                       case .mobility:
 //                           MobilityEntryView()
 //                        }
                    }
                }
            }
        }
        .onAppear {
            updateAIWithLiveSessionData()
        }
        .applyGradientBackground()
        .navigationTitle("\(session.name) Exercises")
        .navigationBarTitleDisplayMode(.inline)
//        .modifier(NavigationBarModifier())
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
                    exercisesSelected: session.exercises.map { $0.name },
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
                    .background(ColorPalette.accent.opacity(0.8).cornerRadius(10))

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
    
    private func updateAIWithLiveSessionData() {
            // 1. Collect exercise names
            let exercises = session.exercises.map { $0.name }.joined(separator: ", ")
            
            // 2. Build a summary of user-inputted values from UserDefaults
            // Example: Pulling weight/reps for each exercise in this session
            var liveStats = ""
            for exercise in session.exercises {
                let weight = UserDefaults.standard.double(forKey: "\(exercise.name)_weight")
                let reps = UserDefaults.standard.integer(forKey: "\(exercise.name)_reps")
                if weight > 0 {
                    liveStats += "\(exercise.name): \(weight)kg x \(reps) reps. "
                }
            }
            
            let details = """
            User is performing session '\(session.name)'. 
            Exercises: \(exercises). 
            Current Live Progress: \(liveStats.isEmpty ? "No sets recorded yet." : liveStats)
            """
            
            aiManager.updateContext(screen: "Active Workout", details: details)
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
            defaults.removeObject(forKey: "combined\(exerciseName)")
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
    private func generateSessionContext() -> String {
        var contextString = "Current Session: \(session.name)\n"
        
        for exercise in session.exercises {
            contextString += "\nExercise: \(exercise.name)\n"
            
            // Fetch the data from UserDefaults (matches your EntryView keys)
            let sets = defaults.integer(forKey: "sets\(exercise.name)")
            let note = defaults.string(forKey: "note\(exercise.name)") ?? "No notes"
            
            contextString += "- Configured Sets: \(sets)\n"
            
            // Loop through the individual sets to get the weight/reps
            // Assuming your keys follow the pattern: weightExerciseName_set0
            for i in 0..<max(1, sets) {
                let weight = defaults.integer(forKey: "weight\(exercise.name)_set\(i)")
                let reps = defaults.integer(forKey: "reps\(exercise.name)_set\(i)")
                if weight > 0 || reps > 0 {
                    contextString += "  [Set \(i+1)]: \(weight)kg x \(reps) reps\n"
                }
            }
            contextString += "- Note: \(note)\n"
        }
        return contextString
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
