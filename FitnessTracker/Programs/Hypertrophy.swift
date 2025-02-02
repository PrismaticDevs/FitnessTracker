//
//  Home.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

struct Hypertrophy: View {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    
    @EnvironmentObject var workoutHistory: WorkoutHistory
    
    var body: some View {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                VStack {
                        HStack {
                            Text("Hypertrophy Mass Building")
                                .foregroundColor(.white)
                                .font(.title )
                        }
                        .padding(5)
                        .padding(.top, 10)
                        List {
                            NavigationLink("Chest & Side Delts", destination: Workouts(Chest: true, Shoulders: false, Abs: false, Legs: false))
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))
                            NavigationLink("Upper Back & Rear Delts", destination: Workouts(Chest: false, Shoulders: true, Abs: false, Legs: false))
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))
                            NavigationLink("Arms & Abs", destination: Workouts(Chest: false, Shoulders: false, Abs: true, Legs: false))
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))
                            NavigationLink("Legs", destination: Workouts(Chest: false, Shoulders: false, Abs: false, Legs: true))
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))
                    }
                    .scrollContentBackground(.hidden)

                }
            }
        .accentColor(Color.white)
    }
}

#Preview {
    let workoutHistory = WorkoutHistory() // Create an instance of WorkoutHistory
    Hypertrophy() // No arguments passed here
        .environmentObject(workoutHistory) // Inject the environment object
}
