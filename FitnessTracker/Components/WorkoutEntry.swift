//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct WorkoutEntryView: View {
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    @EnvironmentObject var auth: AuthManager
    
    @State var id: UUID = UUID()
    @State var exercise: String
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
    @State var itemToDelete: WorkoutEntry?
    @State var showConfirmationDialogue = false
    @State var showHistory: Bool = false
    @State private var showSavedCheckmark = false
    @State private var showAllSavedCheckmark = false
    @State private var showEmptyEntryAlert = false
    @State private var combinedInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""
    @State private var showDeleteConfirmation = false
    @State var emptyEntry: Bool = true
    
    @FocusState private var isFocused: Bool?
    
    var onDelete: () -> Void

    // MARK: - Helpers

    private var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PLAYGROUNDS"] == "1"
    }

    private func exercisePreferencesPayload(userId: String) -> [String: Any] {
        let n = max(1, int(from: setsCountInput))
        var setsArray: [[String: Any]] = []

        for idx in 0..<n {
            let isIso = defaults.bool(forKey: scopedKey("iso\(exercise)_set\(idx)"))
            let combined = defaults.integer(forKey: scopedKey("weight\(exercise)_set\(idx)"))
            let left = defaults.integer(forKey: scopedKey("left\(exercise)_set\(idx)"))
            let right = defaults.integer(forKey: scopedKey("right\(exercise)_set\(idx)"))
            let reps = defaults.integer(forKey: scopedKey("reps\(exercise)_set\(idx)"))
            let rest = defaults.integer(forKey: scopedKey("rest\(exercise)_set\(idx)"))

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

        let noteValue = defaults.string(forKey: scopedKey("note\(exercise)")) ?? ""

        return [
            "exercise": exercise,
            "setsCount": n,
            "sets": setsArray,
            "note": noteValue,
            "updatedAt": Date().timeIntervalSince1970
        ]
    }

    private func uploadExercisePreferencesToCloud() {
        guard !isRunningInPreview else { return }
        guard let userId = auth.user?.uid else {
            print("No authenticated user; skipping cloud preferences upload")
            return
        }
        let payload = exercisePreferencesPayload(userId: userId)
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("settings")
            .document("preferences_exercises")
            .setData([exercise: payload], merge: true) { error in
                if let error = error {
                    print("Error uploading exercise preferences: \(error.localizedDescription)")
                } else {
                    print("Exercise preferences uploaded")
                }
            }
    }
    
    private func uploadAllExercisesPreferencesToCloud() {
        guard !isRunningInPreview else { return }
        guard let userId = auth.user?.uid else {
            print("No authenticated user; skipping cloud preferences upload (all)")
            return
        }
        // Discover all exercises for this session by scanning keys namespaced to this user
        // We will look for keys that match pattern: user_<uid>.note<ExerciseName>
        let prefix = "user_\(userId).note"
        let allKeys = defaults.dictionaryRepresentation().keys
        let exerciseNames: Set<String> = Set(
            allKeys.compactMap { key in
                guard key.hasPrefix(prefix) else { return nil }
                // strip user_<uid>.note and get exercise name suffix
                return String(key.dropFirst(prefix.count))
            }
            .filter { !$0.isEmpty }
        )

        // Build a combined payload [exercise: payload]
        var combined: [String: Any] = [:]
        for ex in exerciseNames {
            // Temporarily use current view's state to compute setsCount for each exercise
            // We will read sets count for that exercise from defaults
            let setsCount = max(1, defaults.integer(forKey: scopedKey("sets\(ex)")))
            var setsArray: [[String: Any]] = []
            for idx in 0..<setsCount {
                let isIso = defaults.bool(forKey: scopedKey("iso\(ex)_set\(idx)"))
                let combinedW = defaults.integer(forKey: scopedKey("weight\(ex)_set\(idx)"))
                let leftW = defaults.integer(forKey: scopedKey("left\(ex)_set\(idx)"))
                let rightW = defaults.integer(forKey: scopedKey("right\(ex)_set\(idx)"))
                let reps = defaults.integer(forKey: scopedKey("reps\(ex)_set\(idx)"))
                let rest = defaults.integer(forKey: scopedKey("rest\(ex)_set\(idx)"))
                var setDict: [String: Any] = [
                    "index": idx,
                    "iso": isIso,
                    "reps": reps,
                    "rest": rest
                ]
                if isIso {
                    setDict["left"] = leftW
                    setDict["right"] = rightW
                } else {
                    setDict["combined"] = combinedW
                }
                setsArray.append(setDict)
            }
            let noteValue = defaults.string(forKey: scopedKey("note\(ex)")) ?? ""
            let payload: [String: Any] = [
                "exercise": ex,
                "setsCount": setsCount,
                "sets": setsArray,
                "note": noteValue,
                "updatedAt": Date().timeIntervalSince1970
            ]
            combined[ex] = payload
        }

        let db = Firestore.firestore()
        db.collection("Users")
            .document(userId)
            .collection("WeightEntry")
            .document("ji6X7gqtCCH7zz21Y4qI")
            .setData(combined, merge: true) { error in
                if let error = error {
                    print("Error uploading ALL exercise preferences: \(error.localizedDescription)")
                } else {
                    print("All exercise preferences uploaded")
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        showAllSavedCheckmark = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showAllSavedCheckmark = false
                        }
                    }
                }
            }
    }
    
    var body: some View {

        VStack {
            Section {
                VStack {
                    WorkoutHeaderView(
                        exercise: exercise,
                        setsCountInput: $setsCountInput,
                        selectedSetIndex: $selectedSetIndex,
                        adjustPerSetArrays: { n in adjustPerSetArrays(to: n) },
                        scopedKey: { base in scopedKey(base) },
                        isFocused: $isFocused
                    )
                    SetSelectorView(setsCount: max(1, int(from: setsCountInput)), selectedSetIndex: $selectedSetIndex) {
                        autofillValues()
                    }
                    SetDetailInputsView(
                        exercise: exercise,
                        selectedSetIndex: $selectedSetIndex,
                        iso: $iso,
                        leftInputs: $leftInputs,
                        rightInputs: $rightInputs,
                        combinedInputs: $combinedInputs,
                        repsInputs: $repsInputs,
                        restInputs: $restInputs,
                        scopedKey: { base in scopedKey(base) },
                        isFocused: $isFocused
                    )
                }
                
                Section {
                    NoteAndDeleteView(
                        exercise: exercise,
                        note: $note,
                        showDeleteConfirmation: $showDeleteConfirmation,
                        scopedKey: { base in scopedKey(base) },
                        isFocused: $isFocused,
                        onDelete: onDelete
                    )
                }
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
                Spacer()
                Button {
                    saveToHistory()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .alert(isPresented: $emptyEntry) {
                    Alert(title: Text("Error"), message: Text("No valid entry to save. All weight fields are empty."), dismissButton: .default(Text("OK")))
                }
                /*
                Removed the inline Save All button here per instructions:
                Button {
                    uploadAllExercisesPreferencesToCloud()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up.on.square")
                        Text("Save All")
                    }
                }
                */
                if showSavedCheckmark {
                    Text("Saved")
                        .foregroundColor(.green)
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .transition(.scale)
                }
                Spacer()
            }
            if !showHistory {
                WorkoutHistoryList()
            }
            
//                        WorkoutHistoryView(
//                            date: $date,
//                            exercise: $exercise,
//                            combined: Binding<Int>(
//                                get: { Int(combinedInput) ?? 0},
//                                set: { combinedInput = String($0)}
//                            ),
//                            left: Binding<Int>(
//                                get: { left },
//                                set: { left = $0 }
//                            ),
//                            right: Binding<Int>(
//                                get: { right },
//                                set: { right = $0 }
//                            ),
//                            sets: Binding<Int>(
//                                get: { Int(setsCountInput) ?? 0},
//                                set: { setsCountInput = String($0)}
//                            ),
//                            reps: Binding<Int>(
//                                get: { reps },
//                                set: { reps = $0 }
//                            ),
//                            rest: Binding<Int>(
//                                get: { rest },
//                                set: { rest = $0 }
//                            ),
//                            note: $note
//                        )
        }
        .background(.clear)
        .padding(.horizontal)
        .cornerRadius(15)
        .onTapGesture {
            isFocused = nil
        }
        .overlay(alignment: .top) {
            if showAllSavedCheckmark {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Saved All")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.3))
                )
                .transition(.scale.combined(with: .opacity))
                .padding(.top, 8)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    uploadAllExercisesPreferencesToCloud()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up.on.square")
                        Text("Save All")
                    }
                }
            }
        }
    }
    
    private func scopedKey(_ base: String) -> String {
        let uid = auth.previewUserID ?? auth.user?.uid ?? "guest"
        return "user_\(uid).\(base)"
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
    
    private func saveToHistory() {
        print("saving")
        print(combinedInputs)
        guard !(combinedInputs == [""] && leftInputs == [""] && rightInputs == [""] && repsInputs == [""] && restInputs == [""]) else {
                    emptyEntry = true
                    return
                }
                emptyEntry = false
        let setRecs = makeSetRecords()
        
        // require at least one non-zero weight across combined or left/right
        let anyWeight = setRecs.contains { $0.combined != 0 || $0.left != 0 || $0.right != 0 }
        guard anyWeight else {
            showEmptyEntryAlert = true
            return
        }
        
        // Build a WorkoutEntry (match your WorkoutEntry @Model initializer)
        let workoutEntry = WorkoutEntry(
            exercise: exercise,
            date: date,
            sets: setRecs,
            note: note,
        )
        
        // Wrap in WorkoutHistory
        let history = WorkoutHistory(
            id: UUID(),
            date: date,
            exercise: exercise,
            entries: [workoutEntry]
        )
        
        context.insert(history)
        print(history.entries.count)
        do {
            try context.save()
            uploadExercisePreferencesToCloud()
            showSavedCheckmark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showSavedCheckmark = false }
        } catch {
            print("Save error:", error)
        }
    }
    
    private func autofillValues() {
        // Check and autofill leftInput
        if leftInputs[selectedSetIndex].isEmpty {
            leftInputs[selectedSetIndex] = "\(lastNonZero(for: "left\(exercise)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill rightInput
        if rightInputs[selectedSetIndex].isEmpty {
            rightInputs[selectedSetIndex] = "\(lastNonZero(for: "right\(exercise)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill combinedInput
        if combinedInputs[selectedSetIndex].isEmpty {
            combinedInputs[selectedSetIndex] = "\(lastNonZero(for: "weight\(exercise)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill repsInput
        if repsInputs[selectedSetIndex].isEmpty {
            repsInputs[selectedSetIndex] = "\(lastNonZero(for: "reps\(exercise)", upTo: selectedSetIndex))"
        }
        
        // Check and autofill restInput
        if restInputs[selectedSetIndex].isEmpty {
            restInputs[selectedSetIndex] = "\(lastNonZero(for: "rest\(exercise)", upTo: selectedSetIndex))"
        }
    }
}

struct SetRow: View {
    var defaults = UserDefaults.standard
    let title: String
    @Binding var text: String
    let exerciseKey: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).padding(-4)
            TextField(title, text: $text)
                .keyboardType(.numberPad)
                .padding(8)
                .background(ColorPalette.accent.opacity(0.8).cornerRadius(8))
                .onChange(of: text) { oldValue, newValue in
                    if let value = Int(newValue) {
                        defaults.set(value, forKey: exerciseKey)
                    } else {
                        defaults.set(0, forKey: exerciseKey)
                    }
                }
                .onAppear {
                    text = "\(defaults.integer(forKey: exerciseKey))"
                }
                .frame(minWidth: 80)
        }
    }
}

