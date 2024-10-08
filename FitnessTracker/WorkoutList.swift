//
//  Home.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

struct WorkoutList: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    NavigationStack {
                        List {
                        HStack {
                            Text("Weight Tracker")
                                .foregroundColor(.cyan)
                                .font(.title )
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundColor(.cyan)
                                .font(.system(size: 36))
                            Text("0.1")
                                .font(.system(size: 18))
                                .foregroundColor(.cyan)
                        }
                        .padding(5)
                        
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
                        .background(Color.cyan)
                    }
                    .scrollContentBackground(.hidden)
                    
                }
                
            }
        }

    }
}

#Preview {
    WorkoutList()
}
