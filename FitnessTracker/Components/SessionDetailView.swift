//
//  SessionDetailView.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    var session: Session
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack {
                        ForEach(session.exercises) { exercise in
                            WeightEntryView(exercise: exercise.name, weight: 0, left: 0, right: 0, sets: "", reps: "", rest: "", note: "")
                        }
                    }
                }
                .padding(.top, 16)
            }
            .applyGradientBackground()
        }
        .navigationTitle("\(session.name) Exercises")
        .modifier(NavigationBarModifier())
    }
}

#Preview {
    // Create mock exercises
    let exercises = [
        Exercise(name: "Push Up"),
        Exercise(name: "Squat"),
        Exercise(name: "Lunge")
    ]
    
    // Create a mock session
    let session = Session(name: "Morning Workout", exercises: exercises)
    
    // Pass the mock session to the preview
    SessionDetailView(session: session)
}
