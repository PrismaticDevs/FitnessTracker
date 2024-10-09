import SwiftUI

struct Four: View {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    var defaults = UserDefaults.standard
    var body: some View {
        
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 15) {
                        WeightInput(Exercise: "Deadlift", WeightLeft: defaults.integer(forKey: "DeadliftWeightLeft"), WeightRight: defaults.integer(forKey:     "DeadliftWeightRight"), Weight: defaults.integer(forKey: "DeadliftWeight"), Note: defaults.string(forKey: "DeadliftNote") ?? "")
                        WeightInput(Exercise: "Lying Leg Curl", WeightLeft: defaults.integer(forKey: "Lying Leg CurlWeightLeft"), WeightRight: defaults.integer(forKey: "Lying Leg CurlWeightRight"), Weight: defaults.integer(forKey: "Lying Leg CurlWeight"), Note: defaults.string(forKey: "Lying Leg CurlNote") ?? "")
                        WeightInput(Exercise: "Walking Lunge", WeightLeft: defaults.integer(forKey: "Walking LungeWeightLeft"), WeightRight: defaults.integer(forKey: "Walking LungeWeightRight"), Weight: defaults.integer(forKey: "Walking LungeWeight"), Note: defaults.string(forKey: "Walking LungeNote") ?? "")
                        WeightInput(Exercise: "Hack Squat", WeightLeft: defaults.integer(forKey: "Hack SquatWeightLeft"), WeightRight: defaults.integer(forKey: "Hack SquatWightRight"), Weight: defaults.integer(forKey: "Hack SquatWeight"), Note: defaults.string(forKey: "Hack SquatNote") ?? "")
                        WeightInput(Exercise: "Leg Extension", WeightLeft: defaults.integer(forKey: "Leg ExtensionWeightLeft"), WeightRight: defaults.integer(forKey: "Leg ExtensionWeightRight"), Weight: defaults.integer(forKey: "Leg ExtensionWeight"), Note: defaults.string(forKey: "Leg ExtensionNote") ?? "")
                        WeightInput(Exercise: "Seated Calf Raise", WeightLeft: defaults.integer(forKey: "Seated Calf RaiseWeightLeft"), WeightRight: defaults.integer(forKey: "Seated Calf RaiseWeightRight"), Weight: defaults.integer(forKey: "Seated Calf RaiseWeight"), Note: defaults.string(forKey: "Seated Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Hip Abduction", WeightLeft: defaults.integer(forKey: "Hip AbductionWeightLeft"), WeightRight: defaults.integer(forKey: "Hip AbductionWeightRight"), Weight: defaults.integer(forKey: "Hip AbductionWeight"), Note: defaults.string(forKey: "Hip AbductionNote") ?? "")
                        WeightInput(Exercise: "Standing Calf Raise", WeightLeft: defaults.integer(forKey: "Standing Calf RaiseWeightLeft"), WeightRight: defaults.integer(forKey: "Standing Calf RaiseWeightRight"), Weight: defaults.integer(forKey: "Standing Calf RaiseWeight"), Note: defaults.string(forKey: "Standing Calf RaiseNote") ?? "")
                        WeightInput(Exercise: "Calf Press", WeightLeft: defaults.integer(forKey: "Calf PressWeightLeft"), WeightRight: defaults.integer(forKey: "Calf PressWeightRight"), Weight: defaults.integer(forKey: "Calf PressWeight"), Note: defaults.string(forKey: "Calf PressNote") ?? "")
                        WeightInput(Exercise: "Leg Press", WeightLeft: defaults.integer(forKey: "Leg PressWeightLeft"), WeightRight: defaults.integer(forKey: "Leg PressWeightRight"), Weight: defaults.integer(forKey: "Leg PressWeight"), Note: defaults.string(forKey: "Leg PressNote") ?? "")
                    }
                    .padding(.top)
                }
                .padding(.top, -30)
                .navigationTitle("Chest & Side Delts")
            }
        }
        .padding(.top, -105)
    }
}

#Preview {
    Four()
}