struct WorkoutHeaderView: View {
    let exercise: String
    @Binding var setsCountInput: String
    @Binding var selectedSetIndex: Int
    var adjustPerSetArrays: (Int) -> Void
    var scopedKey: (String) -> String
    @EnvironmentObject var auth: AuthManager
    var defaults = UserDefaults.standard
    var isFocused: FocusState<Bool?>.Binding
    var body: some View {
        HStack {
            Text(exercise)
                .foregroundColor(.white)
                .padding()
                .font(.title.bold())
            Spacer()
            VStack {
                Text("Sets").font(.subheadline)
                TextField("Sets", text: $setsCountInput)
                    .keyboardType(.default)
                    .frame(width: 60)
                    .padding(6)
                    .background(ColorPalette.accent.opacity(0.8).cornerRadius(8))
                    .onChange(of: setsCountInput) {
                        let n = max(1, Int(setsCountInput) ?? 1)
                        adjustPerSetArrays(n)
                        defaults.set(n, forKey: scopedKey("sets\(exercise)"))
                        if selectedSetIndex >= n { selectedSetIndex = n - 1 }
                    }
                    .focused(isFocused, equals: true)
                    .onAppear {
                        let n = max(1, defaults.integer(forKey: scopedKey("sets\(exercise)")))
                        setsCountInput = "\(n == 0 ? 1 : n)"
                        adjustPerSetArrays(Int(setsCountInput) ?? 1)
                    }
            }
        }
    }
}

