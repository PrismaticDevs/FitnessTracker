//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct StrengthEntryView: View {
    // These are environment objects/properties that don't need to be in the initializer
    var defaults = UserDefaults.standard // Use directly, no @State or init arg
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) private var aiManager
    @EnvironmentObject var auth: AuthManager
    
    // Properties that MUST be passed from the parent
    var workoutProgram: WorkoutProgram
    var session: Session
    @Binding var isCompleted: Bool
    var exercise: Exercise // Now a simple var, initialized by parent
    var allExercises: [Exercise]
    var deleteExercise: () -> Void // Changed to no-argument closure

    // Explicit Initializer
    init(workoutProgram: WorkoutProgram, session: Session, isCompleted: Binding<Bool>, exercise: Exercise, allExercises: [Exercise], deleteExercise: @escaping () -> Void) {
        self.workoutProgram = workoutProgram
        self.session = session
        self._isCompleted = isCompleted
        self.exercise = exercise
        self.allExercises = allExercises
        self.deleteExercise = deleteExercise
    }

    // Computed property for keyScope
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(
            previewUserID: auth.previewUserID,
            liveUserID: auth.user?.uid,
            programID: workoutProgram.id.uuidString,
            sessionID: session.id.uuidString
        )
    }
    
    // Internal @State properties, initialized to defaults or loaded on appear
    // These no longer need to be passed as arguments in the initializer from the parent view.
    @State private var id: UUID = UUID() 
    @State private var combined: Int = 0
    @State private var left: Int = 0 // Renamed from 'var' to 'left'
    @State private var right: Int = 0
    @State private var reps: Int = 0
    @State private var rest: Int = 0
    @State private var note: String = "" 
    @State private var iso: Bool = false 
    
    @State private var setsCountInput: String = "1"
    @State private var sets: Int = 1 
    @State private var combinedInputs: [String] = [""] 
    @State private var leftInputs: [String] = [""]
    @State private var rightInputs: [String] = [""]
    @State private var repsInputs: [String] = [""]
    @State private var restInputs: [String] = [""]
    @State private var selectedSetIndex: Int = 0
    
    @State private var itemToDelete: StrengthEntry?
    @State private var showConfirmationDialogue = false
    @State private var showHistory: Bool = false
    @State private var showDeleteConfirmation = false // Passed to NoteAndDeleteView
    @State private var emptyEntry: Bool = true

    @FocusState private var isFocused: Bool?
    
    // No explicit init needed, SwiftUI will synthesize one for the `var` properties.
    
    var body: some View {

        VStack(spacing: 16) {
            Section {
                VStack {
                    WorkoutHeaderView(
                        exercise: exercise,
                        isCompleted: $isCompleted,
                        setsCountInput: $setsCountInput,
                        selectedSetIndex: $selectedSetIndex,
                        adjustPerSetArrays: { n in adjustPerSetArrays(to: n) },
                        keyScope: keyScope,
                        isFocused: $isFocused
                    )
                    Group {
                        SetSelectorView(setsCount: max(1, int(from: setsCountInput)), selectedSetIndex: $selectedSetIndex) {
                            autofillValues()
                        }
                        SetDetailInputsView(
                            exercise: exercise.name,
                            selectedSetIndex: $selectedSetIndex,
                            iso: $iso,
                            leftInputs: $leftInputs,
                            rightInputs: $rightInputs,
                            combinedInputs: $combinedInputs,
                            repsInputs: $repsInputs,
                            restInputs: $restInputs,
                            keyScope: keyScope,
                            isFocused: $isFocused
                        )
                        NoteAndDeleteView(
                            exercise: exercise.name,
                            note: $note,
                            showDeleteConfirmation: $showDeleteConfirmation, // Passed here
                            keyScope: keyScope,
                            isFocused: $isFocused,
                            deleteExercise: deleteExercise // Now expects no argument
                        )
                    }
                    .opacity((isCompleted ? 0.5 : 1.0))
                    .disabled(isCompleted)
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isCompleted ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1)
                )
            }
            .listRowInsets(EdgeInsets())
            HStack {
                Spacer()
                Text(showHistory ? "Hide History" : "View History")
                Button {
                    showHistory.toggle()
                } label: {
                    Image(systemName: showHistory ? "eye.slash" : "eye")
                }
                .buttonStyle(.plain)
                Spacer()
            }
            
            if showHistory {
                StrengthHistoryListView(exerciseName: exercise.name) 
            }
        }
        .background(.clear)
        .padding(.horizontal, 5)
        .cornerRadius(15)
        .onTapGesture {
            isFocused = nil
        }
        .background(
            Color.black.opacity(0.001) 
                .onTapGesture {
                    isFocused = nil
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DataSynced"))) { _ in
            loadExerciseDataFromUserDefaults()
        }
        .onAppear {
            loadExerciseDataFromUserDefaults() // Load initial data
            aiManager.updateContext(
                screen: "Strength Entry",
                details: "User is logging \(exercise.name)",
                preferences: generateAIContext()
            )
        }
        .onChange(of: selectedSetIndex) {
            aiManager.updateContext(
                screen: "Strength Entry",
                details: "User viewing set \(selectedSetIndex + 1)",
                preferences: generateAIContext()
            )
        }
        // This is the alert for StrengthEntryView's context
        // It relies on NoteAndDeleteView setting showDeleteConfirmation to true
        .alert("Delete Exercise", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                // The deleteExercise closure is called from here
                deleteExercise() // No argument needed, parent will identify
            }
            Button("Cancel", role: .cancel) {
                // Reset state if cancelled
                showDeleteConfirmation = false
            }
        } message: {
            Text("Are you sure you want to remove \(exercise.name) from this session?")
        }
    }
    
    // MARK: - Data Loading and Saving
    
    private func loadExerciseDataFromUserDefaults() {
        let cleanName = exercise.name
        
        // Load Sets Count
        let loadedSetsCount = defaults.integer(forKey: keyScope.scoped("sets\(cleanName)"))
        if loadedSetsCount > 0 {
            setsCountInput = "\(loadedSetsCount)"
            sets = loadedSetsCount
        } else {
            setsCountInput = "1"
            sets = 1
        }
        
        // Ensure arrays are sized correctly
        adjustPerSetArrays(to: sets)
        
        // Load note and iso
        note = defaults.string(forKey: keyScope.scoped("note\(cleanName)")) ?? ""
        iso = defaults.bool(forKey: keyScope.scoped("iso\(cleanName)"))
        
        // Load per-set data for all sets
        for i in 0..<sets {
            combinedInputs[i] = "\(defaults.integer(forKey: keyScope.scoped("weight\(cleanName)_set\(i)")))"
            leftInputs[i] = "\(defaults.integer(forKey: keyScope.scoped("left\(cleanName)_set\(i)")))"
            rightInputs[i] = "\(defaults.integer(forKey: keyScope.scoped("right\(cleanName)_set\(i)")))"
            repsInputs[i] = "\(defaults.integer(forKey: keyScope.scoped("reps\(cleanName)_set\(i)")))"
            restInputs[i] = "\(defaults.integer(forKey: keyScope.scoped("rest\(cleanName)_set\(i)")))"
        }
        
        // Autofill current set if needed (this will update based on selectedSetIndex)
        if selectedSetIndex < sets {
            autofillValues()
        }
    }
    
    // MARK: - Helpers

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    private func exercisePreferencesPayload(userId: String) -> [String: Any] {
        let n = max(1, int(from: setsCountInput))
        var setsArray: [[String: Any]] = []

        for idx in 0..<n {
            let isIso = defaults.bool(forKey: keyScope.scoped("iso\(exercise.name)_set\(idx)"))
            let combined = defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(idx)"))
            let left = defaults.integer(forKey: keyScope.scoped("left\(exercise.name)_set\(idx)"))
            let right = defaults.integer(forKey: keyScope.scoped("right\(exercise.name)_set\(idx)"))
            let reps = defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(idx)"))
            let rest = defaults.integer(forKey: keyScope.scoped("rest\(exercise.name)_set\(idx)"))

            var setDict: [String: Any] = [
                "index": idx,
                "iso": isIso,
                "reps": reps,
                "rest": rest
            ]
            if isIso {
                setDict["left"] = left
                setDict["right"] = right
            } else {
                setDict["combined"] = combined
            }
            setsArray.append(setDict)
        }

        let noteValue = defaults.string(forKey: keyScope.scoped("note\(exercise.name)")) ?? "" // Corrected exercise to exercise.name

        return [
            "exercise": exercise.name, // Use exercise.name here, not the Exercise object
            "setsCount": n,
            "sets": setsArray,
            "note": noteValue,
            "updatedAt": Date().timeIntervalSince1970
        ]
    }

    private func uploadExercisePreferencesToCloud() {
        guard let userId = auth.user?.uid else { return }
        let db = Firestore.firestore()
        
        let n = max(1, int(from: setsCountInput))
        var setPrefs: [SetPreference] = []
        
        for idx in 0..<n {
            let isIso = defaults.bool(forKey: keyScope.scoped("iso\(exercise.name)_set\(idx)"))
            setPrefs.append(SetPreference(
                index: idx,
                iso: isIso,
                reps: defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(idx)")),
                rest: defaults.integer(forKey: keyScope.scoped("rest\(exercise.name)_set\(idx)")),
                weightCombined: isIso ? nil : defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(idx)")),
                weightLeft: isIso ? defaults.integer(forKey: keyScope.scoped("left\(exercise.name)_set\(idx)")) : nil,
                weightRight: isIso ? defaults.integer(forKey: keyScope.scoped("right\(exercise.name)_set\(idx)")) : nil
            ))
        }
        
        let preference = ExercisePreference(
            exerciseName: exercise.name,
            setsCount: n,
            note: note,
            sets: setPrefs,
            updatedAt: Date() // Captures current upload time
        )
        
        do {
            try db.collection("users")
                .document(userId)
                .collection("exercise_preferences")
                .document(exercise.name)
                .setData(from: preference)
        } catch {
            print("Error encoding preferences: \(error)")
        }
    }
    
    private func generateFullSessionAIContext(allExercisesInSession: [Exercise]) -> String {
        var fullContext = "--- FULL CURRENT SESSION ---\n"
        
        for ex in allExercisesInSession {
            let isCurrent = ex.id == exercise.id ? "[CURRENTLY VIEWING] " : ""
            let sets = defaults.integer(forKey: keyScope.scoped("sets\(ex.name)")) 
            let isDone = defaults.bool(forKey: keyScope.scoped("isCompleted\(ex.name)")) 
            
            fullContext += "\(isCurrent)Exercise: \(ex.name) | Sets: \(sets) | Status: \(isDone ? "Done" : "In Progress")\n"
            
            for idx in 0..<max(1, sets) {
                let reps = defaults.integer(forKey: keyScope.scoped("reps\(ex.name)_set\(idx)"))
                let weight = defaults.integer(forKey: keyScope.scoped("weight\(ex.name)_set\(idx)"))
                if reps > 0 || weight > 0 {
                    fullContext += "  - Set \(idx + 1): \(weight)lbs x \(reps) reps\n"
                }
            }
            fullContext += "\n"
        }
        
        return fullContext
    }
    
    private func updateAi() {
        let sessionSummary = generateFullSessionAIContext(allExercisesInSession:  allExercises  )
        
        aiManager.updateContext(
            screen: "Strength Entry",
            details: "User is currently looiking at \(exercise.name)",
            preferences: sessionSummary
        )
    }
    
    private func scopedKey(_ base: String) -> String {
        keyScope.scoped(base)
    }
    
    private func lastNonZero(for baseKey: String, upTo index: Int) -> Int {
        if index >= 0 {
            for i in stride(from: index, through: 0, by: -1) {
                let v = defaults.integer(forKey: scopedKey("\(baseKey)_set\(i)"))
                if v != 0 { return v }
            }
        }
        return 0
    }
    
    private func int(from s: String) -> Int {
        Int(s.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
    }
    
    private func adjustPerSetArrays(to count: Int) {
        let c = max(1, count)
        let needed = c - combinedInputs.count
        if needed > 0 {
            combinedInputs.append(contentsOf: Array(repeating: "", count: needed))
            leftInputs.append(contentsOf: Array(repeating: "", count: needed))
            rightInputs.append(contentsOf: Array(repeating: "", count: needed))
            repsInputs.append(contentsOf: Array(repeating: "", count: needed))
            restInputs.append(contentsOf: Array(repeating: "", count: needed))
        } else if combinedInputs.count > c {
            combinedInputs = Array(combinedInputs.prefix(c))
            leftInputs = Array(leftInputs.prefix(c))
            rightInputs = Array(rightInputs.prefix(c))
            repsInputs = Array(repsInputs.prefix(c))
            restInputs = Array(restInputs.prefix(c))
        }
    }
    
    private func binding(for array: Binding<[String]>, index: Int) -> Binding<String> {
        Binding(
            get: {
                let a = array.wrappedValue
                return a.indices.contains(index) ? a[index] : ""
            },
            set: { newValue in
                var a = array.wrappedValue
                if a.indices.contains(index) { a[index] = newValue }
                else if index == a.count { a.append(newValue) }
                array.wrappedValue = a
            }
        )
    }
    
    private func makeSetRecords() -> [SetRecord] {
        let count = max(1, int(from: setsCountInput))
        func val(_ arr: [String], _ idx: Int) -> Int {
            guard arr.indices.contains(idx) else { return 0 }
            return Int(arr[idx].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        }
        
        return (0..<count).map { i in
            SetRecord(
                id: UUID(),
                combined: val(combinedInputs, i),
                left:     val(leftInputs, i),
                right:    val(rightInputs, i),
                reps:     val(repsInputs, i),
                rest:     val(restInputs, i)
            )
        }
    }
    
    private func autofillValues() {
        let cleanName = exercise.name
        
        // This function now primarily populates the text field strings for the CURRENTLY selected set
        // by reading from UserDefaults, after the initial full load in onAppear.
        combinedInputs[selectedSetIndex] = "\(defaults.integer(forKey: keyScope.scoped("weight\(cleanName)_set\(selectedSetIndex)")))"
        leftInputs[selectedSetIndex] = "\(defaults.integer(forKey: keyScope.scoped("left\(cleanName)_set\(selectedSetIndex)")))"
        rightInputs[selectedSetIndex] = "\(defaults.integer(forKey: keyScope.scoped("right\(cleanName)_set\(selectedSetIndex)")))"
        repsInputs[selectedSetIndex] = "\(defaults.integer(forKey: keyScope.scoped("reps\(cleanName)_set\(selectedSetIndex)")))"
        restInputs[selectedSetIndex] = "\(defaults.integer(forKey: keyScope.scoped("rest\(cleanName)_set\(selectedSetIndex)")))"
    }
    
    private func generateAIContext() -> String {
        let n = max(1, int(from: setsCountInput))
        var contextString = "Current exercise: \(exercise.name). Planned sets: \(n).\n"
        
        for idx in 0..<n {
            let isIso = defaults.bool(forKey: keyScope.scoped("iso\(exercise.name)_set\(idx)"))
            let reps = defaults.integer(forKey: keyScope.scoped("reps\(exercise.name)_set\(idx)"))
            let rest = defaults.integer(forKey: keyScope.scoped("rest\(exercise.name)_set\(idx)"))
            
            contextString += "Set \(idx + 1): \(reps) reps, \(rest)s rest. "
            
            if isIso {
                let left = defaults.integer(forKey: keyScope.scoped("left\(exercise.name)_set\(idx)"))
                let right = defaults.integer(forKey: keyScope.scoped("right\(exercise.name)_set\(idx)"))
                contextString += "Weights: Left \(left), Right \(right).\n"
            } else {
                let combined = defaults.integer(forKey: keyScope.scoped("weight\(exercise.name)_set\(idx)"))
                contextString += "Combined Weight: \(combined).\n"
            }
        }
        
        let noteValue = defaults.string(forKey: keyScope.scoped("note\(exercise.name)")) ?? ""
        if !noteValue.isEmpty {
            contextString += "User Note: \(noteValue)"
        }
        
        return contextString
    }
    
}

final class MockAuthManager: AuthManager {
    override init() {
        super.init()
        self.previewUserID = "preview_user"
    }
}

// MARK: - Preview

#Preview {
    let mockAuthManager = AuthManager()
    let previewExercise = Exercise(name: "Preview Exercise")
    
    let mockProgram = WorkoutProgram(title: "Preview Program", sessions: [])
    let mockSession = Session(name: "Preview Session", exercises: [previewExercise])
    
    StrengthEntryView(
        workoutProgram: mockProgram,
        session: mockSession,
        isCompleted: .constant(false),
        exercise: previewExercise,
        allExercises: [previewExercise],
        deleteExercise: { } // Updated closure to no arguments
    )
    .environmentObject(mockAuthManager)
    .environment(AIContextManager())
}

