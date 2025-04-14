//
//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

var defaults = UserDefaults.standard

struct WorkoutEntryView: View {
    @Environment(\.modelContext) var context
    @State var id: UUID = UUID()
    @State var exercise: String
    @State var weight: Int = 0
    @State var left: Int = 0
    @State var right: Int = 0
    @State var sets: String = ""
    @State var reps: String = ""
    @State var rest: String = ""
    @State var note: String = ""
    @State var date: Date = Date()
    @State var iso: Bool = false
    @State var itemToDelete: WorkoutEntry?
    @State var showConfirmationDialogue = false
    @State var showHistory: Bool = false
    @State private var weightInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""
    @State private var showDeleteConfirmation = false
    var onDelete: () -> Void


    var body: some View {
        VStack {
            Section {
                    HStack {
                        Text(exercise)
                            .foregroundColor(.white)
                            .padding()
                            .font(.headline)
                        Button {
                            iso.toggle()
                            defaults.set(iso, forKey: "iso\(exercise)")
                        } label: {
                            Image(systemName: iso ? "arrow.right.and.line.vertical.and.arrow.left" : "arrow.left.and.line.vertical.and.arrow.right")
                        }
                        
                        if defaults.bool(forKey: "iso\(exercise)") {
                            HStack {
                                WeightField(label: "Left", input: $leftInput, key: "left", exercise: exercise, value: $left)
                                WeightField(label: "Right", input: $rightInput, key: "right", exercise: exercise, value: $right)
                            }
                        } else {
                            WeightField(label: "Weight", input: $weightInput, key: "weight", exercise: exercise, value: $weight)
                        }
                    }
                    
                    HStack {
                        HStack {
                            ExerciseField(label: "Sets", value: $sets, key: "sets", exercise: exercise, placeholder: "Sets")
                            ExerciseField(label: "Reps", value: $reps, key: "reps", exercise: exercise, placeholder: "Reps")
                            ExerciseField(label: "Rest", value: $rest, key: "rest", exercise: exercise, placeholder: "Rest")
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
                                    .onChange(of: note) { oldValue, newValue in
                                        note = newValue
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
                                Alert(title: Text("Delete Exercise"),
                                      message: Text("Are you sure you want to remove \(exercise) from this session?"),
                                      primaryButton: .destructive(Text("Delete")) {
                                    onDelete()
                                },
                                      secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
            WorkoutHistoryView(date: $date, exercise: $exercise, weight: $weight, left: $left, right: $right, sets: $sets, reps: $reps, rest: $rest, note: $note)
        }
        .background(.clear)
        .padding(.horizontal)
        .cornerRadius(15)
    }
}

#Preview {
    WorkoutEntryView(exercise: "Test Exercise", weight: 0, left: 0, right: 0, sets: "", reps: "", rest: "", note: "", onDelete: {})
}

// Subcomponents
struct ExerciseField: View {
    var label: String
    @Binding var value: String
    var key: String
    var exercise: String
    var placeholder: String

    var body: some View {
        VStack {
            Text(label)
                .padding(-4)
                .font(.subheadline)
            TextField(placeholder, text: $value, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .padding()
                .background(Color.blue.opacity(0.8).cornerRadius(10))
                .onChange(of: value) { oldValue, newValue in
                    value = newValue
                    defaults.set(value, forKey: "\(key)\(exercise)")
                }
        }
    }
}

struct WeightField: View {
    var label: String
    @Binding var input: String
    var key: String
    var exercise: String
    @Binding var value: Int

    var body: some View {
        VStack {
            Text(label)
                .padding(-4)
                .font(.subheadline)
            TextField(label, text: $input, prompt: Text(label).foregroundColor(.white.opacity(0.5)))
                .padding()
                .background(input == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                .onChange(of: input) { oldValue, newValue in
                    if let newValue = Int(newValue) {
                        value = newValue
                    } else {
                        value = 0
                    }
                    defaults.set(value, forKey: "\(key)\(exercise)")
                }
                .onAppear {
                    input = "\(defaults.integer(forKey: "\(key)\(exercise)"))"
                }
        }
    }
}

