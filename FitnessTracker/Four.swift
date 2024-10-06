import SwiftUI

struct Four: View {
    var defaults = UserDefaults.standard
    var body: some View {
        
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) { // Add some spacing between elements
                        WeightInput(Exercise: "Deadlift", Weight: defaults.string(forKey: "DeadliftWeight") ?? "", Note: defaults.string(forKey: "DeadliftNote") ?? "")
                        WeightInput(Exercise: "Lying Leg Curl", Weight: defaults.string(forKey: "Lying Leg CurlWeight") ?? "", Note: defaults.string(forKey: "Lying Leg CurlNote") ?? "")
                        WeightInput(Exercise: "Walking Lunge", Weight: defaults.string(forKey: "Walking LungeWeight") ?? "", Note: defaults.string(forKey: "Walking LungeNote") ?? "")
                        WeightInput(Exercise: "Hack Squat", Weight: defaults.string(forKey: "Back SquatWeight") ?? "", Note: defaults.string(forKey: "Back SquatNote") ?? "")
                        WeightInput(Exercise: "Leg Extension", Weight: defaults.string(forKey: "Leg ExtensionWeight") ?? "", Note: defaults.string(forKey: "Leg ExtensionNote") ?? "")
                        WeightInput(Exercise: "Seated Calf Raise", Weight: defaults.string(forKey: "Calf RaiseWeight") ?? "", Note: defaults.string(forKey: "Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Hip Abduction", Weight: defaults.string(forKey: "Hip AbductionWeight") ?? "", Note: defaults.string(forKey: "Hip AbductionNote") ?? "")
                        WeightInput(Exercise: "Standing Calf Raise", Weight: defaults.string(forKey: "Standing Calf RaiseWeight") ?? "", Note: defaults.string(forKey: "Standing Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Calf Press", Weight: defaults.string(forKey: "Calf PressWeight") ?? "", Note: defaults.string(forKey: "Calf PressNote") ?? "")
                        WeightInput(Exercise: "Leg Press", Weight: defaults.string(forKey: "Leg PressWeight") ?? "", Note: defaults.string(forKey: "Leg PressNote") ?? "")
                    }
                    .padding() // Padding around the VStack
                }
                .padding(.top, 1)
                .navigationTitle("Chest & Side Delts")
                .background(Color.cyan)
            }
        }
        .padding(.top, -100)
    }
}

#Preview {
    Four()
}
