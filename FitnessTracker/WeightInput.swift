import SwiftUI
import UIKit

struct WeightInput: View {
    let Exercise: String
    var defaults = UserDefaults.standard
    @State var WeightLeft: String
    @State var WeightRight: String
    @State var Note: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Exercise)
                    .font(.headline)
                    .frame(minWidth: 100, alignment: .leading)
                    .scaledToFit()
                Spacer()
                HStack {
                    VStack {
                        Text("Left")
                            .font(.system(size: 14))
                        TextField("Weight", text: $WeightLeft)
                            .onChange(of: WeightLeft) {
                                defaults.set(WeightLeft, forKey: Exercise + "WeightLeft")
                            }
                            .padding()
//                            .background(Color.blue)
                            .cornerRadius(8)
                            .textFieldStyle(.roundedBorder)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    }
                    VStack {
                        Text("Right")
                            .font(.system(size: 14))
                        TextField("Weight", text: $WeightRight)
                            .onChange(of: WeightRight) {
                                defaults.set(WeightRight, forKey: Exercise + "WeightRight")
                            }
                            .textFieldStyle(.roundedBorder)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    }
                }
            }
            .padding(.vertical, 5)
            TextField("Note", text: $Note, axis: .vertical)
                .onChange(of: Note){
                    defaults.set(Note, forKey: Exercise + "Note")
            }
                .textFieldStyle(.roundedBorder)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .lineLimit(1...4)
        }
        .padding()
    }
}

#Preview {
    WeightInput(Exercise: "Deadlift", WeightLeft: "", WeightRight: "",Note: "")
}
