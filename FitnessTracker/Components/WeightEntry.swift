//
//  WeightInput.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct WeightEntryView: View {
    @Environment(\.modelContext) var context
    @Binding var exercise: String
    @State private var weight: String = ""
    @State private var left: String = ""
    @State private var right: String = ""
    @State private var sets: String = ""
    @State private var reps: String = ""
    @State private var rest: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var iso: Bool = false
    @State private var itemToDelete: WeightEntry?
    @State private var showConfirmationDialogue = false

    var body: some View {
        Form {
            Section(header: Text("Weight Entry")) {
                HStack {
                    Text(exercise)
                        .foregroundColor(.white)
                        .padding()
                        .font(.headline)
                        .frame(width: 100, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if iso {
                        HStack {
                            TextField("Left Weight", text: $left)
                                .keyboardType(.numberPad)
                            TextField("Right Weight", text: $right)
                                .keyboardType(.numberPad)
                        }
                    } else {
                        TextField("Weight", text: $weight)
                            .keyboardType(.numberPad)
                    }
                }
                
                HStack {
                    TextField("Sets", text: $sets)
                        .keyboardType(.numberPad)
                    TextField("Reps", text: $reps)
                        .keyboardType(.numberPad)
                    TextField("Rest (sec)", text: $rest)
                        .keyboardType(.numberPad)
                }
                
                TextField("Note", text: $note)
            }
            
            HStack {
                Text("Save")
                Section {
                    Button {
                        saveEntry()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
        .navigationTitle("Add Weight Entry")
    }

    private func saveEntry() {
        guard let weightValue = Int(weight),
              let leftValue = Int(left),
              let rightValue = Int(right) else {
            // Handle invalid input
            return
        }

        let newEntry = WeightEntry(
            exercise: exercise,
            weight: weightValue,
            left: leftValue,
            right: rightValue,
            sets: sets,
            reps: reps,
            rest: rest,
            note: note
        )
        
        context.insert(newEntry)

        // Optionally, reset the fields after saving
        resetFields()
    }
    
    private func resetFields() {
        exercise = ""
        weight = ""
        left = ""
        right = ""
        sets = ""
        reps = ""
        rest = ""
        note = ""
    }
}

#Preview {
    WeightEntryView(exercise: .constant("pushups"))
}
