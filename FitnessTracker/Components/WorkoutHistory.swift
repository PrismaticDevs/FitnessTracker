////
////  WorkoutHistory.swift
////  FitnessTracker
////
////  Created by Matt on 3/3/25.
////
//import SwiftUI
//import SwiftData
//
//import SwiftUI
//import SwiftData
//
//struct WorkoutHistoryView: View {
//    @Environment(\.modelContext) var context
//    @Environment(\.defaultMinListRowHeight) var minRowHeight
//    @Query var workoutHistory: [WorkoutEntry]
//
//    // Bindings (simplified)
//    @Binding var date: Date
//    @Binding var exercise: String
//    @Binding var setsCountInput: String
//    @Binding var combinedInputs: [String]
//    @Binding var leftInputs: [String]
//    @Binding var rightInputs: [String]
//    @Binding var repsInputs: [String]
//    @Binding var restInputs: [String]
//    @Binding var note: String
//
//    @State private var showHistory: Bool = false
//    @State private var emptyEntry: Bool = false
//    @State private var showCheckmark: Bool = false
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                HStack {
//                    Spacer()
//                    Button {
//                        saveEntry()
//                    } label: {
//                        HStack { Image(systemName: "square.and.arrow.down"); Text("Save") }
//                    }
//                    .alert(isPresented: $emptyEntry) {
//                        Alert(title: Text("Error"), message: Text("No valid entry to save. All weight fields are empty."), dismissButton: .default(Text("OK")))
//                    }
//
//                    if showCheckmark {
//                        HStack {
//                            Image(systemName: "checkmark").foregroundColor(.green)
//                            Text("Saved").foregroundColor(.green)
//                        }
//                        .transition(.scale)
//                    }
//
//                    Spacer()
//
//                    Button {
//                        showHistory.toggle()
//                    } label: {
//                        HStack { Image(systemName: showHistory ? "eye.slash" : "eye"); Text(showHistory ? "Hide History" : "View History") }
//                    }
//
//                    Spacer()
//                }
//                .padding()
//
//                if showHistory {
//                    if workoutHistory.filter({ $0.exercise == exercise }).isEmpty {
//                        ContentUnavailableView(label: {
//                            Label("No history to list", systemImage: "list.bullet.rectangle.portrait")
//                                .foregroundColor(.white)
//                        }, description: {
//                            Text("Start by saving sessions to your workout history.")
//                                .foregroundColor(.white)
//                        })
//                    } else {
//                        List {
//                            ForEach(workoutHistory.filter { $0.exercise == exercise }.sorted(by: { $0.date > $1.date }), id: \.id) { entry in
//                                WorkoutEntryItem(entry: entry)
//                                    .listRowBackground(Color.blue.opacity(0.8))
//                            }
//                        }
//                        .frame(height: 500)
//                        .scrollContentBackground(.hidden)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//
//    func saveEntry() {
//        // require at least combined OR (left and right)
//        guard !(combined == 0 && (left == 0 && right == 0)) else {
//            emptyEntry = true
//            return
//        }
//        emptyEntry = false
//
//        // convert string inputs
//        let setsCount = max(1, Int(sets) ?? 1)
//        let repsValue = Int(reps)
//        let restValue = Int(rest)
//
//        // Build WorkoutEntry — adjust initializer to your model
//        let newEntry = WorkoutEntry(
//            date: Date(),
//            sets: setsCount,
//            reps: reps,
//            rest: rest,
//            note: note,
//            combined: combined,
//            left: left,
//            right: right
//        )
//
//        context.insert(newEntry)
//        do {
//            try context.save()
//            showCheckmark = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { showCheckmark = false }
//        } catch {
//            print("Error saving context: \(error)")
//        }
//    }
//}
//
//#Preview {
//    WorkoutHistoryView(
//        date: .constant(Date()),
//        exercise: .constant("Incline Bench Press"),
//        combined: .constant(0),
//        left: .constant(0),
//        right: .constant(0),
//        sets: .constant("1"),
//        reps: .constant(0),
//        rest: .constant(0),
//        note: .constant("")
//    )
//}
//
//struct WorkoutEntryItem: View {
//    @Environment(\.modelContext) var context
//    @State private var showHistoryItemDeleteAlert: Bool = false
//    @State var entry: WorkoutEntry
//
//    var body: some View {
//        let dateFormatter: DateFormatter = {
//            let f = DateFormatter()
//            f.dateFormat = "MM/dd/yyyy HH:mm"
//            return f
//        }()
//        let formattedDate = dateFormatter.string(from: entry.date)
//
//        VStack(alignment: .leading) {
//            Text(formattedDate).font(.title2)
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Combined: \(entry.combined)").foregroundColor(.white)
//                    Text("Left Isolated: \(entry.left)").foregroundColor(.white)
//                    Text("Right Isolated: \(entry.right)").foregroundColor(.white)
//                }
//                VStack(alignment: .leading) {
//                    Text("Sets: \(entry.sets)").foregroundColor(.white)
//                    Text("Reps: \(entry.reps)").foregroundColor(.white)
//                    Text("Rest: \(entry.rest)").foregroundColor(.white)
//                }
//            }
//            Text("Note: \(entry.note)")
//        }
//        .swipeActions(edge: .trailing) {
//            Button(role: .destructive) {
//                showHistoryItemDeleteAlert = true
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//            .tint(.red)
//        }
//        .alert(isPresented: $showHistoryItemDeleteAlert) {
//            Alert(
//                title: Text("Delete Entry"),
//                message: Text("Are you sure you want to delete this entry?"),
//                primaryButton: .destructive(Text("Delete")) { deleteEntry() },
//                secondaryButton: .cancel()
//            )
//        }
//    }
//
//    private func deleteEntry() {
//        context.delete(entry)
//        do { try context.save() } catch { print("Error saving context after deletion: \(error)") }
//    }
//}
