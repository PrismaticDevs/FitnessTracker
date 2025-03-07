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
    var exercise: String
    @State var workoutHistory: [WeightEntry] = []
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
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            return formatter
        }

    var body: some View {
        VStack {
            Section {
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
                                        TextField("Left Weight", text: $leftInput, prompt: Text("Weight Left").foregroundColor(.white))
                                            .padding()
                                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                                            .keyboardType(.numberPad)
                                    }
                                    VStack {
                                        Text("Right")
                                            .padding(-4)
                                            .font(.subheadline)
                                        TextField("Right Weight", text: $rightInput, prompt: Text("Right Weight").foregroundColor(.white))
                                            .padding().background(Color.blue.opacity(0.8).cornerRadius(10))
                                            .keyboardType(.numberPad)
                                    }
                                }
                            }
                        } else {
                            VStack {
                                Text("Weight").font(.subheadline)
                                    .padding(-4)
                                TextField("Weight", text: $weightInput, prompt: Text("Weight").foregroundColor(.white))
                                    .padding()
                                    .background(Color.blue.opacity(0.8).cornerRadius(10))
                                    .keyboardType(.numberPad)
                            }
                        }
                    }
                    
                    HStack {
                        VStack {
                            Text("Sets")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Sets", text: $sets, prompt: Text("Sets").foregroundColor(.white))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .keyboardType(.numberPad)
                        }
                        VStack {
                            Text("Reps")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Reps", text: $reps, prompt: Text("Reps").foregroundColor(.white))
                                .padding() .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .keyboardType(.numberPad)
                        }
                        VStack {
                            Text("Rest")
                                .padding(-4)
                                .font(.subheadline)
                            TextField("Rest (sec)", text: $rest, prompt: Text("Rest (sec)").foregroundColor(.white))
                                .padding()
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .keyboardType(.numberPad)
                        }
                    }
                    Section {
                        Text("Note")
                            .padding(-4)
                            .font(.subheadline)
                        TextField("Note", text: $note, prompt: Text("Note").foregroundColor(.white))
                            .padding()
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .lineLimit(1...4)
                        
                    }
                }
                .listRowInsets(EdgeInsets()) // Remove default insets
                
                Section(header: Text("History").foregroundColor(.white).padding(-4)) {
                    VStack {
                        HStack {
                            Spacer()
                            Text("See History")
                            Button {
                                saveEntry()
                                showHistory.toggle()
                            } label: {
                                Image(systemName: showHistory ? "eye.slash" : "eye")
                            }
                            Spacer()
                            Text("Save")
                            Button {
                                saveEntry()
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                            Spacer()
                        }
                        .padding()
//                        if showHistory {
//                            let sortedItems = workoutHistory
//                                                        .filter { $0.exercise == Exercise }
//                                                        .sorted(by: { $0.date > $1.date })
//                            let maxWeight = sortedItems.max(by: { $0.weight < $1.weight })?.weight
//                            let maxLeft = sortedItems.max(by: { $0.left < $1.left })?.left
//                            let maxRight = sortedItems.max(by: { $0.right < $1.right })?.right
//                            List {
//                                ForEach(WeightEntry.filter { $0.exercise == Exercise }.sorted(by: { $0.date > $1.date}), id: \.id) { item in
//                                    VStack(alignment: .leading) {
//                                        let formattedDate = dateFormatter.string(from: item.date)
//                                        Text(formattedDate)
//                                        Text("Weight: \(item.weight)")
//                                            .foregroundColor(item.weight == maxWeight ? Color.yellow : Color.primary)
//                                        Text("Left Isolated: \(item.left)")
//                                            .foregroundColor(item.left == maxLeft ? Color.yellow : Color.primary)
//                                        Text("Right Isolated: \(item.right)")
//                                            .foregroundColor(item.right == maxRight ? Color.yellow : Color.primary)
//                                    }
//                                    VStack {
//                                        Text("Sets: \(item.sets)")
//                                        Text("Reps: \(item.reps)")
//                                        Text("Rest: \(item.rest)")
//                                    }
//                                            
//                                }
//                            }
//                            .listStyle(PlainListStyle())
//                        }
                        
                    }
                    .background(Color.blue.opacity(0.8).cornerRadius(10))
                }
                .listRowInsets(EdgeInsets())
                .background(Color.clear)
            }
            .background(Color.clear)
        }
        .background(.clear)
        .padding()
        .cornerRadius(15)
    }

     func saveEntry() {
        guard let weightValue = Int(weightInput),
              let leftValue = Int(leftInput),
              let rightValue = Int(rightInput) else {
            // Handle invalid input
            return
        }

        let newEntry = WeightEntry(
            exercise: exercise,
            date: Date(),
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
    
     func resetFields() {
//        exercise = ""
        weight = 0
        left = 0
        right = 0
        sets = ""
        reps = ""
        rest = ""
        note = ""
    }
}

#Preview {
    WeightEntryView(exercise: "Shest Press",iso: true)
}
