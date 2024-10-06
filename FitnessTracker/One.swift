//
//  DayOne.swift
//  Fitness Tracker
//
//  Created by Matt on 9/28/24.
//

import SwiftUI

struct One: View {
    let defaults = UserDefaults.standard
    var body: some View {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack {
                            WeightInput(Exercise: "Chest Press", Weight: defaults.string(forKey: "Chest PressWeight") ?? "", Note: defaults.string(forKey: "Chest PressNote") ?? "")
                            WeightInput(Exercise: "Chest Fly", Weight: defaults.string(forKey: "ChestFlyWeight") ?? "", Note: defaults.string(forKey: "Chest FlyNote") ?? "")
                            WeightInput(Exercise: "Seated Lateral Raise", Weight: defaults.string(forKey: "Seated Lateral RaiseWeight") ?? "", Note: defaults.string(forKey: "Seated Lateral RaiseNote") ?? "")
                            WeightInput(Exercise: "Lateral Raise Machine", Weight: defaults.string(forKey: "Seated Lateral RaiseWight") ?? "", Note: defaults.string(forKey: "Seated Lateral RaiseNote") ?? "")
                            WeightInput(Exercise: "Single Arm Cable Lateral Raise", Weight:       defaults.string(forKey: "Single Arm Cable Lateral RaiseWeight") ?? "", Note: defaults.string(forKey: "Single Arm Cable Lateral RaiseNote") ?? "")
                        }
                    }
                }
                .padding(.top, 1)
                .background(Color.cyan)
                .navigationTitle("Chest and Side Delts")
        }
        .padding(.top, -100)
    }
    
}

#Preview {
    One()
}
