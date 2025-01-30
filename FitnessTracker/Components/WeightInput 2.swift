import SwiftUI
import UIKit

struct WeightInput2: View {
    var defaults = UserDefaults.standard
    var id: UUID = UUID()
    @State var Exercise: String
    @State var WeightLeft: Int
    @State var WeightRight: Int
    @State var Weight: Int
    @State var Note: String
    @State var Expand: Bool = true
    @State var ShowHistory: Bool = false
    @State var History: [String] = []

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
                    if Expand {
                        Button { Expand.toggle() } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                .foregroundColor(Color.white)
                        }

                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .padding(-5)
                            TextField("Weight", value: $WeightLeft, format: .number)
                                .onChange(of: WeightLeft) {
                                    defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                                }
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
                                .padding(-5)
                            TextField("Weight", value: $WeightRight, format: .number)
                                .onChange(of: WeightRight) {
                                    defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                                }
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .foregroundColor(Color.white)
                                .padding(-3)
                        }
                    } else {
                        Button { Expand.toggle() } label: {
                            Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                .foregroundColor(Color.white)
                        }

                        TextField("Weight", value: $Weight, format: .number)
                            .onChange(of: Weight) {
                                defaults.set(Weight, forKey: Exercise + "Weight")
                            }
                            .padding(10)
                            .background(Color.blue.opacity(0.8).cornerRadius(10))
                            .foregroundColor(Color.white)
                            .padding(-3)
                    }
                }
            }

            VStack {
                TextField("Note", text: $Note, axis: .vertical)
                    .onChange(of: Note) {
                        defaults.set(Note, forKey: Exercise + "Note")
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.8).cornerRadius(10))
                    .foregroundColor(Color.white)
                    .overlay(
                        Button(action: { Note = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(Note.isEmpty ? 0 : 1)
                                .padding()
                        }
                        .foregroundColor(Color.white)
                        .padding(),
                        alignment: .trailing
                    )
            }
            .padding(5)

            VStack {
                HStack {
                    Text("Save")
                    Button {
                        saveHistory(weight: Weight, date: date)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .foregroundStyle(.white)

                    Text("History")
                    Button {
                        ShowHistory.toggle()
                    } label: {
                        Image(systemName: ShowHistory ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                    }
                    .foregroundStyle(.white)
                }
                if ShowHistory {
                    VStack(alignment: .leading) {
                        ForEach(History, id: \.self) { entry in
                            Text(entry)
                                .foregroundColor(.white)
                                .padding(5)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadHistory()
        }
    }

    // Function to load history from UserDefaults
    func loadHistory() {
        History = defaults.stringArray(forKey: Exercise + "History") ?? []
    }

    // Function to save history
    func saveHistory(weight: Int, date: String) {
        let entry = "\(date): \(weight) lbs"
        History.append(entry)
        defaults.set(History, forKey: Exercise + "History")
    }
}

#Preview {
    WeightInput2(Exercise: "Bench Press", WeightLeft: 0, WeightRight: 0, Weight: 135, Note: "")
}
