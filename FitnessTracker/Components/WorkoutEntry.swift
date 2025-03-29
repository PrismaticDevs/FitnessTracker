//
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
                            VStack {
                                
                                HStack {
                                    VStack {
                                        Text("Left")
                                            .padding(-4)
                                            .font(.subheadline)
                                        TextField("Left Weight", text: $leftInput, prompt: Text("Weight Left").foregroundColor(.white.opacity(0.5)))
                                            .padding()
                                            .background(weightInput == "" && leftInput == "" && rightInput == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                            .onChange(of: leftInput) { oldValue, newValue in
                                                if let value = Int(newValue) {
                                                    left = value
                                                } else {
                                                    left = 0
                                                }
                                                defaults.set(left, forKey: "left\(exercise)")
                                            }
                                            .onAppear {
                                                leftInput = "\(defaults.integer(forKey: "left\(exercise)"))"
                                            }
                                    }
                                    VStack {
                                        Text("Right")
                                            .padding(-4)
                                            .font(.subheadline)
                                        TextField("Right Weight", text: $rightInput, prompt: Text("Right Weight").foregroundColor(.white.opacity(0.5)))
                                            .padding()
                                            .background(weightInput == "" && leftInput == "" && rightInput == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                            .onChange(of: rightInput) { oldValue, newValue in
                                                if let value = Int(newValue) {
                                                    right = value
                                                } else {
                                                    right = 0
                                                }
                                                defaults.set(right, forKey: "right\(exercise)")
                                            }
                                            .onAppear {
                                                rightInput = "\(defaults.integer(forKey: "right\(exercise)"))"
                                            }
                                    }
                                }
                            }
                        } else {
                            VStack {
                                Text("Weight").font(.subheadline)
                                    .padding(-4)
                                TextField("Weight", text: $weightInput, prompt: Text("Weight").foregroundColor(.white.opacity(0.5)))
                                    .padding()
                                    .background(weightInput == "" && leftInput == "" && rightInput == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                    .onChange(of: weightInput) { oldValue, newValue in
                                        if let value = Int(newValue) {
                                            weight = value
                                        } else {
                                            weight = 0
                                        }
                                        defaults.set(weight, forKey: "weight\(exercise)")
                                    }
                                    .onAppear {
                                        weightInput = "\(defaults.integer(forKey: "weight\(exercise)"))"
                                    }
                            }
                        }
                    }
                    
                    HStack {
                        VStack {
                            Text("Sets")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Sets", text: $sets, prompt: Text("Sets").foregroundColor(.white.opacity(0.5)))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .onChange(of: sets) { oldValue, newValue in
                                    sets = newValue
                                    defaults.set(sets, forKey: "sets\(exercise)")
                                }
                        }
                        VStack {
                            Text("Reps")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Reps", text: $reps, prompt: Text("Reps").foregroundColor(.white.opacity(0.5)))
                                .padding() .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .onChange(of: reps) { oldValue, newValue in
                                    reps = newValue
                                    defaults.set(reps, forKey: "reps\(exercise)")
                                }

                        }
                        VStack {
                            Text("Rest")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Rest (sec)", text: $rest, prompt: Text("Rest (sec)").foregroundColor(.white.opacity(0.5)))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .onChange(of: rest) { oldValue, newValue in
                                    rest = newValue
                                    defaults.set(rest, forKey: "rest\(exercise)")
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
                                            note = "" // Clear the text field
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .opacity(note.isEmpty ? 0 : 1) // Hide button if text is empty
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
                .listRowInsets(EdgeInsets()) // Remove default insets
            WorkoutHistoryView(date: $date, exercise: $exercise, weight: $weight, left: $left, right: $right, sets: $sets, reps: $reps, rest: $rest, note: $note)
        }
        .background(.clear)
        .padding(.horizontal)
        .cornerRadius(15)
    }
}

#Preview {
    WorkoutEntryView(exercise: "", weight: 0, left: 0, right: 0, sets: "", reps: "", rest: "", note: "", onDelete: {})
}