struct SetSelectorView: View {
    let setsCount: Int
    @Binding var selectedSetIndex: Int
    var onSelect: () -> Void
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<setsCount, id: \.self) { idx in
                    Button(action: {
                        selectedSetIndex = idx
                        onSelect()
                    }) {
                        Text("Set \(idx + 1)")
                            .padding(8)
                            .background(selectedSetIndex == idx ? ColorPalette.accent.opacity(0.8) : ColorPalette.primary.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }.padding(.vertical, 6)
        }
    }
}

struct SetDetailInputsView: View {
    let exercise: String
    @Binding var selectedSetIndex: Int
    @Binding var iso: Bool
    @Binding var leftInputs: [String]
    @Binding var rightInputs: [String]
    @Binding var combinedInputs: [String]
    @Binding var repsInputs: [String]
    @Binding var restInputs: [String]
    var scopedKey: (String) -> String
    var defaults = UserDefaults.standard
    var isFocused: FocusState<Bool?>.Binding
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 10) {
                    if defaults.bool(forKey: scopedKey("iso\(exercise)_set\(selectedSetIndex)")) {
                        HStack {
                            SetRow(title: "Left Weight",
                                   text: Binding(get: { leftInputs[selectedSetIndex] }, set: { leftInputs[selectedSetIndex] = $0 }),
                                   exerciseKey: scopedKey("left\(exercise)_set\(selectedSetIndex)"))
                            .focused(isFocused, equals: true)
                            SetRow(title: "Right Weight",
                                   text: Binding(get: { rightInputs[selectedSetIndex] }, set: { rightInputs[selectedSetIndex] = $0 }),
                                   exerciseKey: scopedKey("right\(exercise)_set\(selectedSetIndex)"))
                            .focused(isFocused, equals: true)
                        }
                    } else {
                        SetRow(title: "Combined Weight",
                               text: Binding(get: { combinedInputs[selectedSetIndex] }, set: { combinedInputs[selectedSetIndex] = $0 }),
                               exerciseKey: scopedKey("weight\(exercise)_set\(selectedSetIndex)"))
                        .focused(isFocused, equals: true)
                    }
                }
                Button {
                    iso.toggle()
                    defaults.set(iso, forKey: scopedKey("iso\(exercise)_set\(selectedSetIndex)"))
                } label: {
                    Image(systemName: iso ? "arrow.right.and.line.vertical.and.arrow.left" : "arrow.left.and.line.vertical.and.arrow.right")
                }
            }
            HStack {
                SetRow(title: "Reps",
                       text: Binding(get: { repsInputs[selectedSetIndex] }, set: { repsInputs[selectedSetIndex] = $0 }),
                       exerciseKey: scopedKey("reps\(exercise)_set\(selectedSetIndex)"))
                .focused(isFocused, equals: true)
                SetRow(title: "Rest",
                       text: Binding(get: { restInputs[selectedSetIndex] }, set: { restInputs[selectedSetIndex] = $0 }),
                       exerciseKey: scopedKey("rest\(exercise)_set\(selectedSetIndex)"))
                .focused(isFocused, equals: true)
            }
        }
        .onAppear {
            iso = defaults.bool(forKey: scopedKey("iso\(exercise)_set\(selectedSetIndex)"))
        }
    }
}

