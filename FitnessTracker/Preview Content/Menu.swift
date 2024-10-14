//
//  Home.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

struct Menu: View {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    
    var body: some View {
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                VStack {
                        HStack {
                            Text("FitnessTracker")
                                .foregroundColor(.white)
                                .font(.title )
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundColor(.white)
                                .font(.system(size: 36))
                            Text("0.1")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                        .padding(5)
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
        }
        .accentColor(Color.white)
    }
}

#Preview {
    Menu()
}
