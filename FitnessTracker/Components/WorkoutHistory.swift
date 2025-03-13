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
    
    var body: some View {
        
        NavigationStack {
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
                            ZStack {
                                List {
                                    ForEach(workoutHistory.filter { $0.exercise == exercise}, id: \.id) { entry in
                                        WeightEntryItem(entry: entry)
                                    }
                                    .padding(3)
                                    .cornerRadius(10)
                                    .listRowBackground(Color.blue.opacity(0.8))
                                }
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
                                .padding()
                                .frame(height: 500)
                                .scrollContentBackground(.hidden)
                            }
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .padding()
                    .font(.system(size: 18))
                }
                .background(Color.clear)
            }
        }
    }
    
    func saveEntry() {
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
        context.insert(newEntry)
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

}

#Preview {
    WorkoutHistoryView(date: .constant(Date()), exercise: .constant("Incline Bench Press"), weight: .constant(0), left: .constant(0), right: .constant(0), sets: .constant(""), reps: .constant(""), rest: .constant(""), note: .constant("") )
}

struct WeightEntryItem: View {
    @Environment(\.modelContext) var context
    @State var showDeleteAlert: Bool = false
    @State var entry: WeightEntry
    var body: some View {
        var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy HH:mm"
                return formatter
        }
        let formattedDate = dateFormatter.string(from: entry.date)
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(formattedDate)
                    Text("Weight: \(entry.weight)")
                        .foregroundColor(.white)
                    Text("Left Isolated: \(entry.left)")
                        .foregroundColor(.white)
                    Text("Right Isolated \(entry.right)")
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading) {
                    Text("Sets: \(entry.sets)")
                        .foregroundColor(.white)
                    Text("Reps: \(entry.reps)")
                        .foregroundColor(.white)
                    Text("Rest: \(entry.rest)")
                        .foregroundColor(.white)
                }
            }
            Text("Note: \(entry.note)")
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive){
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .alert("Delete Entry", isPresented: $showDeleteAlert) {
            Button(role: .destructive) {
                context.delete(entry)
                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error)")
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Are you sure you want to delete this entry?")
        }
    }
}
