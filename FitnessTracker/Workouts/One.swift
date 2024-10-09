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
                            WeightInput(Exercise: "Chest Press", WeightLeft: defaults.integer(forKey: "Chest PressWeightLeft"), WeightRight: defaults.integer(forKey: "Chest PressWeightRight"), Weight: defaults.integer(forKey: "Chest PressWeight"), Note: defaults.string(forKey: "Chest PressNote") ?? "")
                            WeightInput(Exercise: "Chest Fly", WeightLeft: defaults.integer(forKey: "Chest FlyWeightLeft"), WeightRight: defaults.integer(forKey: "Chest FlyWeightRight"), Weight: defaults.integer(forKey: "Chest FlyWeight"), Note: defaults.string(forKey: "Chest FlyNote") ?? "")
                            WeightInput(Exercise: "Flat Dumbell Bench Press", WeightLeft: defaults.integer(forKey: "Flat Dumbell Bench PressWeightLeft"), WeightRight: defaults.integer(forKey: "Flat Dumbell Bench PressWeightRight"), Weight: defaults.integer(forKey: "Flat Dumbell Bench PressWeight"), Note: defaults.string(forKey: "Flat Dumbell Bench PressNote") ?? "")
                            WeightInput(Exercise: "Seated Lateral Raise", WeightLeft: defaults.integer(forKey: "Seated Lateral RaiseWeightLeft"), WeightRight: defaults.integer(forKey: "Seated Lateral RaiseWeightRight"), Weight: defaults.integer(forKey: "Seated Lateral RaiseWeight"), Note: defaults.string(forKey: "Seated Lateral RaiseNote") ?? "")
                            WeightInput(Exercise: "Lateral Raise Machine", WeightLeft: defaults.integer(forKey: "Lateral Raise MachineWeightLeft"), WeightRight: defaults.integer(forKey: "Lateral Raise MachineWeightRight"), Weight: defaults.integer(forKey: "Lateral RaiseWeight"), Note: defaults.string(forKey: "Lateral Raise MachineNote") ?? "")
                            WeightInput(Exercise: "Single Arm Cable Lateral Raise", WeightLeft:       defaults.integer(forKey: "Single Arm Cable Lateral RaiseWeightLeft"), WeightRight: defaults.integer(forKey: "Single Arm Cable Lateral RaiseWeightRight"), Weight: defaults.integer(forKey: "Signle Arm Cable Lateral RaiseWeight"), Note: defaults.string(forKey: "Single Arm Cable Lateral RaiseNote") ?? "")
                        }
                    }
                    .padding(.top)
                }
                .padding(.top, -30)
                .navigationBarTitle(Text("Chest and Side Delts"))
                .foregroundColor(Color.white)
        }
        .padding(.top, -105)
    }
    
}

#Preview {
    One()
}
