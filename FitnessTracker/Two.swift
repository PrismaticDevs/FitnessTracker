//
//  DayOne.swift
//  Fitness Tracker
//
//  Created by Matt on 9/28/24.
//

import SwiftUI

struct Two: View {
    var defaults = UserDefaults.standard
    var body: some View {
            NavigationView {
                ZStack{
                    ScrollView {
                        VStack {
                            WeightInput(Exercise: "Shoulder Press", Weight: defaults.string(forKey: "Shoulder PressWeight") ?? "", Note: defaults.string(forKey: "Shoulder PressNote") ?? "")
                            WeightInput(Exercise: "Pulldown", Weight: defaults.string(forKey:  "PulldownWeight") ?? "", Note: defaults.string(forKey: "PulldownNote") ?? "")
                            WeightInput(Exercise: "Seated Row", Weight: defaults.string(forKey: "Seated RowWeight") ?? "", Note: defaults.string(forKey: "Seated RowNote") ?? "")
                            WeightInput(Exercise: "Row", Weight: defaults.string(forKey: "RowWeight") ?? "", Note: defaults.string(forKey: "RowNote") ?? "")
                            WeightInput(Exercise: "Dumbell Rear Delt Fly", Weight: defaults.string(forKey: "Dumbell Rear Felt FlyWeight") ?? "", Note: defaults.string(forKey: "Dumbell Rear Felt FlyNote") ?? "")
                            WeightInput(Exercise: "Rear Delt Machine", Weight: defaults.string(forKey: "Rear Delt MachineWeight") ?? "", Note: defaults.string(forKey: "Rear Delt MachineNote") ?? "")
                            WeightInput(Exercise: "Dumbell Shrug", Weight: defaults.string(forKey: "Dumbell ShrugWeight") ?? "", Note:  defaults.string(forKey: "Dumbell ShrugNote") ?? "")
                            
                        }
                    }
                    .padding(.top, 1)
                    .navigationTitle("Upper Back & Rear Delts")
                    .background(Color.cyan)
                }
        }
        .padding(.top, -100)
    }
    
}

#Preview {
    Two()
}
