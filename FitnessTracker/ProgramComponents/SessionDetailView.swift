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
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) var aiManager
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showingAddExerciseView = false
    @State private var selectedExerciseName: String = ""
    @State private var showingRenameSheet = false
    @State private var newSessionName: String = ""
    @State private var dragOffset: CGFloat = 0
    
    // Save and Upload
    @State private var network = NetworkMonitor()
    @State private var hasSavedLocally = false
    @State private var isUploading = false
    @State private var isOnline = true
    @State private var showSyncError = false
    
    @State private var completedExerciseIds: Set<UUID> = []
    @State var exercises: [Exercise]


    var body: some View {
        ZStack(alignment: .top) {
            Color.clear.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 120)
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(session.exercises.sorted { lhs, rhs in lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending }) { exercise in
                                StrengthEntryView(
                                    isCompleted: Binding(
                                        get: { completedExerciseIds.contains(exercise.id) },
                                        set: { isDone in
                                            if isDone { completedExerciseIds.insert(exercise.id)}
                                            else { completedExerciseIds.remove(exercise.id)}
                                        }
                                    ),
                                    exercise: exercise,
                                    allExercises: session.exercises,
                                    deleteExercise: { name in deleteExercise(named: name) },
                                )
                            }
                        }
                        .padding(.horizontal)
                        Color.clear.frame(height: 1)
                    }
                    .clipped()
                    customFloatingBar
                }
                .offset(x: dragOffset)
                .animation(.interactiveSpring(), value: dragOffset)
                .padding(.horizontal, 12)
                .onAppear {
                    updateAIWithLiveSessionData()
                }
                .applyAppBranding()
                .sheet(isPresented: $showingRenameSheet) {
                    VStack {
                        Text("Rename Session")
                            .font(.headline)
                            .padding()
                        
                        TextField("New Session Name", text: $newSessionName, prompt: Text("New Session Name").foregroundColor(.white.opacity(0.5)))
                            .padding()
                            .background(theme.currentTheme.accent.opacity(0.8).cornerRadius(10))
                        
                        Button("Rename") {
                            renameSession()
                            showingRenameSheet = false // Dismiss the sheet
                        }
                        .padding()
                    }
                    .padding()
                }
            
            // Leading-edge swipe back hit area to avoid ScrollView conflicts
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    // Only respond to drags that start near the leading edge and move right
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
        }
        .brandedBackButton(title: "\(session.name) Exercises", theme: theme.currentTheme, dismiss: dismiss)
    }
    
    private var customFloatingBar: some View {
        HStack {
            Spacer()
            
            // Save/Finish Workout Button
            Button(action: {
                if !hasSavedLocally {
                    handleLocalSave()
                } else {
                    handleCloudUpload()
                }
            }) {
                VStack(spacing: 2) {
                    Image(systemName: isUploading ? "arrow.clockwise" : hasSavedLocally ? "icloud.arrow.up" : "square.and.arrow.down")
                        .font(.system(size: 20, weight: .bold))
                        .rotationEffect(.degrees(isUploading ? 360 : 0))
                        .animation(isUploading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isUploading)
                }
                .foregroundColor(completedExerciseIds.isEmpty ? .white.opacity(0.3) : .white)
            }
            .disabled(completedExerciseIds.isEmpty || (hasSavedLocally && isOnline))
            .opacity((hasSavedLocally && !network.isConnected) ? 0.5 : 1.0)
                
                Spacer()
                
                // Your existing Exercise Menu/Toolbar
                ExerciseToolbar(
                    title: "",
                    exerciseName: $selectedExerciseName,
                    exercisesSelected: session.exercises.map { $0.name },
                    onExerciseSelected: { exerciseName in
                        addExercise(named: exerciseName)
                    }
                )
                .foregroundColor(.white)
                
                Spacer()
                
                // Rename Session Button
                Button(action: {
                    newSessionName = session.name
                    showingRenameSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 50)
            .background(theme.currentTheme.accent)
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
            .alert("Upload Failed", isPresented: $showSyncError) {
                        Button("Retry") { startCloudUpload() }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("We couldn't reach the server. Please check your connection and try again.")
                    }
        }
    
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
        
        Task {
            do {
                // Pass the session/history object here
                try await SyncManager.shared.uploadWholeSession(from: session, userId: userId)
                
                await MainActor.run {
                    isUploading = false
                    // Haptic feedback for successful cloud sync
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    showSyncError = true
                }
            }
        }
    }
    
    private func handleLocalSave() {
        // 1. Run your existing SwiftData logic
        finishWorkoutSession()
        
        // 2. Trigger haptic feedback for success
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            hasSavedLocally = true
        }
    }

    private func handleCloudUpload() {
        guard isOnline else { return }
        
        isUploading = true
        
        // Use the function you already have
        uploadWholeSessionToCloud()
        
        // Simulate a slight delay for the spinner, then finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isUploading = false
            // Option A: Just stay here and show a checkmark
            // Option B: Dismiss the view
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
        SyncManager.shared.uploadAllToCloud(userId: userId, keyScope: keyScope)
        
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
    
    private func deleteExercise(named exerciseName: String) {
        if let index = session.exercises.firstIndex(where: { $0.name == exerciseName }) {
            session.exercises.remove(at: index)
            
            // Cleanup per-set keys (assuming a max of 20 sets for safety)
            for i in 0..<20 {
                let baseKeys = ["weight", "left", "right", "reps", "rest", "iso"]
                for base in baseKeys {
                    defaults.removeObject(forKey: keyScope.scoped("\(base)\(exerciseName)_set\(i)"))
                }
            }
            defaults.removeObject(forKey: keyScope.scoped("sets\(exerciseName)"))
            defaults.removeObject(forKey: keyScope.scoped("note\(exerciseName)"))

            // Save SwiftData context
            try? context.save()
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
        guard let userId = FBAuth.auth().currentUser?.uid else { return }
        let sessionDate = Date()
        
        // 1. Map every exercise in this session to a StrengthEntry
        let strengthEntries: [StrengthEntry] = session.exercises.compactMap { exercise in
            let setCount = defaults.integer(forKey: keyScope.scoped("sets\(exercise.name)"))
            guard setCount > 0 else { return nil } // Skip exercises with no sets
            
            var setRecords: [SetRecord] = []
            
            // Loop through the sets defined in UserDefaults
            for i in 0..<setCount {
                let combined = defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(i)"))
                let left = defaults.integer(forKey: keyScope.scoped("left\(exercise.name)_set\(i)"))
                let right = defaults.integer(forKey: keyScope.scoped("right\(exercise.name)_set\(i)"))
                let reps = defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(i)"))
                let rest = defaults.integer(forKey: keyScope.scoped("rest\(exercise.name)_set\(i)"))
                
                // Only add the set if there's actual work recorded
                if reps > 0 {
                    setRecords.append(SetRecord(id: UUID(), combined: combined, left: left, right: right, reps: reps, rest: rest))
                }
            }
            
            guard !setRecords.isEmpty else { return nil }
            
            let note = defaults.string(forKey: keyScope.scoped("note\(exercise.name)"))
            return StrengthEntry(exercise: exercise.name, date: sessionDate, sets: setRecords, note: note)
        }
        
        // 2. Wrap everything into ONE WorkoutHistory object
        if !strengthEntries.isEmpty {
            let history = WorkoutHistory(
                userId: userId,
                date: sessionDate,
                exercise: session.name, // The "Master Name" is the Session Name (e.g., "Push Day")
                entries: strengthEntries
            )
            
            context.insert(history)
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

