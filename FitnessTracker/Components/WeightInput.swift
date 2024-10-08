import SwiftUI
import UIKit

struct WeightInput: View {
    let Exercise: String
    var defaults = UserDefaults.standard
    @State var WeightLeft: String
    @State var WeightRight: String
    @State var Weight: String
    @State var Note: String
    @State private var Expand: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Exercise)
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if (Expand == false) {
                        Button {
                            Expand = true
                        } label: {
                            Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                        }
                    }
                    if (Expand == true) {
                        Button {
                            Expand = false
                        } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                        }
                    }
                    if (Expand == true) {
                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-8)
                            TextField("Weight", text: $WeightLeft)
                                .onChange(of: WeightLeft) {
                                    defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                                }
                                .cornerRadius(8)
                                .textFieldStyle(.roundedBorder)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        }
                        .padding(0)
                        VStack {
                            Text("Right")
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-8)
                            TextField("Weight", text: $WeightRight)
                                .onChange(of: WeightRight) {
                                    defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                                }
                                .textFieldStyle(.roundedBorder)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        }
                    }
                    if (Expand == false) {
                        VStack {
                            TextField("Weight", text: $Weight)
                                .onChange(of: Weight) {
                                    defaults.set(Weight, forKey: Exercise + "Weight")
                                }
                                .cornerRadius(8)
                                .textFieldStyle(.roundedBorder)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        }
                        .padding(0)
                    }
                }
                .padding(0)
            }
            TextField("Note", text: $Note, axis: .vertical)
                .onChange(of: Note){
                    defaults.set(Note, forKey: Exercise + "Note")
            }
                .textFieldStyle(.roundedBorder)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .lineLimit(1...4)
                .padding(-3)
        }
        .padding()
    }
}

#Preview {
    WeightInput(Exercise: "Deadlift", WeightLeft: "", WeightRight: "", Weight: "", Note: "")
}
