//
//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct WeightEntryView: View {
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
    @State var itemToDelete: WeightEntry?
    @State var showConfirmationDialogue = false
    @State var showHistory: Bool = false
    @State private var weightInput: String = ""
    @State private var leftInput: String = ""
    @State private var rightInput: String = ""

    var body: some View {
        VStack {
            Section {
                    HStack {
                        Text(exercise)
                            .foregroundColor(.white)
                            .padding()
                            .font(.headline)
                        if (iso) {
                            Button {
                                iso = false
                            } label: {
                                Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                    .foregroundColor(Color.white)
                            }
                        } else {
                            Button {
                                iso = true
                            } label: {
                                Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                    .foregroundColor(Color.white)
                            }
                        }
                        
                        if iso {
                            VStack {
                                
                                HStack {
                                    VStack {
                                        Text("Left")
                                            .padding(-4)
                                            .font(.subheadline)
                                        TextField("Left Weight", text: $leftInput, prompt: Text("Weight Left").foregroundColor(.white.opacity(0.5)))
                                            .padding()
                                            .background(weight == 0 && left == 0 && right == 0 ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                            .keyboardType(.numberPad)
                                            .onChange(of: leftInput) { oldValue, newValue in
                                                if let value = Int(newValue) {
                                                    left = value
                                                    defaults.set(leftInput, forKey: "left\(id)")
                                                } else {
                                                    left = 0
                                                }
                                                print(defaults.integer(forKey: "left\(id)"))
                                            }                                    }
                                    VStack {
                                        Text("Right")
                                            .padding(-4)
                                            .font(.subheadline)
                                        TextField("Right Weight", text: $rightInput, prompt: Text("Right Weight").foregroundColor(.white.opacity(0.5)))
                                            .padding()
                                            .background(weight == 0 && left == 0 && right == 0 ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                            .keyboardType(.numberPad)
                                            .onChange(of: rightInput) { oldValue, newValue in
                                                if let value = Int(newValue) {
                                                    right = value
                                                    defaults.set(rightInput, forKey: "right\(id)")
                                                } else {
                                                    right = 0
                                                }
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
                                    .background(weight == 0 && left == 0 && right == 0 ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
                                    .keyboardType(.numberPad)
                                    .onChange(of: weightInput) { oldValue, newValue in
                                        if let value = Int(newValue) {
                                            weight = value
                                            defaults.set(weightInput, forKey: "weight\(id)")
                                        } else {
                                            weight = 0
                                        }
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
                                .keyboardType(.numberPad)
                                .onChange(of: sets) { oldValue, newValue in
                                    sets = newValue
                                    defaults.set(sets, forKey: "sets\(id)")
                                }
                        }
                        VStack {
                            Text("Reps")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Reps", text: $reps, prompt: Text("Reps").foregroundColor(.white.opacity(0.5)))
                                .padding() .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .keyboardType(.numberPad)
                                .onChange(of: reps) { oldValue, newValue in
                                    reps = newValue
                                    defaults.set(reps, forKey: "reps\(id)")
                                }

                        }
                        VStack {
                            Text("Rest")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Rest (sec)", text: $rest, prompt: Text("Rest (sec)").foregroundColor(.white.opacity(0.5)))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .keyboardType(.numberPad)
                                .onChange(of: rest) { oldValue, newValue in
                                    rest = newValue
                                    defaults.set(rest, forKey: "rest\(id)")
                                }
                        }
                    }
                    Section {
                        Text("Note")
                            .padding(-4)
                            .font(.subheadline)
                        TextField("Note", text: $note, prompt: Text("Note").foregroundColor(.white.opacity(0.5)))
                            .padding()
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .lineLimit(1...4)
                            .onChange(of: note) { oldValue, newValue in
                                note = newValue
                                defaults.set(note, forKey: "note\(id)")
                            }
                        
                    }
                }
                .listRowInsets(EdgeInsets()) // Remove default insets
            WorkoutHistoryView(date: $date, exercise: $exercise, weight: $weight, left: $left, right: $right, sets: $sets, reps: $reps, rest: $rest, note: $note)
        }
        .background(.clear)
        .padding()
        .cornerRadius(15)
    }
}

#Preview {
    WeightEntryView(exercise: "Shest Press", iso: true)
}
