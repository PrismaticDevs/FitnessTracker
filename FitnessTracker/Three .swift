import SwiftUI

struct Three: View {
//    var bckGrdGradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    let defaults = UserDefaults.standard
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 15) { // Vertical stack for all Exercises
                        // First Exercise with weight input
                        WeightInput(Exercise: "Chest Press", Weight: defaults.string(forKey: "Chest PressWeight") ?? "", Note: defaults.string(forKey: "Chest PressNote") ?? "")
                        
                        // "Dip" aligned and bolded like in WeightInput, moved slightly right
                        HStack {
                            Text("Dip")
                                .bold() // Apply bold style
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20) // Adjust the leading padding to move right
                        }

                        // Tricep Extension Machine with weight input
                        WeightInput(Exercise: "Tricep Extension Machine", Weight: defaults.string(forKey: "Tricep Extension MachineWeight") ?? "", Note: defaults.string(forKey: "Tricep Extension MachineNote") ?? "")
                        
                        // Another weight input component
                        WeightInput(Exercise: "Triceps Press", Weight: defaults.string(forKey:  "Triceps PressWeight") ?? "", Note: defaults.string(forKey: "Triceps PressNote") ?? "")
                        
                        // "Leg Raise" aligned and bolded like in WeightInput, moved slightly right
                        HStack {
                            Text("Leg Raise")
                                .bold() // Apply bold style
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20) // Adjust the leading padding to move right
                        }

                        // Abdominal Machine with weight input
                        WeightInput(Exercise: "Abdominal Machine", Weight: defaults.string(forKey: "Abdominal MachineWeight") ?? "", Note: defaults.string(forKey: "Abdominal MachineNote") ?? "")
                        
                        // Additional weight input components
                        WeightInput(Exercise: "Hammer Curl", Weight: defaults.string(forKey: "Hammer CurlWeight") ?? "", Note: defaults.string(forKey: "Hammer CurlNote") ?? "")
                        WeightInput(Exercise: "Preacher Curl Machine", Weight: defaults.string(forKey: "Preacher CurlMachineWeight") ?? "", Note: defaults.string(forKey: "Preacher CurlMachineNote") ?? "")
                        WeightInput(Exercise: "Biceps Curl Machine", Weight: defaults.string(forKey:    "Biceps Curl MachineWeight") ?? "", Note: defaults.string(forKey: "Biceps Curl MachineNote") ?? "")
                    }
                    .padding()
                }
                .padding(.top, 1)
                .navigationTitle("Arms & Abs")
                .background(Color.cyan)
            }
        }
        .padding(.top, -100)
    }
}

#Preview {
    Three()
}
