import SwiftUI

struct Three: View {
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    let defaults = UserDefaults.standard
    var body: some View {
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 15) {
                        WeightInput(Exercise: "Chest Press", WeightLeft: defaults.integer(forKey: "Chest PressWeightLeft"), WeightRight: defaults.integer(forKey: "Chest PressWeightRight"),Weight: defaults.integer(forKey: "Chest PressWeight"), Note: defaults.string(forKey: "Chest PressNote") ?? "")
                        
                        HStack {
                            Text("Dip")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }

                        WeightInput(Exercise: "Tricep Extension Machine", WeightLeft: defaults.integer(forKey: "Tricep Extension MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Tricep Extension MachineWeightRight"), Weight: defaults.integer(forKey: "Tricep Extension MachineWeight"), Note: defaults.string(forKey: "Tricep Extension MachineNote") ?? "")
                        
                        WeightInput(Exercise: "Triceps Press", WeightLeft: defaults.integer(forKey:  "Triceps PressWeightLeft"), WeightRight: defaults.integer(forKey: "Triceps PressWeightRight"), Weight: defaults.integer(forKey: "Triceps PressWeight"), Note: defaults.string(forKey: "Triceps PressNote") ?? "")
                        HStack {
                            Text("Leg Raise")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        WeightInput(Exercise: "Abdominal Machine", WeightLeft: defaults.integer(forKey: "Abdominal MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Abdominal MachineWeightRight"), Weight: defaults.integer(forKey: "Abdominal MachineWeight"), Note: defaults.string(forKey: "Abdominal MachineNote") ?? "")
                        WeightInput(Exercise: "Hammer Curl", WeightLeft: defaults.integer(forKey: "Hammer CurlWeightLeft"), WeightRight: defaults.integer(forKey: "Hammer CurlWeightRight"), Weight: defaults.integer(forKey: "Hammer CurlWeight"), Note: defaults.string(forKey: "Hammer CurlNote") ?? "")
                        WeightInput(Exercise: "Preacher Curl Machine", WeightLeft: defaults.integer(forKey: "Preacher Curl MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Preacher Curl MachineWeightRight"), Weight: defaults.integer(forKey: "Pracher Curl MachineWeight"), Note: defaults.string(forKey: "Preacher Curl MachineNote") ?? "")
                        WeightInput(Exercise: "Biceps Curl Machine", WeightLeft: defaults.integer(forKey: "Biceps Curl MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Biceps Curl MachineWeightRight"), Weight: defaults.integer(forKey: "Biceps Curl MachineWeight"), Note: defaults.string(forKey: "Biceps Curl MachineNote") ?? "")
                    }
                    .padding(.top)
                }
                .padding(.top, -30)
                .navigationTitle("Arms & Abs")
                .foregroundColor(Color.white)
            }
        }
        .padding(.top, -105)
    }
}

#Preview {
    Three()
}
