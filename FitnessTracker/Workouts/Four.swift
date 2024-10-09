import SwiftUI

struct Four: View {
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    var defaults = UserDefaults.standard
    var body: some View {
        
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) { // Add some spacing between elements
                        WeightInput(Exercise: "Deadlift", WeightLeft: defaults.string(forKey: "DeadliftWeightLeft") ?? "", WeightRight: defaults.string(forKey:     "DeadliftWeightRight") ?? "", Weight: defaults.string(forKey: "DeadfliftWeight") ?? "", Note: defaults.string(forKey: "DeadliftNote") ?? "")
                        WeightInput(Exercise: "Lying Leg Curl", WeightLeft: defaults.string(forKey: "Lying Leg CurlWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Lying Leg CurlWeightRight") ?? "", Weight: defaults.string(forKey: "Lying Leg CurlWeight") ?? "", Note: defaults.string(forKey: "Lying Leg CurlNote") ?? "")
                        WeightInput(Exercise: "Walking Lunge", WeightLeft: defaults.string(forKey: "Walking LungeWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Walking LungeWeightRight") ?? "", Weight: defaults.string(forKey: "Walking LungeWeight") ?? "", Note: defaults.string(forKey: "Walking LungeNote") ?? "")
                        WeightInput(Exercise: "Hack Squat", WeightLeft: defaults.string(forKey: "Hack SquatWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Hack SquatWightRight") ?? "", Weight: defaults.string(forKey: "Hack SquatWeight") ?? "", Note: defaults.string(forKey: "Hack SquatNote") ?? "")
                        WeightInput(Exercise: "Leg Extension", WeightLeft: defaults.string(forKey: "Leg ExtensionWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Leg ExtensionWeightRight") ?? "", Weight: defaults.string(forKey: "Leg ExtensionWeight") ?? "", Note: defaults.string(forKey: "Leg ExtensionNote") ?? "")
                        WeightInput(Exercise: "Seated Calf Raise", WeightLeft: defaults.string(forKey: "Seated Calf RaiseWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Seated Calf RaiseWeightRight") ?? "", Weight: defaults.string(forKey: "Seated Calf RaiseWeight") ?? "", Note: defaults.string(forKey: "Seated Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Hip Abduction", WeightLeft: defaults.string(forKey: "Hip AbductionWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Hip AbductionWeightRight") ?? "", Weight: defaults.string(forKey: "Hip AbductionWeight") ?? "", Note: defaults.string(forKey: "Hip AbductionNote") ?? "")
                        WeightInput(Exercise: "Standing Calf Raise", WeightLeft: defaults.string(forKey: "Standing Calf RaiseWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Standing Calf RaiseWeightRight") ?? "", Weight: defaults.string(forKey: "Standing Calf RaiseWeight") ?? "", Note: defaults.string(forKey: "Standing Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Calf Press", WeightLeft: defaults.string(forKey: "Calf PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Calf PressWeightRight") ?? "", Weight: defaults.string(forKey: "Calf PRessWeight") ?? "", Note: defaults.string(forKey: "Calf PressNote") ?? "")
                        WeightInput(Exercise: "Leg Press", WeightLeft: defaults.string(forKey: "Leg PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Leg PressWeightRight") ?? "", Weight: defaults.string(forKey: "Leg PressWeight") ?? "", Note: defaults.string(forKey: "Leg PressNote") ?? "")
                    }
                    .padding() // Padding around the VStack
                }
                .padding(.top, 1)
                .navigationTitle("Chest & Side Delts")
//                .background(Color.cyan)
            }
        }
        .padding(.top, -120)
    }
}

#Preview {
    Four()
}
