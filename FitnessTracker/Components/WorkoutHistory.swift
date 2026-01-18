////
////  WorkoutHistory.swift
////  FitnessTracker
////
////  Created by Matt on 3/3/25.
////
//import SwiftUI
//import SwiftData
//
//struct WorkoutHistoryView: View {
//    @Environment(\.modelContext) var context
//    @Environment(\.defaultMinListRowHeight) var minRowHeight
//    @Query var workoutHistory: [StrengthEntry]
//    // Bidings
//    @Binding var date: Date
//    @Binding var exercise: String
//    @Binding var combined: Int
//    @Binding var left: Int
//    @Binding var right: Int
//    @Binding var sets: Int
//    @Binding var reps: Int
//    @Binding var rest: Int
//    @Binding var note: String
//    // State
//    @State private var showHistory: Bool = false
//    @State private var emptyEntry: Bool = false
//    @State private var showCheckmark: Bool = false
//    
//    var body: some View {
//        
//        NavigationStack {
//            ZStack {
//                Section {
//                    VStack {
//                        HStack {
//                            Spacer()
//                            Text("Save")
//                            Button {
//                                saveEntry()
//                                print(workoutHistory)
//                            } label: {
//                                Image(systemName: "square.and.arrow.down")
//                            }
//                            .alert(isPresented: $emptyEntry) {
//                                Alert(title: Text("Error"), message: Text("No valid entry to save. All weight fields are empty."), dismissButton: .default(Text("OK")))
//                            }
//                            if showCheckmark {
//                                Text("Saved")
//                                    .foregroundColor(.green)
//                                Image(systemName: "checkmark")
//                                    .foregroundColor(.green)
//                                    .transition(.scale)
//                            }
//                            Spacer()
//                            Text(showHistory ? "Hide History" : "View History")
//                            Button {
//                                showHistory.toggle()
//                            } label: {
//                                Image(systemName: showHistory ? "eye.slash" : "eye")
//                            }
//                            Spacer()
//                        }
//                        .padding()
//                        if showHistory {
//                            ZStack { if workoutHistory.isEmpty {
//                                ContentUnavailableView(label: {
//                                    Label("No history to list", systemImage: "list.bullet.rectangle.portrait")
//                                        .foregroundColor(.white)
//                                }, description: {
//                                    Text("Start by saving sessions to your workout history.")
//                                        .foregroundColor(.white)
//                                })
//                            } else {
//                                List {
//                                    ForEach(workoutHistory.filter { $0.exercise == exercise}.sorted(by: { $0.date > $1.date }), id: \.id) { entry in
//                                        StrengthEntryItem(entry: entry)
//                                    }
//                                    .padding(3)
//                                    .cornerRadius(10)
//                                    .listRowBackground(ColorPalette.accent.opacity(0.8))
//                                }
//                                .padding()
//                                .frame(height: 500)
//                                .scrollContentBackground(.hidden)
//                            }
//                            }
//                        }
//                    }
//                    .listStyle(PlainListStyle())
//                    .background(Color.clear)
//                    .padding()
//                    .font(.system(size: 18))
//                }
//                .background(Color.clear)
//            }
//        }
//    }
//    
//    func saveEntry() {
//        print(emptyEntry)
//        guard !(combined == 0 && left == 0 && right == 0) else {
//            emptyEntry = true
//            return
//        }
//        
//        emptyEntry = false
//        
//        let newEntry = StrengthEntry(
//            exercise: exercise,
//            date: Date(),
//            combined: Int(combined),
//            left: Int(left),
//            right: Int(right),
//            sets: sets,
//            reps: reps,
//            rest: rest,
//            note: note
//        )
//        context.insert(newEntry)
//        do {
//            try context.save()
//            
//            showCheckmark = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
//                showCheckmark = false
//            }
//        } catch {
//            print("Error saving context: \(error)")
//        }
//    }
//
//}
//
//#Preview {
//    WorkoutHistoryView(date: .constant(Date()), exercise: .constant("Incline Bench Press"), combined: .constant(0), left: .constant(0), right: .constant(0), sets: .constant(0), reps: .constant(0), rest: .constant(0), note: .constant("") )
//}
//
//struct StrengthEntryItem: View {
//    @Environment(\.modelContext) var context
//    @State private var showHistoryItemDeleteAlert: Bool = false
//    @State var entry: StrengthEntry
//
//    var body: some View {
//        var dateFormatter: DateFormatter {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM/dd/yyyy HH:mm"
//            return formatter
//        }
//        let formattedDate = dateFormatter.string(from: entry.date)
//
//        VStack {
//            Text(formattedDate)
//                .font(.title2)
//            HStack {
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text("Weight:")
//                        Text("\(entry.combined)")
//                            .foregroundColor(.white)
//                    }
//                    Text("Left Isolated: \(entry.left)")
//                        .foregroundColor(.white)
//                    Text("Right Isolated: \(entry.right)")
//                        .foregroundColor(.white)
//                }
//                VStack(alignment: .leading) {
//                    Text("Sets: \(entry.sets)")
//                        .foregroundColor(.white)
//                    Text("Reps: \(entry.reps)")
//                        .foregroundColor(.white)
//                    Text("Rest: \(entry.rest)")
//                        .foregroundColor(.white)
//                }
//            }
//            Text("Note: \(entry.note)")
//        }
//        .swipeActions(edge: .trailing) {
//            Button(role: .destructive) {
//                showHistoryItemDeleteAlert = true
//                print("Delete button tapped for entry ID: \(entry.id)")
//                print(context)
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//            .tint(.red)
//        }
//        .alert(isPresented: $showHistoryItemDeleteAlert) {
//           Alert(
//               title: Text("Delete Entry"),
//               message: Text("Are you sure you want to delete this entry?"),
//               primaryButton: .destructive(Text("Delete")) {
//                   deleteEntry()
//               },
//               secondaryButton: .cancel() {
//                   print("Delete canceled")
//               }
//           )
//       }
//    }
//
//    private func deleteEntry() {
//        print("Attempting to delete entry with ID: \(entry.id)")
//        context.delete(entry)
//        do {
//            try context.save()
//            print("Successfully deleted entry with ID: \(entry.id)")
//        } catch {
//            print("Error saving context after deletion: \(error)")
//        }
//    }
//}
