import SwiftUI
import UIKit

struct WeightInput: View {
    @EnvironmentObject var workoutHistory: WorkoutHistory // Injecting the WorkoutHistory instance
    var defaults = UserDefaults.standard
    var id: UUID = UUID()
    @State var Exercise: String = ""
    @State var WeightLeft: String = ""
    @State var WeightRight: String = ""
    @State var Weight: String = ""
    @State var Note: String = ""
    @State var Sets: String = ""
    @State var Reps: String = ""
    @State var Rest: String = ""
    @State var Iso: Bool = false
    @State var ShowHistory: Bool = false
    @State var Confirmation: Bool = false
    @State private var itemToDelete: WeightEntry?
    @State private var showConfirmationDialog = false
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            return formatter
        }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Exercise)
                    .foregroundColor(Color.white)
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if (!Iso) {
//                        Text("Weight")
//                            .font(.system(size: 14))
                        Button {
                            Iso = true
                            defaults.set(Iso, forKey: "Iso \(id)")
                        } label: {
                            Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                .foregroundColor(Color.white)
                        }
                    }
                    if (Iso) {
                        Button {
                            Iso = false
                        } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                .foregroundColor(Color.white)
                        }
                    }
                    // Isolated Left and Right Weight entries
                    if (Iso) {
                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-4)
                            TextField("Weight", text: $WeightLeft, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.5)))
                                // Saves Weight entered on change of TextField
                                .onChange(of: WeightLeft) {
                                    defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .foregroundColor(Color.white)
                            
                        }
                        .padding(0)
                        VStack {
                            Text("Weight Right")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(-4)
                            TextField("Weight", text: $WeightRight, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.5)))
                            // Saves Weight entered on change of TextField
                                .onChange(of: WeightRight) {
                                    defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .foregroundColor(Color.white)
                            
                        }
                    }
                    // Singular weight entry
                    if (!Iso) {
                        VStack {
                            Text("Weight")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(-4)
                            TextField("Weight", text: $Weight, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.5)))
                            // Saves Weight entered on change of TextField
                                .onChange(of: Weight) {
                                    defaults.set(Weight, forKey: Exercise + "Weight")
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .foregroundColor(Color.white)
                                .lineLimit(1...4)
                            
                        }
                        .padding(0)
                    }
                }
                .padding(0)
            }
            // Sets, Reps, and Rest
            VStack {
                HStack {
                    VStack {
                        Text("Sets")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(-6)
                        TextField("Sets", text: $Sets, prompt: Text("Sets").foregroundColor(Color.white.opacity(0.5)), axis: .vertical)
                            .onChange(of: Sets){
                                defaults.set(Sets, forKey: Exercise + "Sets")
                            }
                            .lineLimit(1...4)
                            .padding(10)
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .foregroundColor(Color.white)
                    }
                    VStack {
                        Text("Reps")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(-4)
                        TextField("Reps", text: $Reps, prompt: Text("Reps").foregroundColor(Color.white.opacity(0.5)), axis: .vertical)
                            .onChange(of: Reps){
                                defaults.set(Reps, forKey: Exercise + "Reps")
                            }
                            .lineLimit(1...4)
                            .padding(10)
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .foregroundColor(Color.white)
                    }
                    VStack {
                        Text("Rest")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(-6)
                        TextField("Rest", text: $Rest, prompt: Text("Rest").foregroundColor(Color.white.opacity(0.5)), axis: .vertical)
                            .onChange(of: Rest){
                                defaults.set(Rest, forKey: Exercise + "Rest")
                            }
                            .lineLimit(1...4)
                            .padding(10)
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .foregroundColor(Color.white)
                    }

                }
                .padding(0)
            }
            .padding(0)
            // TextField for entering notes
            VStack {
                Text("Note")
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(-4)
                HStack {
                    TextField("Note", text: $Note, prompt: Text("Note").foregroundColor(Color.white.opacity(0.5)), axis: .vertical)
                    // Saves Note entered on change of TextField
                        .onChange(of: Note){
                            defaults.set(Note, forKey: Exercise + "Note")
                        }
                        .lineLimit(1...4)
                        .padding(10)
                        .background(Color.blue.opacity(0.8).cornerRadius(10))
                        .foregroundColor(Color.white)
//                        .shadow(color: Color.black.opacity(0.8), radius: 1, x: 0, y: 3)
                    // Overlayed Button to clear Note TextField
                        .overlay(
                            Button(action: {
                                Note = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .opacity(Note.isEmpty ? 0 : 1).padding()
                            }
                                .foregroundColor(Color.white)
                                .padding(),
                            alignment: .trailing
                        )
                }
                .padding(0)
            }
            .padding(0)
        }

        // Saving and displaying Weight and Note history
        VStack {
            HStack {
                HStack {
                    Text("Save")
                        .font(.headline)
                    Button {
                        let newEntry = WeightEntry(exercise: $Exercise.wrappedValue, date: Date(), weight: $Weight.wrappedValue, left: $WeightLeft.wrappedValue, right: $WeightRight.wrappedValue, sets: $Sets.wrappedValue, reps: $Reps.wrappedValue, rest: $Rest.wrappedValue, note: $Note.wrappedValue)
                        workoutHistory.history.append(newEntry)
                        if let encoded = try? JSONEncoder().encode(workoutHistory) {
                                            defaults.set(encoded, forKey: "History\(id)")
                                         }
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .foregroundStyle(.white)    
                }
                // Displays Exercise weight history for weights
                HStack {
                    Text("See History")
                       .font(.headline)
                   Button {
                       ShowHistory.toggle()
                   } label: {
                       Image(systemName: ShowHistory ? "eye.slash" : "eye")
                   }
                   .foregroundStyle(.white)
                }
            }
            // History component displays on Expand button click
            if (ShowHistory) {
                let sortedItems = workoutHistory.history
                                .filter { $0.exercise == Exercise }
                                .sorted(by: { $0.date > $1.date })
                let maxWeight = sortedItems.max(by: { $0.weight < $1.weight })?.weight
                let maxLeft = sortedItems.max(by: { $0.left < $1.left })?.left
                let maxRight = sortedItems.max(by: { $0.right < $1.right })?.right
//                List {
                    ForEach(workoutHistory.history.filter { $0.exercise == Exercise }.sorted(by: { $0.date > $1.date }), id: \.id) { item in
                        VStack {
                            HStack{
                                VStack(alignment: .leading) {
                                    let formattedDate = dateFormatter.string(from: item.date)
                                    Text(formattedDate)
                                    Text("Weight: \(item.weight)")
                                        .foregroundColor(item.weight == maxWeight ? Color.yellow : Color.primary)
                                    Text("Left Isolated: \(item.left)")
                                        .foregroundColor(item.left == maxLeft ? Color.yellow : Color.primary)
                                    Text("Right Isolated: \(item.right)")
                                        .foregroundColor(item.right == maxRight ? Color.yellow : Color.primary)
                                }
                                VStack {
                                    Text("Sets: \(item.sets)")
                                    Text("Reps: \(item.reps)")
                                    Text("Rest: \(item.rest)")
                                }
                                Spacer()
                                // Encodes JSON and saved to UserDefaults
                                Button {
                                    itemToDelete = item
                                    showConfirmationDialog = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Notes: \(item.note)")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .cornerRadius(10)
                        .background(Color.blue.opacity(0.8).cornerRadius(10))
//                        .shadow(color: Color.black.opacity(0.8), radius: 1, x: 0, y: 3)


//                        .listRowBackground(Color.blue.opacity(0.5))
//                    }
                }
                .confirmationDialog("Are you sure you want to delete this item?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        if let itemToDelete = itemToDelete {
                            // Perform the deletion
                            if let index = workoutHistory.history.firstIndex(of: itemToDelete) {
                                workoutHistory.deleteEntry(at: index)
                            } else {
                                // Handle the case where the item is not found
                                print("Item to delete not found in history.")
                            }
                        }
                        // Reset itemToDelete after deletion
                        self.itemToDelete = nil
                    }

                    Button("Cancel", role: .cancel) {
                        // Cancel action
                        self.itemToDelete = nil
                    }
                        }
                .confirmationDialog("Are you sure you want to delete this item?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                                       Button("Delete", role: .destructive) {
                                           if let itemToDelete = itemToDelete,
                                              let index = workoutHistory.history.firstIndex(of: itemToDelete) {
                                               workoutHistory.deleteEntry(at: index) // Use the deleteEntry method from WorkoutHistory
                                           }
                                           self.itemToDelete = nil
                                       }
                                       Button("Cancel", role: .cancel) {
                                           self.itemToDelete = nil
                                       }
            }
        }
        }
    }
}

#Preview {
    WeightInput(Exercise: "", WeightLeft: "", WeightRight: "", Weight: "", Note: "", Sets: "", Reps: "", Rest: "")
        .environmentObject(WorkoutHistory())
}