struct NoteAndDeleteView: View {
    let exercise: String
    @Binding var note: String
    @Binding var showDeleteConfirmation: Bool
    var scopedKey: (String) -> String
    var isFocused: FocusState<Bool?>.Binding
    var onDelete: () -> Void
    var defaults = UserDefaults.standard
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Note").font(.subheadline).padding(-4)
                HStack(alignment: .center, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("Note")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                        }
                        TextEditor(text: $note)
                            .focused(isFocused, equals: true)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 6)
                            .padding(.top, 6)
                            .frame(minHeight: 36, maxHeight: 96)
                    }
                    if !note.isEmpty {
                        Button(action: { note = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ColorPalette.primary)
                                .padding(8)
                                .contentShape(Rectangle())
                        }
                        .padding(.trailing, 6)
                        .padding(.vertical, 2)
                    }
                }
                .background(ColorPalette.accent.opacity(0.8).cornerRadius(10))
                .onAppear {
                    note = defaults.string(forKey: scopedKey("note\(exercise)")) ?? ""
                }
                .onChange(of: note) {
                    defaults.set(note, forKey: scopedKey("note\(exercise)"))
                }
            }
            Button(action: { showDeleteConfirmation = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Exercise"),
                    message: Text("Are you sure you want to remove \(exercise) from this session?"),
                    primaryButton: .destructive(Text("Delete")) { onDelete() },
                    secondaryButton: .cancel()
                )
            }
        }
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
    WorkoutEntryView(exercise: "Test Exercise", combined: 0, left: 0, right: 0, reps: 0, rest: 0, note: "", onDelete: {})
        .environmentObject(MockAuthManager())
        .modelContainer(for: [WorkoutHistory.self, WorkoutEntry.self], inMemory: true)
}

