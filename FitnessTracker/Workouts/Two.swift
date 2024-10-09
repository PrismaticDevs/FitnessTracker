//
//  DayOne.swift
//  Fitness Tracker
//
//  Created by Matt on 9/28/24.
//

import SwiftUI

struct Two: View {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    var defaults = UserDefaults.standard
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    var body: some View {
            NavigationView {
                ZStack {
                    gradient.edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack(spacing: 15) {
                            WeightInput(Exercise: "Shoulder Press", WeightLeft: defaults.integer(forKey: "Shoulder PressWeightLeft"), WeightRight: defaults.integer(forKey: "Shoulder PressWeightRight"), Weight: defaults.integer(forKey: "Shoulder PressWeight"), Note: defaults.string(forKey: "Shoulder PressNote") ?? "")
                            WeightInput(Exercise: "Pulldown", WeightLeft: defaults.integer(forKey:  "PulldownWeightLeft"), WeightRight: defaults.integer(forKey: "PulldownWeightRight"), Weight: defaults.integer(forKey: "PulldownWeight"), Note: defaults.string(forKey: "PulldownNote") ?? "")
                            WeightInput(Exercise: "Row", WeightLeft: defaults.integer(forKey: "RowWeightLeft"), WeightRight: defaults.integer(forKey: "RowWeightRight"), Weight: defaults.integer(forKey: "RowWeight"), Note: defaults.string(forKey: "RowNote") ?? "")
                            WeightInput(Exercise: "Dumbell Rear Delt Fly", WeightLeft: defaults.integer(forKey: "Dumbell Rear Delt FlyWeightLeft"), WeightRight: defaults.integer(forKey: "Dumbell Rear Delt FlyWeightRight"), Weight: defaults.integer(forKey: "Dumbell Rear Delt FlyWeight"), Note: defaults.string(forKey: "Dumbell Rear Felt FlyNote") ?? "")
                            WeightInput(Exercise: "Rear Delt Machine", WeightLeft: defaults.integer(forKey: "Rear Delt MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Rear Delt MachineWeightRight"), Weight: defaults.integer(forKey: "Rear Delt MachineWeight"), Note: defaults.string(forKey: "Rear Delt MachineNote") ?? "")
                            WeightInput(Exercise: "Dumbell Shrug", WeightLeft: defaults.integer(forKey: "Dumbell ShrugWeightLeft"), WeightRight: defaults.integer(forKey: "Dumbell ShrugWeightRight"), Weight: defaults.integer(forKey: "Dumbell ShrugWeight"), Note:  defaults.string(forKey: "Dumbell ShrugNote") ?? "")
                            
                        }
                        .padding(.top)
                    }
                    .padding(.top, -30)
                    .navigationTitle("Upper Back & Rear Delts")
                }
        }
        .padding(.top, -105)
    }
    
}

#Preview {
    Two()
}
