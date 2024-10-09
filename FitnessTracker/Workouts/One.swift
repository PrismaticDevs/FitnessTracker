//
//  DayOne.swift
//  Fitness Tracker
//
//  Created by Matt on 9/28/24.
//

import SwiftUI

struct One: View {
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    let defaults = UserDefaults.standard
    var body: some View {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack {
                            WeightInput(Exercise: "Chest Press", WeightLeft: defaults.string(forKey: "Chest PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Chest PressWeightRight") ??  "", Weight: defaults.string(forKey: "Chest PressWeight") ?? "", Note: defaults.string(forKey: "Chest PressNote") ?? "")
                            WeightInput(Exercise: "Chest Fly", WeightLeft: defaults.string(forKey: "Chest FlyWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Chest FlyWeightRight") ?? "", Weight: defaults.string(forKey: "Chest FlyWeight") ?? "", Note: defaults.string(forKey: "Chest FlyNote") ?? "")
                            WeightInput(Exercise: "Flat Dumbell Bench Press", WeightLeft: defaults.string(forKey: "Flat Dumbell Bench PressWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Flat Dumbell Bench PressWeightRight") ?? "", Weight: defaults.string(forKey: "Flat Dumbell Bench PressWeight") ?? "", Note: defaults.string(forKey: "Flat Dumbell Bench PressNote") ?? "")
                            WeightInput(Exercise: "Seated Lateral Raise", WeightLeft: defaults.string(forKey: "Seated Lateral RaiseWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Seated Lateral RaiseWeightRight") ?? "", Weight: defaults.string(forKey: "Seated Lateral RaiseWeight") ?? "",Note: defaults.string(forKey: "Seated Lateral RaiseNote") ?? "")
                            WeightInput(Exercise: "Lateral Raise Machine", WeightLeft: defaults.string(forKey: "Lateral Raise MachineWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Lateral Raise MachineWeightRight") ?? "", Weight: defaults.string(forKey: "Lateral RaiseWeight") ?? "", Note: defaults.string(forKey: "Lateral Raise MachineNote") ?? "")
                            WeightInput(Exercise: "Single Arm Cable Lateral Raise", WeightLeft:       defaults.string(forKey: "Single Arm Cable Lateral RaiseWeightLeft") ?? "", WeightRight: defaults.string(forKey: "Single Arm Cable Lateral RaiseWeightRight") ?? "", Weight: defaults.string(forKey: "Signle Arm Cable Lateral RaiseWeight") ?? "", Note: defaults.string(forKey: "Single Arm Cable Lateral RaiseNote") ?? "")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 1)
//                .background(Color.cyan)
                .navigationBarTitle(Text("Chest and Side Delts"))
        }
        .padding(.top, -120)
    }
    
}

#Preview {
    One()
}
