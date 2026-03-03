//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct StrengthEntryView: View {
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) private var aiManager
    @EnvironmentObject var auth: AuthManager
//    @StateObject private var sync = SyncManager.shared
    private var keyScope: DefaultsKeyScope { DefaultsKeyScope.from(previewUserID: auth.previewUserID, liveUserID: auth.user?.uid) }
    
    @Binding var isCompleted: Bool
    
    @State var id: UUID = UUID()
    @State var exercise: Exercise
    @State var combined: Int = 0
    @State var left: Int = 0
    @State var right: Int = 0
    
    @State private var setsCountInput: String = "1"
    @State private var sets: Int = 1
    @State private var combinedInputs: [String] = [""]
    @State private var leftInputs: [String] = [""]
    @State private var rightInputs: [String] = [""]
    @State private var repsInputs: [String] = [""]
    @State private var restInputs: [String] = [""]
    @State private var selectedSetIndex: Int = 0
    
    @State var reps: Int = 0
    @State var rest: Int = 0
    @State var note: String = ""
    @State var date: Date = Date()
    @State var iso: Bool = false
    @State var itemToDelete: StrengthEntry?
    @State var showConfirmationDialogue = false
    @State var showHistory: Bool = false
    @State private var showEmptyEntryAlert = false
    @State private var combinedInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""
    @State private var showDeleteConfirmation = false
    @State var emptyEntry: Bool = true
    
    @State var allExercises: [Exercise]
    
    @FocusState private var isFocused: Bool?
    
    var deleteExercise: (String) -> Void

    
    
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
                            showDeleteConfirmation: $showDeleteConfirmation,
                            keyScope: keyScope,
                            isFocused: $isFocused,
                            deleteExercise: deleteExercise
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
            Color.black.opacity(0.001) // Invisible but tappable
                .onTapGesture {
                    isFocused = nil
                }
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DataSynced"))) { _ in
            // This forces the view to reload its local @State arrays from the now-updated UserDefaults
            autofillValues()
        }
        .onAppear {
            if let userId = auth.user?.uid {
//                sync.fetchAllFromCloud(userId: userId, keyScope: keyScope)
            }
            // Set initial context
            aiManager.updateContext(
                screen: "Strength Entry",
                details: "User is logging \(exercise.name)",
                preferences: generateAIContext()
            )
        }
        .onChange(of: selectedSetIndex) {
            // Update context whenever they switch sets so the AI knows which set is being viewed
            aiManager.updateContext(
                screen: "Strength Entry",
                details: "User viewing set \(selectedSetIndex + 1)",
                preferences: generateAIContext()
            )
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

        let noteValue = defaults.string(forKey: keyScope.scoped("note\(exercise)")) ?? ""

        return [
            "exercise": exercise,
            "setsCount": n,
            "sets": setsArray,
            "note": noteValue,
            "updatedAt": Date().timeIntervalSince1970
        ]
    }

    private func uploadExercisePreferencesToCloud() {
        guard let userId = auth.user?.uid else { return }
        let db = Firestore.firestore()
        
        // 1. Gather the data into our Codable struct
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
        
        // 2. Upload to a dedicated document per exercise
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
            let sets = defaults.integer(forKey: keyScope.scoped("setsCount\(ex.name)"))
            let isDone = defaults.bool(forKey: keyScope.scoped("isCompleted\(ex.name)")) // If you persist completion
            
            fullContext += "\(isCurrent)Exercise: \(ex.name) | Sets: \(sets) | Status: \(isDone ? "Done" : "In Progress")\n"
            
            // Brief detail for each set of EVERY exercise in the session
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
        // Walk backwards from index to 0 to find last non-zero value for this per-set key
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
        // Check and autofill leftInput
        if leftInputs[selectedSetIndex].isEmpty {
            leftInputs[selectedSetIndex] = "\(lastNonZero(for: "left\(exercise.name)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill rightInput
        if rightInputs[selectedSetIndex].isEmpty {
            rightInputs[selectedSetIndex] = "\(lastNonZero(for: "right\(exercise.name)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill combinedInput
        if combinedInputs[selectedSetIndex].isEmpty {
            combinedInputs[selectedSetIndex] = "\(lastNonZero(for: "weight\(exercise.name)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill repsInput
        if repsInputs[selectedSetIndex].isEmpty {
            repsInputs[selectedSetIndex] = "\(lastNonZero(for: "reps\(exercise.name)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill restInput
        if restInputs[selectedSetIndex].isEmpty {
            restInputs[selectedSetIndex] = "\(lastNonZero(for: "rest\(exercise.name)", upTo: selectedSetIndex))"
        }
    }
    
    // Add this inside StrengthEntryView
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
    let mockAuthManager = AuthManager() // Use your actual or mock manager
    let previewExercise = Exercise(name: "Preview Exercise")
    
    // Create the view
    StrengthEntryView(
        isCompleted: .constant(false),
        exercise: previewExercise,
        combined: 0,
        left: 0,
        right: 0,
        reps: 0,
        rest: 0,
        note: "",
        // FIX: Wrap previewExercise in brackets to make it an array [Exercise]
        allExercises: [previewExercise],
        deleteExercise: { _ in }
    )
    .environmentObject(mockAuthManager)
    // Adding the AI Manager since your view uses @Environment(AIContextManager.self)
    .environment(AIContextManager())
//    .modelContainer(for: [WorkoutHistory.self, StrengthEntry.self], inMemory: true)
}
