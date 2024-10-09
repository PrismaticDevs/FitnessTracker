//
//  Home.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

struct WorkoutList: View {
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
                            NavigationLink("Chest & Side Delts", destination: One())
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))

                            NavigationLink("Upper Back & Rear Delts", destination: Two())
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))

                            NavigationLink("Arms & Abs", destination: Three())
                                .bold()
                                .padding()
                                .listRowBackground(Color.blue)
                                .foregroundStyle(.white, .white)
                                .font(.system(size: 24))

                            NavigationLink("Legs", destination: Four())
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
    WorkoutList()
}
