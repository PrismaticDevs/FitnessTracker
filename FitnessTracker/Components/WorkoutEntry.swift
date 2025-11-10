//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct WorkoutEntryView: View {
    var defaults = UserDefaults.standard
    @Environment(\.modelContext) var context
    
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
    @State private var showEmptyEntryAlert = false
    @State private var combinedInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""
    @State private var showDeleteConfirmation = false
    @State var emptyEntry: Bool = true
    
    var onDelete: () -> Void
    
    var body: some View {
        VStack {
            Section {
                VStack {
                    HStack {
                        Text(exercise)
                            .foregroundColor(.white)
                            .padding()
                            .font(.headline)
                        VStack {
                            Text("Sets").font(.subheadline)
                            TextField("Sets", text: $setsCountInput)
                                .keyboardType(.default)
                                .frame(width: 60)
                                .padding(6)
                                .background(Color.blue.opacity(0.8).cornerRadius(8))
                                .onChange(of: setsCountInput) {
                                    let n = max(1, Int(setsCountInput) ?? 1)
                                    adjustPerSetArrays(to: n)
                                    defaults.set(n, forKey: "sets\(exercise)")
                                    if selectedSetIndex >= n { selectedSetIndex = n - 1 }
                                }
                                .onAppear {
                                    let n = max(1, defaults.integer(forKey: "sets\(exercise)"))
                                    setsCountInput = "\(n == 0 ? 1 : n)"
                                    adjustPerSetArrays(to: Int(setsCountInput) ?? 1)
                                }
                        }
                    }
                    // horizontal selector of set numbers
                    let n = max(1, int(from: setsCountInput))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<n, id: \.self) { idx in
                                Button(action: {
                                    selectedSetIndex = idx
                                    autofillValues()
                                }) {
                                    Text("Set \(idx + 1)")
                                        .padding(8)
                                        .background(selectedSetIndex == idx ? Color.blue.opacity(0.8) : Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }.padding(.vertical, 6)
                    }
                    
                    // show detailed inputs for the selected set only
                    VStack {
                        HStack {
                            VStack(spacing: 10) {
                                if defaults.bool(forKey: "iso\(exercise)_set\(selectedSetIndex)") {
                                    HStack {
                                        SetRow(title: "Left Weight",
                                               text: binding(for: $leftInputs, index: selectedSetIndex),
                                               exerciseKey: "left\(exercise)_set\(selectedSetIndex)"
                                        )
                                        .onChange(of: leftInputs[selectedSetIndex]) { oldValue, newValue in
                                            if let value = Int(newValue) {
                                                defaults.set(value, forKey: "left\(exercise)_set\(selectedSetIndex)")
                                            } else {
                                                defaults.set(0, forKey: "left\(exercise)_set\(selectedSetIndex)")
                                            }
                                        }
                                        SetRow(title: "Right Weight",
                                               text: binding(for: $rightInputs, index: selectedSetIndex),
                                               exerciseKey: "right\(exercise)_set\(selectedSetIndex)"
                                        )
                                        .onChange(of: rightInputs[selectedSetIndex]) { oldValue, newValue in
                                            if let value = Int(newValue) {
                                                defaults.set(value, forKey: "right\(exercise)_set\(selectedSetIndex)")
                                            } else {
                                                defaults.set(0, forKey: "right\(exercise)_set\(selectedSetIndex)")
                                            }
                                        }
                                    }
                                } else {
                                    SetRow(title: "Combined Weight",
                                           text: binding(for: $combinedInputs, index: selectedSetIndex),
                                           exerciseKey: "weight\(exercise)_set\(selectedSetIndex)"
                                    )
                                    .onChange(of: leftInputs[selectedSetIndex]) { oldValue, newValue in
                                        if let value = Int(newValue) {
                                            defaults.set(value, forKey: "weight\(exercise)_set\(selectedSetIndex)")
                                        } else {
                                            defaults.set(0, forKey: "weight\(exercise)_set\(selectedSetIndex)")
                                        }
                                    }
                                }
                                
                            }
                            Button {
                                iso.toggle()
                                defaults.set(iso, forKey: "iso\(exercise)_set\(selectedSetIndex)")
                            } label: {
                                Image(systemName: iso ? "arrow.right.and.line.vertical.and.arrow.left" : "arrow.left.and.line.vertical.and.arrow.right")
                            }
                        }
                        HStack {
                            SetRow(title: "Reps",
                                   text: binding(for: $repsInputs, index: selectedSetIndex),
                                   exerciseKey: "reps\(exercise)_set\(selectedSetIndex)"
                            )
                            .onChange(of: repsInputs[selectedSetIndex]) { oldValue, newValue in
                                if let value = Int(newValue) {
                                    defaults.set(value, forKey: "reps\(exercise)_set\(selectedSetIndex)")
                                } else {
                                    defaults.set(0, forKey: "reps\(exercise)_set\(selectedSetIndex)")
                                }
                            }
                            SetRow(title: "Rest",
                                   text: binding(for: $restInputs, index: selectedSetIndex),
                                   exerciseKey: "rest\(exercise)_set\(selectedSetIndex)"
                            )
                            .onChange(of: restInputs[selectedSetIndex]) { oldValue, newValue in
                                if let value = Int(newValue) {
                                    defaults.set(value, forKey: "rest\(exercise)_set\(selectedSetIndex)")
                                } else {
                                    defaults.set(0, forKey: "rest\(exercise)_set\(selectedSetIndex)")
                                }
                            }
                        }
                    }
                }
                
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Note \(defaults.integer(forKey: "note\(exercise)"))").font(.subheadline).padding(-4)
                            TextField("Note", text: $note, prompt: Text("Note").foregroundColor(.white.opacity(0.5)))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .lineLimit(1...4)
                                .overlay(
                                    Button(action: {
                                        note = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .opacity(note.isEmpty ? 0 : 1)
                                            .padding()
                                    }
                                        .foregroundColor(Color.white)
                                        .padding(),
                                    alignment: .trailing
                                )
                                .onChange(of: note) {
                                    defaults.set(note, forKey: "note\(exercise)")
                                }
                        }
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
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
    }
    
    // MARK: - Helpers
    
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
            showSavedCheckmark = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showSavedCheckmark = false }
        } catch {
            print("Save error:", error)
        }
    }
    
    private func autofillValues() {
        // Check and autofill leftInput
        if leftInputs[selectedSetIndex].isEmpty {
            leftInputs[selectedSetIndex] = "\(defaults.integer(forKey: "left\(exercise)_set0"))"
        }
        
        // Check and autofill rightInput
        if rightInputs[selectedSetIndex].isEmpty {
            rightInputs[selectedSetIndex] = "\(defaults.integer(forKey: "right\(exercise)_set0"))"
        }
        
        // Check and autofill combinedInput
        if combinedInputs[selectedSetIndex].isEmpty {
            combinedInputs[selectedSetIndex] = "\(defaults.integer(forKey: "combined\(exercise)_set0"))"
        }
        
        // Check and autofill repsInput
        if repsInputs[selectedSetIndex].isEmpty {
            repsInputs[selectedSetIndex] = "\(defaults.integer(forKey: "reps\(exercise)_set0"))"
        }
        
        // Check and autofill combinedInput
        if restInputs[selectedSetIndex].isEmpty {
            restInputs[selectedSetIndex] = "\(defaults.integer(forKey: "rest\(exercise)_set0"))"
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
                .keyboardType(.default)
                .padding(8)
                .background(Color.blue.opacity(0.8).cornerRadius(8))
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

// MARK: - Preview

#Preview {
    WorkoutEntryView(exercise: "Test Exercise", combined: 0, left: 0, right: 0, reps: 0, rest: 0, note: "", onDelete: {})
}
