import SwiftUI
import UIKit

struct WeightInput: View {
    let Exercise: String
    var defaults = UserDefaults.standard
    @State var WeightLeft: String
    @State var WeightRight: String
    @State var Weight: String
    @State var Note: String
    @State private var Expand: Bool = true

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
                                .foregroundColor(Color.secondary)
                        }
                    }
                    if (Expand == true) {
                        Button {
                            Expand = false
                        } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                .foregroundColor(Color.secondary)
                        }
                    }
                    if (Expand == true) {
                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-5)
                            TextField("Weight", text: $WeightLeft, prompt: Text("Weight").foregroundColor(Color.primary.opacity(0.3)))
                                .onChange(of: WeightLeft) {
                                    defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .padding(-3)
                        }
                        .padding(0)
                        VStack {
                            Text("Right")
                                .font(.system(size: 14))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-5)
                            TextField("Weight", text: $WeightRight, prompt: Text("Weight").foregroundColor(Color.primary.opacity(0.3)))
                                .onChange(of: WeightRight) {
                                    defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .padding(-3)
                        }
                    }
                    if (Expand == false) {
                        VStack {
                            TextField("Weight", text: $Weight, prompt: Text("Weight").foregroundColor(Color.primary.opacity(0.3)))
                                .onChange(of: Weight) {
                                    defaults.set(Weight, forKey: Exercise + "Weight")
                                }
                                .lineLimit(1...4)
                                .padding(10)
                                .background(Color.blue.opacity(0.8).cornerRadius(10))
                                .padding(-3)
                        }
                        .padding(0)
                    }
                }
                .padding(0)
            }
            TextField("Note", text: $Note, prompt: Text("Note").foregroundColor(Color.primary.opacity(0.3)))
                .onChange(of: Note){
                    defaults.set(Note, forKey: Exercise + "Note")
            }
                .lineLimit(1...4)
                .padding(10)
                .background(Color.blue.opacity(0.8).cornerRadius(10))
                .padding(-3)
        }
        .padding()
    }
}

#Preview {
    WeightInput(Exercise: "Deadlift", WeightLeft: "", WeightRight: "", Weight: "", Note: "")
}
