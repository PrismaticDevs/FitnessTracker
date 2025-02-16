//
//  SessionView.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/25.
//

import SwiftUI

// Workout Program Detail View
struct SessionsView: View {
    @ObservedObject var program: WorkoutProgram
    @EnvironmentObject var workoutHistory: WorkoutHistory

    var body: some View {
        VStack {
            Text(program.title)
                .font(.title)

            List {
                ForEach(program.sessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        Text(session.name)
                    }
                    .background(Color.clear)
                    .padding()
                    .listStyle(PlainListStyle())
                }
                .listRowBackground(Color.blue)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .bold()
            .font(.system(size: 24))
            .padding()
            .foregroundColor(.white)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Sessions")
        .applyGradientBackground() // Apply the gradient background
    }
}

#Preview {
    SessionsView(program: WorkoutProgram(title: "test", sessions: [Session(name: "test", exercises: [Exercise(name: "test")]), Session(name: "test 2", exercises: [Exercise(name: "test")])]))
        .environmentObject(WorkoutHistory())
}
