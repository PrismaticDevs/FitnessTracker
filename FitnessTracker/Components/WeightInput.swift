import SwiftUI
import UIKit

struct WeightInput: View {
    let Exercise: String
    var defaults = UserDefaults.standard
    @State var WeightLeft: Int
    @State var WeightRight: Int
    @State var Weight: Int
    @State var Note: String
    @State var Expand: Bool = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Exercise)
                    .foregroundColor(Color.white)
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if (Expand == false) {
                        Button {
                            Expand = true
                        } label: {
                            Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                .foregroundColor(Color.white)
                        }
                    }
                    if (Expand == true) {
                        Button {
                            Expand = false
                        } label: {
                            Image(systemName: "arrow.right.and.line.vertical.and.arrow.left")
                                .foregroundColor(Color.white)
                        }
                    }
                    if (Expand == true) {
                        VStack {
                            Text("Left")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(-5)
                            TextField("Weight", value: $WeightLeft, format: .number, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.3)))
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
                    if (Expand == false) {
                        VStack {
                            TextField("Weight", value: $Weight, format: .number, prompt: Text("Weight").foregroundColor(Color.white.opacity(0.3)))
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
            TextField("Note", text: $Note, prompt: Text("Note").foregroundColor(Color.white.opacity(0.3)), axis: .vertical)
                .onChange(of: Note){
                    defaults.set(Note, forKey: Exercise + "Note")
            }
                .lineLimit(1...4)
                .padding(10)
                .background(Color.blue.opacity(0.8).cornerRadius(10))
                .padding(-3)
                .foregroundColor(Color.white)
                .overlay(
                            Button(action: {
                                Note = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .opacity(Note.isEmpty ? 0 : 1).padding()
                                }
                                    .padding(),
                                    alignment: .trailing
                        )
        }
        .padding()
    }
}

#Preview {
    WeightInput(Exercise: "Deadlift", WeightLeft: 0, WeightRight: 0, Weight: 0, Note: "")
}
