import SwiftUI
import UIKit

struct WeightInput: View {
    @EnvironmentObject var workoutHistory: WorkoutHistory // Injecting the WorkoutHistory instance
    var defaults = UserDefaults.standard
    var id: UUID = UUID()
    @State var Exercise: String
    @State var WeightLeft: Int
    @State var WeightRight: Int
    @State var Weight: Int
    @State var Note: String
    @State var Iso: Bool = false
    @State var ShowHistory: Bool = false
    @State var Confirmation: Bool = false
    @State private var itemToDelete: WeightEntry?
    @State private var showConfirmationDialog = false

    var body: some View {
        let date: String = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
                return dateFormatter.string(from: Date())
            }()
        VStack(alignment: .leading) {
            HStack {
                Text(Exercise)
                    .foregroundColor(Color.white)
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if (Iso == false) {
                        Button {
                            Iso = true
                            defaults.set(Iso, forKey: "Iso \(id)")
                        } label: {
                            Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                .foregroundColor(Color.white)
                        }
                    }
                    if (Iso == true) {
                        Button {
                            Iso = false
                        } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                .foregroundColor(Color.white)
                        }
                    }
                    // Isolated Left and Right Weight entries
                    if (Iso == true) {
                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-5)
                            TextField("Weight", value: $WeightLeft, format: .number, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.3)))
                                // Saves Weight entered on change of TextField
                                .onChange(of: WeightLeft) {
                                    defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .foregroundColor(Color.white)
                                .padding(-3)
                            
                        }
                        .padding(0)
                        VStack {
                            Text("Right")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-5)
                            TextField("Weight", value: $WeightRight, format: .number, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.3)))
                            // Saves Weight entered on change of TextField
                                .onChange(of: WeightRight) {
                                    defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .padding(-3)
                                .foregroundColor(Color.white)
                            
                        }
                    }
                    // Singular wright entry
                    if (Iso == false) {
                        VStack {
                            TextField("Weight", value: $Weight, format: .number, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.3)))
                            // Saves Weight entered on change of TextField
                                .onChange(of: Weight) {
                                    defaults.set(Weight, forKey: Exercise + "Weight")
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .padding(-3)
                                .foregroundColor(Color.white)
                                .lineLimit(1...4)
                            
                        }
                        .padding(0)
                    }
                }
                .padding(0)
            }
            // TextField for entering notes
            VStack {
                TextField("Note", text: $Note, prompt: Text("Note").foregroundColor(Color.white.opacity(0.3)), axis: .vertical)
                // Saves Note entered on change of TextField
                    .onChange(of: Note){
                        defaults.set(Note, forKey: Exercise + "Note")
                    }
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color.blue.opacity(0.8).cornerRadius(10))
                    .padding(-3)
                    .foregroundColor(Color.white)
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
            .padding(5)
        }
        // Saving and displaying Weight and Note history
        VStack {
            HStack {
                HStack {
                    Text("Save")
                        .font(.headline)
                    Button {
                        if let encoded = try? JSONEncoder().encode(workoutHistory) {
                                            defaults.set(encoded, forKey: "History\(id)")
                                         }
                        
                        let newEntry = WeightEntry(exercise: $Exercise.wrappedValue, date: date, weight: $Weight.wrappedValue, left: $WeightLeft.wrappedValue, right: $WeightRight.wrappedValue, note: $Note.wrappedValue)
                        workoutHistory.history.append(newEntry)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .foregroundStyle(.white)    
                }
                // Displays Exercise weight history for weights
                HStack {
                    Text("History")
                       .font(.headline)
                   Button {
                       ShowHistory.toggle()
                       print(workoutHistory.history)
                       print($Exercise)
                   } label: {
                       Image(systemName: ShowHistory ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                   }
                   .foregroundStyle(.white)
                }
            }
            // History component displays on Expand button click
            if (ShowHistory) {
                List {
                    ForEach(workoutHistory.history, id:\.id) { item in
                        HStack{
                            VStack(alignment: .leading) {
                                Text(item.date)
                                Text("Weight: \(item.weight)")
                                Text("Left Isolated: \(item.left)")
                                Text("Right Isolated: \(item.right)")
                            }
                            .padding(2.5)
                            
                            // Encodes JSON and saved to UserDefaults
                            Button {
                                itemToDelete = item
                                showConfirmationDialog = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .listRowBackground(Color.blue.opacity(0.5))
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
    WeightInput(Exercise: "", WeightLeft: 0, WeightRight: 0, Weight: 0, Note: "")
        .environmentObject(WorkoutHistory())
}

