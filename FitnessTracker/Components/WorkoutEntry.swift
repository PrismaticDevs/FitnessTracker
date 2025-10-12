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
    @State private var combinedInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""
    @State private var showDeleteConfirmation = false

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
                                .keyboardType(.numberPad)
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
                                Button(action: { selectedSetIndex = idx }) {
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
                                        SetRow(title: "Left Weight", text: binding(for: $leftInputs, index: selectedSetIndex)) {
                                            defaults.set(Int(leftInputs[selectedSetIndex]) ?? 0, forKey: "left\(exercise)_set\(selectedSetIndex)")
                                        }
                                        SetRow(title: "Right Weight", text: binding(for: $rightInputs, index: selectedSetIndex)) {
                                            defaults.set(Int(rightInputs[selectedSetIndex]) ?? 0, forKey: "right\(exercise)_set\(selectedSetIndex)")
                                        }
                                    }
                                } else {
                                    SetRow(title: "Combined Weight", text: binding(for: $combinedInputs, index: selectedSetIndex)) {
                                        defaults.set(Int(combinedInputs[selectedSetIndex]) ?? 0, forKey: "combined\(exercise)_set\(selectedSetIndex)")
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
                            SetRow(title: "Reps", text: binding(for: $repsInputs, index: selectedSetIndex)) {
                                defaults.set(Int(repsInputs[selectedSetIndex]) ?? 0, forKey: "reps\(exercise)_set\(selectedSetIndex)")
                            }
                            SetRow(title: "Rest", text: binding(for: $restInputs, index: selectedSetIndex)) {
                                defaults.set(Int(restInputs[selectedSetIndex]) ?? 0, forKey: "rest\(exercise)_set\(selectedSetIndex)")
                            }
                        }
                    }
                }

                Section {
                    HStack {
                        VStack {
                            Text("Note")
                                .padding(-4)
                                .font(.subheadline)
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

//            WorkoutHistoryView(
//                date: $date,
//                exercise: $exercise,
//                combined: Binding<Int>(
//                    get: { Int(combinedInput) ?? 0},
//                    set: { combinedInput = String($0)}
//                ),
//                left: Binding<Int>(
//                    get: { left },
//                    set: { left = $0 }
//                ),
//                right: Binding<Int>(
//                    get: { right },
//                    set: { right = $0 }
//                ),
//                sets: $setsCountInput,
//                reps: $reps,
//                rest: $rest,
//                note: $note
//            )
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
}

struct SetRow: View {
    let title: String
    @Binding var text: String
    var onCommit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).padding(-4)
            TextField(title, text: $text)
                .keyboardType(.numberPad)
                .padding(8)
                .background(Color.blue.opacity(0.8).cornerRadius(8))
                .onChange(of: text) { oldValue, newValue in onCommit() }
                .onSubmit { onCommit() }
                .frame(minWidth: 80)
        }
    }
}

// MARK: - Preview

#Preview {
    WorkoutEntryView(exercise: "Test Exercise", combined: 0, left: 0, right: 0, reps: 0, rest: 0, note: "", onDelete: {})
}
