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
    
    // Save & Upload State
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

    // MARK: - Save Logic
        
        private func handleLocalSave() {
            finishWorkoutSession()
            
            // Reset the exercises for the next time the template is used
            for exercise in session.exercises {
                exercise.isCompleted = false
            }
            completedExerciseIds.removeAll()
            try? context.save()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation {
                hasSavedLocally = true
            }
        }

        private func handleCloudUpload() {
            guard network.isConnected, let userId = auth.user?.uid else {
                showSyncError = true
                return
            }
            
            isUploading = true
            
            Task {
                do {
                    // 1. Sync Blueprints (UserDefaults)
                    SyncManager.shared.uploadAllToCloud(userId: userId, keyScope: keyScope)
                    
                    // 2. Sync the most recent CompletedSession
                    let descriptor = FetchDescriptor<CompletedSession>(
                        sortBy: [SortDescriptor(\.date, order: .reverse)]
                    )
                    
                    if let lastSession = try context.fetch(descriptor).first {
                        try await SyncManager.shared.uploadCompletedSession(userId: userId, session: lastSession)
                    }
                    
                    isUploading = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                    
                } catch {
                    print("Sync failed: \(error)")
                    isUploading = false
                    showSyncError = true
                }
            }
        }
        
        private func finishWorkoutSession() {
            guard let userId = auth.user?.uid else { return }
            let sessionDate = Date()
            
            // 1. Create the new "Envelope"
            let completed = CompletedSession(
                date: sessionDate,
                programTitle: workoutProgram.title,
                sessionName: session.name
            )
            
            // 2. Map every exercise to StrengthEntry
            for exercise in session.exercises {
                let setsKey = keyScope.scoped("sets\(exercise.name)")
                let setCount = Int(defaults.string(forKey: setsKey) ?? "0") ?? 0
                
                guard setCount > 0 else { continue }
                
                var setRecords: [SetRecord] = []
                for i in 0..<setCount {
                    let reps = Int(defaults.string(forKey: keyScope.scoped("reps\(exercise.name)_set\(i)")) ?? "0") ?? 0
                    if reps > 0 {
                        let weight = Int(defaults.string(forKey: keyScope.scoped("weight\(exercise.name)_set\(i)")) ?? "0") ?? 0
                        let left = Int(defaults.string(forKey: keyScope.scoped("left\(exercise.name)_set\(i)")) ?? "0") ?? 0
                        let right = Int(defaults.string(forKey: keyScope.scoped("right\(exercise.name)_set\(i)")) ?? "0") ?? 0
                        let rest = Int(defaults.string(forKey: keyScope.scoped("rest\(exercise.name)_set\(i)")) ?? "0") ?? 0
                        
                        setRecords.append(SetRecord(id: UUID(), combined: weight, left: left, right: right, reps: reps, rest: rest))
                    }
                }
                
                if !setRecords.isEmpty {
                    let entry = StrengthEntry(
                        exercise: exercise.name,
                        date: sessionDate,
                        sets: setRecords,
                        note: defaults.string(forKey: keyScope.scoped("note\(exercise.name)")),
                        programTitle: workoutProgram.title
                    )
                    completed.strengthEntries.append(entry)
                }
            }
            
            // 3. Persist individual session to SwiftData
            if !completed.strengthEntries.isEmpty {
                context.insert(completed)
                do {
                    try context.save()
                    print("✅ Successfully saved CompletedSession: \(session.name)")
                } catch {
                    print("❌ SwiftData Save Error: \(error.localizedDescription)")
                }
            }
        }

        // MARK: - Utilities
        private var keyScope: DefaultsKeyScope {
            DefaultsKeyScope.from(previewUserID: auth.previewUserID, liveUserID: auth.user?.uid)
        }

        private func deleteExercise(withId id: UUID) {
            if let index = session.exercises.firstIndex(where: { $0.id == id }) {
                let exerciseName = session.exercises[index].name
                withAnimation {
                    session.exercises.remove(at: index)
                    // Cleanup logic here...
                    try? context.save()
                }
            }
        }

        private func renameSession() {
            session.name = newSessionName
            try? context.save()
        }

        private func addExercise(named exerciseName: String) {
            let newExercise = Exercise(name: exerciseName)
            session.exercises.append(newExercise)
            try? context.save()
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

