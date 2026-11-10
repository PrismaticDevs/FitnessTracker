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
                    keyScope: keyScope,
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
                    onAdd: { addExercise($0) },
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
        guard auth.user?.uid != nil else {
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
        guard auth.user?.uid != nil else { return }
        
        // We use the SyncManager to handle the heavy lifting
        // This ensures consistency across the app
//        SyncManager.shared.uploadAllToCloud(userId: userId, keyScope: keyScope)
        
        // Optional: Trigger Haptic feedback or a toast notification
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Add this computed property to SessionDetailView to match StrengthEntryView logic
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(
            previewUserID: auth.previewUserID,
            liveUserID: auth.user?.uid,
            programID: workoutProgram.id.uuidString,
            sessionID: session.id.uuidString
        )
    }
    
    private func addExercise(_ template: Exercise) {
        let newExercise = Exercise(name: template.name, type: template.type ?? .strength)
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
            let sets = defaults.integer(forKey: keyScope.scoped("setsCount\(exercise.name)"))
            let note = defaults.string(forKey: keyScope.scoped("note\(exercise.name)")) ?? "No notes"

            contextString += "- Configured Sets: \(sets)\n"

            for i in 0..<max(1, sets) {
                let weight = defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(i)"))
                let reps = defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(i)"))
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

        print("🏋️ finishWorkoutSession — program: '\(workoutProgram.title)', session: '\(session.name)'")
        print("🔑 keyScope: user=\(keyScope.userID) program=\(keyScope.programID ?? "nil") session=\(keyScope.sessionID ?? "nil")")
        print("📋 exercises in session: \(session.exercises.map { $0.name })")

        // 2. Create the Master Record
        let completedSession = CompletedSession(
            date: sessionDate,
            userId: userId,
            programTitle: workoutProgram.title,
            sessionName: session.name
        )

        // 3. Loop through your live session exercises
        for exercise in session.exercises {
            let cleanName = exercise.name

            let fullScopeKey = keyScope.scoped("setsCount\(cleanName)")
            let legacyKey    = keyScope.legacyScoped("setsCount\(cleanName)")
            var setCount = defaults.integer(forKey: fullScopeKey)
            print("  📌 [\(cleanName)] setsCount fullScope '\(fullScopeKey)' = \(setCount)")
            if setCount == 0 {
                setCount = defaults.integer(forKey: legacyKey)
                print("  📌 [\(cleanName)] setsCount legacyScope '\(legacyKey)' = \(setCount)")
            }

            guard setCount > 0 else {
                print("  ⚠️ [\(cleanName)] setCount=0, skipping")
                continue
            }

            let isIsoSession = defaults.bool(forKey: keyScope.scoped("iso\(cleanName)"))

            var setRecords: [SetRecord] = []

            func intVal(_ key: String) -> Int {
                if let s = defaults.string(forKey: key), let n = Int(s) { return n }
                return defaults.integer(forKey: key)
            }

            // Track the last set that had any real data so we can forward-fill.
            // This handles the common case where the user sets e.g. Total Sets=3
            // and enters data only on Set 1 — the other sets inherit those values.
            var lastNonZeroRecord: (reps: Int, combined: Int, left: Int, right: Int, rest: Int)?

            for i in 0..<setCount {
                let repsKey     = keyScope.scoped("reps\(cleanName)_set\(i)")
                let weightKey   = keyScope.scoped("weight\(cleanName)_set\(i)")
                var reps     = intVal(repsKey)
                var combined = intVal(weightKey)
                var left     = intVal(keyScope.scoped("left\(cleanName)_set\(i)"))
                var right    = intVal(keyScope.scoped("right\(cleanName)_set\(i)"))
                var rest     = intVal(keyScope.scoped("rest\(cleanName)_set\(i)"))

                print("    set\(i): reps=\(reps) weight=\(combined) left=\(left) right=\(right) rest=\(rest) | repsKey='\(repsKey)'")

                // If this set has no data at all, forward-fill from the last set that did
                if reps == 0 && combined == 0 && left == 0 && right == 0, let fill = lastNonZeroRecord {
                    reps = fill.reps; combined = fill.combined
                    left = fill.left; right = fill.right; rest = fill.rest
                    print("    ↩️ set\(i) forward-filled from previous set: reps=\(reps) weight=\(combined)")
                }

                if reps > 0 || combined > 0 || left > 0 || right > 0 {
                    lastNonZeroRecord = (reps, combined, left, right, rest)
                    setRecords.append(SetRecord(
                        id: UUID(),
                        combined: combined,
                        left: left,
                        right: right,
                        reps: reps,
                        rest: rest
                    ))
                } else {
                    print("    ⚠️ set\(i) has all-zero values, skipping")
                }
            }

            // 4. Create the StrengthEntry
            if !setRecords.isEmpty {
                let note = defaults.string(forKey: keyScope.scoped("note\(cleanName)"))
                let entry = StrengthEntry(
                    exercise: exercise.name,
                    date: sessionDate,
                    sets: setRecords,
                    note: note,
                    iso: isIsoSession
                )
                entry.session = completedSession
                completedSession.strengthEntries.append(entry)
                print("  ✅ [\(cleanName)] added \(setRecords.count) set(s) to completedSession")
            } else {
                print("  ⚠️ [\(cleanName)] no valid sets to save")
            }
        }

        // 4b. Cardio and mobility entries
        for exercise in session.exercises {
            let cleanName = exercise.name

            func strVal(_ key: String) -> String {
                defaults.string(forKey: keyScope.scoped(key)) ?? ""
            }
            func dblVal(_ key: String) -> Double {
                Double(strVal(key)) ?? 0
            }
            func intVal2(_ key: String) -> Int {
                Int(strVal(key)) ?? defaults.integer(forKey: keyScope.scoped(key))
            }

            switch exercise.type {
            case .cardio:
                let durationMins = dblVal("cardioDuration\(cleanName)")
                guard durationMins > 0 else {
                    print("  ⚠️ cardio [\(cleanName)] no duration, skipping")
                    continue
                }
                let entry = CardioEntry(
                    exercise: cleanName,
                    date: sessionDate,
                    duration: durationMins * 60,
                    distance: dblVal("cardioDistance\(cleanName)") > 0 ? dblVal("cardioDistance\(cleanName)") : nil,
                    calories: intVal2("cardioCalories\(cleanName)") > 0 ? intVal2("cardioCalories\(cleanName)") : nil,
                    note: strVal("cardioNote\(cleanName)").isEmpty ? nil : strVal("cardioNote\(cleanName)")
                )
                entry.session = completedSession
                completedSession.cardioEntries.append(entry)
                print("  ✅ cardio [\(cleanName)] duration=\(durationMins)min")

            case .mobility:
                let holdSecs = dblVal("mobilityHold\(cleanName)")
                let roundsVal = intVal2("mobilityRounds\(cleanName)")
                guard holdSecs > 0 || roundsVal > 0 else {
                    print("  ⚠️ mobility [\(cleanName)] no data, skipping")
                    continue
                }
                let entry = MobilityEntry(
                    exercise: cleanName,
                    date: sessionDate,
                    holdTime: holdSecs,
                    rounds: roundsVal,
                    note: strVal("mobilityNote\(cleanName)").isEmpty ? nil : strVal("mobilityNote\(cleanName)")
                )
                entry.session = completedSession
                completedSession.mobilityEntries.append(entry)
                print("  ✅ mobility [\(cleanName)] hold=\(holdSecs)s rounds=\(roundsVal)")

            default:
                break // strength already handled above
            }
        }

        // 5. Save to SwiftData
        print("💾 total strength entries: \(completedSession.strengthEntries.count)")
        let hasEntries = !completedSession.strengthEntries.isEmpty
                      || !completedSession.cardioEntries.isEmpty
                      || !completedSession.mobilityEntries.isEmpty
        if hasEntries {
            context.insert(completedSession)
            do {
                try context.save()
                print("✅ Successfully saved: \(session.name) — strength:\(completedSession.strengthEntries.count) cardio:\(completedSession.cardioEntries.count) mobility:\(completedSession.mobilityEntries.count)")
            } catch {
                print("❌ Save Error: \(error)")
            }
        } else {
            print("❌ Nothing to save — all entry arrays are empty")
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

