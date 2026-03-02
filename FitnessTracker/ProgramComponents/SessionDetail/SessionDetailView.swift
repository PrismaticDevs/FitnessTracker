//
//  SessionDetailView.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard
    var session: Session
    var workoutProgram: WorkoutProgram
    var exercises: [Exercise]
    
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) var aiManager
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var editMode: EditMode = .inactive
    @State private var completedExerciseIds: Set<UUID> = []
    var liveCompletedCount: Int {
        session.exercises.filter { $0.isCompleted }.count
    }
    @State private var dragOffset: CGFloat = 0
    @State private var showingRenameSheet = false
    @State private var newSessionName: String = ""
    
    // Save/Upload State
    @State private var network = NetworkMonitor()
    @State private var hasSavedLocally = false
    @State private var isUploading = false
    @State private var showSyncError = false
    
    

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 120)
                
                ExerciseListSection(
                    session: session,
                    completedExerciseIds: $completedExerciseIds,
                    onDelete: deleteExercise
                )
                
                BottomControls(
                    session: session,
                    theme: theme,
                    isUploading: isUploading,
                    isOnline: network.isConnected,
                    hasSavedLocally: hasSavedLocally, // Direct access to the property
                    onRename: {
                        newSessionName = session.name
                        showingRenameSheet = true
                    },
                    onAdd: addExercise,
                    onSave: {
                        if !hasSavedLocally { handleLocalSave() }
                        else { handleCloudUpload() }
                    }
                )
                
            }
            .offset(x: dragOffset)
            .applyAppBranding()
            
            LeadingEdgeDragHandler(dragOffset: $dragOffset, onDismiss: { dismiss() })
        }
        .brandedBackButton(title: session.name, theme: theme.currentTheme, dismiss: dismiss)
        .sheet(isPresented: $showingRenameSheet) {
            RenameSheet(newName: $newSessionName, onRename: renameSession)
        }
    }

    // MARK: - Reordering Logic
    private func startCloudUpload() {
        guard network.isConnected else {
            showSyncError = true
            return
        }
        guard let userId = auth.user?.uid else {
            showSyncError = true
            return
        }
        
        isUploading = true
        
//        Task {
//            do {
//                // Pass the session/history object here
//                try await SyncManager.shared.uploadWholeSession(from: session, userId: userId)
//                
//                await MainActor.run {
//                    isUploading = false
//                    // Haptic feedback for successful cloud sync
//                    UINotificationFeedbackGenerator().notificationOccurred(.success)
//                    dismiss()
//                }
//            } catch {
//                await MainActor.run {
//                    isUploading = false
//                    showSyncError = true
//                }
//            }
//        }
    }
    
    private func handleLocalSave() {
        // 1. Process and save the workout history
        finishWorkoutSession()
        
        // 2. Reset the exercises so the session is fresh for next time
        for exercise in session.exercises {
            exercise.isCompleted = false
        }
        completedExerciseIds.removeAll()
        try? context.save()
        
        // 3. Trigger haptic feedback for success
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            hasSavedLocally = true
        }
    }

    private func handleCloudUpload() {
        // Look at the network monitor directly instead of a local 'isOnline' state
        guard network.isConnected else { return }
        
        isUploading = true
        
        // Your existing cloud upload logic
        uploadWholeSessionToCloud()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isUploading = false
            dismiss()
        }
    }
    
    private func updateAIWithLiveSessionData() {
        let details = generateSessionContext()
        
        aiManager.updateContext(
            screen: "Active Session \(session.name)",
            details: "User is vieting their full workout session list",
            preferences: details
        )
    }
    
    private func uploadWholeSessionToCloud() {
        guard let userId = auth.user?.uid else { return }
        
        // We use the SyncManager to handle the heavy lifting
        // This ensures consistency across the app
//        SyncManager.shared.uploadAllToCloud(userId: userId, keyScope: keyScope)
        
        // Optional: Trigger Haptic feedback or a toast notification
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Add this computed property to SessionDetailView to match StrengthEntryView logic
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(previewUserID: auth.previewUserID, liveUserID: auth.user?.uid)
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
    
    private func deleteExercise(withId id: UUID) {
        // Find the specific instance by its unique ID
        if let index = session.exercises.firstIndex(where: { $0.id == id }) {
            let exerciseName = session.exercises[index].name
            
            withAnimation {
                session.exercises.remove(at: index)
                
                // Cleanup per-set keys
                // Note: Since name is used for keys, this cleans up the "Bench Press" defaults.
                // (If you want separate data for duplicate exercises, use .id in the key instead of .name)
                let baseKeys = ["weight", "left", "right", "reps", "rest", "iso"]
                for i in 0..<20 {
                    for base in baseKeys {
                        defaults.removeObject(forKey: keyScope.scoped("\(base)\(exerciseName)_set\(i)"))
                    }
                }
                defaults.removeObject(forKey: keyScope.scoped("sets\(exerciseName)"))
                defaults.removeObject(forKey: keyScope.scoped("note\(exerciseName)"))

                try? context.save()
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
    
    private func finishWorkoutSession() {
        // 1. Get User ID (handle both Firebase and Preview states)
        let userId = auth.user?.uid ?? auth.previewUserID ?? "guest_id"
        let sessionDate = Date()
        
        // 2. Create the Master Record
        let completedSession = CompletedSession(
            date: sessionDate,
            userId: userId,
            programTitle: workoutProgram.title,
            sessionName: session.name
        )
        
        // 3. Loop through your live session exercises
        for exercise in session.exercises {
            // Fetch the set count you've saved in UserDefaults
            let setCount = defaults.integer(forKey: keyScope.scoped("sets\(exercise.name)"))
            guard setCount > 0 else { continue }
            
            var setRecords: [SetRecord] = []
            
            for i in 0..<setCount {
                let reps = defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(i)"))
                
                // Only save the set if there is actual data
                if reps > 0 {
                    let combined = defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(i)"))
                    let left = defaults.integer(forKey: keyScope.scoped("left\(exercise.name)_set\(i)"))
                    let right = defaults.integer(forKey: keyScope.scoped("right\(exercise.name)_set\(i)"))
                    let rest = defaults.integer(forKey: keyScope.scoped("rest\(exercise.name)_set\(i)"))
                    
                    let record = SetRecord(
                        id: UUID(),
                        combined: combined,
                        left: left,
                        right: right,
                        reps: reps,
                        rest: rest
                    )
                    setRecords.append(record)
                }
            }
            
            // 4. Create the StrengthEntry (Your old 'WorkoutHistory' style detail)
            if !setRecords.isEmpty {
                let note = defaults.string(forKey: keyScope.scoped("note\(exercise.name)"))
                let entry = StrengthEntry(
                    exercise: exercise.name,
                    date: sessionDate,
                    sets: setRecords,
                    note: note
                )
                
                // Link it to the main session
                entry.session = completedSession
                completedSession.strengthEntries.append(entry)
            }
        }
        
        // 5. Save to SwiftData
        if !completedSession.strengthEntries.isEmpty {
            context.insert(completedSession)
            
            do {
                try context.save()
                print("Successfully logged: \(session.name)")
            } catch {
                print("Save Error: \(error)")
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
    SessionDetailView(session: session, workoutProgram: workoutProgram, exercises: exercises)
}

