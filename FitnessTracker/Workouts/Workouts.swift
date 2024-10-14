//
//  Workouts.swift
//  FitnessTracker
//
//  Created by Matt on 10/13/24.
//

import SwiftUI

struct Workouts: View  {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
//    init() {
//        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    var defaults = UserDefaults.standard
    var Chest: Bool
    var Shoulders: Bool
    var Abs: Bool
    var Legs: Bool
    @State private var ChestExercises = ["Chest Press", "Chest Fly", "Flat Dumbell Bench Press", "Seated Lateral Raise", "Lateral Raise Machine", "Single Arm Cable Lateral Raise"]
    @State private var ShoulderExercises = ["Shoulder Press", "Pulldown", "Row", "Dumbell Rear Delt Fly", "Rear Delt Machine", "Dumbell Shrug"]
    @State private var ArmsAbsExercises = ["Chest Press", "Tricep Extension Machine", "Triceps Press", "Abdominal Machine", "Hammer Curl", "Preacher Curl Machine", "Biceps Curl Machine"]
    @State private var LegExercises = ["Deadlift", "Lying Leg Curl", "Walking Lunge", "Hack Squat", "Leg Extension", "Seated Calf Raise", "Hip Abduction", "Standing Calf Raise", "Calf Press", "Leg Press"]
    var body: some View {
        
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 15) {
                        if Chest {
                            ForEach(ChestExercises, id: \.self) { exercise in
                                WeightInput(Exercise: exercise, WeightLeft: defaults.integer(forKey: exercise + "WeightLeft"), WeightRight: defaults.integer(forKey: exercise + "WeightRight"), Weight: defaults.integer(forKey: exercise + "Weight"), Note: defaults.string(forKey: exercise + "Note") ?? "", Expand: false)
                                    
                            }
                        }
                         else if Shoulders {
                            ForEach(ShoulderExercises, id: \.self) { exercise in
                                WeightInput(Exercise: exercise, WeightLeft: defaults.integer(forKey: exercise + "WeightLeft"), WeightRight: defaults.integer(forKey: exercise + "WeightRight"), Weight: defaults.integer(forKey: exercise + "Weight"), Note: defaults.string(forKey: exercise + "Note") ?? "", Expand: false)
                                    
                            }
                        }
                        else if Abs {
                            ForEach(ArmsAbsExercises, id: \.self) { exercise in
                                WeightInput(Exercise: exercise, WeightLeft: defaults.integer(forKey: exercise + "WeightLeft"), WeightRight: defaults.integer(forKey: exercise + "WeightRight"), Weight: defaults.integer(forKey: exercise + "Weight"), Note: defaults.string(forKey: exercise + "Note") ?? "", Expand: false)
                                    
                            }
                        }
                        else if Legs {
                            ForEach(LegExercises, id: \.self) { exercise in
                                WeightInput(Exercise: exercise, WeightLeft: defaults.integer(forKey: exercise + "WeightLeft"), WeightRight: defaults.integer(forKey: exercise + "WeightRight"), Weight: defaults.integer(forKey: exercise + "Weight"), Note: defaults.string(forKey: exercise + "Note") ?? "", Expand: false)
                                    
                            }
                        }
                        else {
                            Text("No workout Selected")
                        }
                    }
                    .padding(.top)
                }
                .padding(.top, -30)
                .navigationTitle("Legs")
                .foregroundColor(Color.white)
            }
        }
        .padding(.top, -105)
    }
}

#Preview {
    Workouts(Chest: false, Shoulders: false, Abs: false, Legs: false)
}
