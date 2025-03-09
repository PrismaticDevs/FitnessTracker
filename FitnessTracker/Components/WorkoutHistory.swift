//
//  WorkoutHistory.swift
//  FitnessTracker
//
//  Created by Matt on 3/3/25.
//
import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) var context
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Query var workoutHistory: [WeightEntry]
    @Binding var date: Date
    @State var showHistory: Bool = false
    @Binding var exercise: String
    @Binding var weight: Int
    @Binding var left: Int
    @Binding var right: Int
    @Binding var sets: String
    @Binding var reps: String
    @Binding var rest: String
    @Binding var note: String
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            return formatter
    }
    
    var body: some View {
        ZStack {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Text("Save")
                        Button {
                            saveEntry()
                            print(workoutHistory)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        Spacer()
                        Text("See History")
                        Button {
                            showHistory.toggle()
                        } label: {
                            Image(systemName: showHistory ? "eye.slash" : "eye")
                        }
                        Spacer()
                    }
                    .padding()
                    if showHistory {
//                        List {
                            ForEach(workoutHistory.filter { $0.exercise == exercise}, id: \.id) { entry in
                                let formattedDate = dateFormatter.string(from: entry.date)
                                Text(formattedDate)
                                HStack {
                                    VStack {
                                        Text("Weight: \(entry.weight)")
                                            .foregroundColor(.white)
                                        Text("Left Isolated: \(entry.left)")
                                            .foregroundColor(.white)
                                        Text("Right Isolated \(entry.right)")
                                            .foregroundColor(.white)
                                    }
                                    VStack {
                                        Text("Sets: \(entry.sets)")
                                            .foregroundColor(.white)
                                        Text("Reps: \(entry.reps)")
                                            .foregroundColor(.white)
                                        Text("Rest: \(entry.rest)")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
//                        }
                        .overlay {
                            if workoutHistory.isEmpty {
                                ContentUnavailableView(label: {
                                    Label("No history to list", systemImage: "list.bullet.rectangle.portrait")
                                        .foregroundColor(.white)
                                }, description: {
                                    Text("Start by saving sessions to your workout history.")
                                        .foregroundColor(.white)
                                })
                            }
                        }
                        .listStyle(PlainListStyle())
//                        .frame(height: 500)
//                        .listRowBackground(Color.clear)
//                        .scrollContentBackground(.hidden)
                    }
                    
                }
                .background(Color.blue.opacity(0.8).cornerRadius(10))
                .onAppear() {
                    print(workoutHistory.isEmpty)
                }
            }
            .listRowInsets(EdgeInsets())
            .background(Color.clear)
        }
    }
    
    func saveEntry() {
        print("Exercise: \(exercise)")
          print("Weight: \(weight)")
          print("Left: \(left)")
          print("Right: \(right)")
          print("Sets: \(sets)")
          print("Reps: \(reps)")
          print("Rest: \(rest)")
          print("Note: \(note)")
        let newEntry = WeightEntry(
            exercise: exercise,
            date: Date(),
            weight: Int(weight),
            left: Int(left),
            right: Int(right),
            sets: sets,
            reps: reps,
            rest: rest,
            note: note
        )
        print(newEntry.weight, "new weight entry")
        context.insert(newEntry)
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        print(newEntry)
    }

}

#Preview {
    WorkoutHistoryView(date: .constant(Date()), exercise: .constant("Incline Bench Press"), weight: .constant(0), left: .constant(0), right: .constant(0), sets: .constant(""), reps: .constant(""), rest: .constant(""), note: .constant("") )
}
