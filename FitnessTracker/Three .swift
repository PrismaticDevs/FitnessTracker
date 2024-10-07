import SwiftUI

struct Three: View {
//    var bckGrdGradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    let defaults = UserDefaults.standard
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 15) {
                        WeightInput(Exercise: "Chest Press", WeightLeft: defaults.string(forKey: "Chest PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Chest PressWeightRight") ?? "",Note: defaults.string(forKey: "Chest PressNote") ?? "")
                        
                        HStack {
                            Text("Dip")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }

                        WeightInput(Exercise: "Tricep Extension Machine", WeightLeft: defaults.string(forKey: "Tricep Extension MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Tricep Extension MachineWeightRight") ?? "", Note: defaults.string(forKey: "Tricep Extension MachineNote") ?? "")
                        
                        WeightInput(Exercise: "Triceps Press", WeightLeft: defaults.string(forKey:  "Triceps PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Triceps PressWeightRight") ?? "",Note: defaults.string(forKey: "Triceps PressNote") ?? "")
                        HStack {
                            Text("Leg Raise")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }
                        WeightInput(Exercise: "Abdominal Machine", WeightLeft: defaults.string(forKey: "Abdominal MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Abdominal MachineWeightRight") ?? "", Note: defaults.string(forKey: "Abdominal MachineNote") ?? "")
                        WeightInput(Exercise: "Hammer Curl", WeightLeft: defaults.string(forKey: "Hammer CurlWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Hammer CurlWeightRight") ?? "", Note: defaults.string(forKey: "Hammer CurlNote") ?? "")
                        WeightInput(Exercise: "Preacher Curl Machine", WeightLeft: defaults.string(forKey: "Preacher Curl MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Preacher Curl MachineWeightRight") ?? "",Note: defaults.string(forKey: "Preacher Curl MachineNote") ?? "")
                        WeightInput(Exercise: "Biceps Curl Machine", WeightLeft: defaults.string(forKey: "Biceps Curl MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Biceps Curl MachineRight") ?? "", Note: defaults.string(forKey: "Biceps Curl MachineNote") ?? "")
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
