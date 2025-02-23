//
//  SessionView.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/25.
//

import SwiftUI

struct SessionsView: View {
    @ObservedObject var program: WorkoutProgram
    @EnvironmentObject var workoutHistory: WorkoutHistory
    @EnvironmentObject var workoutProgramsData: WorkoutProgramsData
    @State private var showDeleteConfirmation: Bool = false

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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Toggle the isStarred property
                    program.isStarred.toggle()
                    
                    if let index = workoutProgramsData.starredPrograms.firstIndex(where: { $0.id == program.id}) {
                        workoutProgramsData.workoutPrograms[index].isStarred = program.isStarred
                    }
                    
                    workoutProgramsData.updateStarredPrograms()
                    workoutProgramsData.saveWorkoutProgram(program: program)
                    print(workoutProgramsData.starredPrograms.count)
                }) {
                    Image(systemName: program.isStarred ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

#Preview {
    SessionsView(program: WorkoutProgram(title: "test", sessions: [Session(name: "test", exercises: [Exercise(name: "test")]), Session(name: "test 2", exercises: [Exercise(name: "test")])]))
        .environmentObject(WorkoutHistory())
}
