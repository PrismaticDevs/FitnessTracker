//
//  Home.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

struct WorkoutList: View {
    var body: some View {
        @State var menuOpened: Bool = false
        NavigationView {
            ZStack {
                VStack {
                    NavigationStack {
                        HStack {
                            Text("Weight Tracker")
                                .foregroundColor(.cyan)
                                .font(.title )
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundColor(.cyan)
                                .font(.system(size: 36))
                            Text("1.0")
                                .font(.system(size: 18))
                                .foregroundColor(.cyan)
                        }
                        .padding()
                        List {
                            NavigationLink("Chest & Side Delts", destination: One())
                                .bold()
                                .padding()
                            NavigationLink("Upper Back & Rear Delts", destination: Two())
                                .bold()
                                .padding()
                            NavigationLink("Arms & Abs", destination: Three())
                                .bold()
                                .padding()
                            NavigationLink("Legs", destination: Four())
                                .bold()
                                .padding()
                        }
                    }
                }
            }
        }

    }
}

#Preview {
    WorkoutList()
}
