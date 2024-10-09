//
//  DayOne.swift
//  Fitness Tracker
//
//  Created by Matt on 9/28/24.
//

import SwiftUI

struct Two: View {
    var defaults = UserDefaults.standard
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    var body: some View {
            NavigationView {
                ZStack{
                    ScrollView {
                        VStack {
                            WeightInput(Exercise: "Shoulder Press", WeightLeft: defaults.string(forKey: "Shoulder PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Shoulder PressWeightRight") ?? "", Weight: defaults.string(forKey: "Shoulder PressWeight") ?? "", Note: defaults.string(forKey: "Shoulder PressNote") ?? "")
                            WeightInput(Exercise: "Pulldown", WeightLeft: defaults.string(forKey:  "PulldownWeightLeft") ?? "", WeightRight: defaults.string(forKey: "PulldownWeightRight") ?? "", Weight: defaults.string(forKey: "PulldownWeight") ?? "", Note: defaults.string(forKey: "PulldownNote") ?? "")
                            WeightInput(Exercise: "Seated Row", WeightLeft: defaults.string(forKey: "Seated RowWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Seated RowWeightRight") ?? "", Weight: defaults.string(forKey: "Seated RowWeight") ?? "", Note: defaults.string(forKey: "Seated RowNote") ?? "")
                            WeightInput(Exercise: "Row", WeightLeft: defaults.string(forKey: "RowWeightLeft") ?? "", WeightRight: defaults.string(forKey: "RowWeightRight") ?? "", Weight: defaults.string(forKey: "RowWeight") ?? "", Note: defaults.string(forKey: "RowNote") ?? "")
                            WeightInput(Exercise: "Dumbell Rear Delt Fly", WeightLeft: defaults.string(forKey: "Dumbell Rear Felt FlyWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Dumbell Rear Delt FlyWeightRight") ?? "", Weight: defaults.string(forKey: "Dumbell Rear Delt FlyWeight") ?? "", Note: defaults.string(forKey: "Dumbell Rear Felt FlyNote") ?? "")
                            WeightInput(Exercise: "Rear Delt Machine", WeightLeft: defaults.string(forKey: "Rear Delt MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Rear Delt Machine WeightRight") ?? "", Weight: defaults.string(forKey: "Rear Delt MachineWeight") ?? "", Note: defaults.string(forKey: "Rear Delt MachineNote") ?? "")
                            WeightInput(Exercise: "Dumbell Shrug", WeightLeft: defaults.string(forKey: "Dumbell ShrugWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Dumbell ShrugWeightRight") ?? "", Weight: defaults.string(forKey: "Dumbell ShrugWeight") ?? "", Note:  defaults.string(forKey: "Dumbell ShrugNote") ?? "")
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 1)
                    .navigationTitle("Upper Back & Rear Delts")
//                    .background(Color.cyan)
                }
        }
        .padding(.top, -120)
    }
    
}

#Preview {
    Two()
}
