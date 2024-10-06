import SwiftUI
import UIKit

struct WeightInput: View {
    let Exercise: String
    var defaults = UserDefaults.standard
    @State var Weight: String
    @State var Note: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Exercise name and weight input horizontally aligned
                Text(Exercise)
                    .font(.headline) // You can adjust the font style
                    .frame(minWidth: 100, alignment: .leading) // Control the size/alignment of the exercise label
                Spacer()
                TextField("Weight", text: $Weight)
                    .onChange(of: Weight) {
                        defaults.set(Weight, forKey: Exercise + "Weight")
                    }
                    .textFieldStyle(.roundedBorder)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)


            }
            .padding(.vertical, 5) // Add padding between elements
            
            // Note input field below
            TextField("Note", text: $Note)
                .onChange(of: Note){
                    defaults.set(Note, forKey: Exercise + "Note")
            }
                .textFieldStyle(.roundedBorder)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
        }
        .padding()
    }
}

#Preview {
    WeightInput(Exercise: "Deadlift", Weight: "", Note: "")
}
