//  AddProgram.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/25.
//

import SwiftUI

// Create workout program
struct AddWorkoutProgramView: View {
    @EnvironmentObject var workoutProgramsData: WorkoutProgramsData
    @State private var programTitle: String = ""
    @State private var sessionName: String = ""
    @State private var exerciseName: String = ""
    @State private var sets: String = ""
    @State private var reps: String = ""
    @State private var rest: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 16) {
                        Section(header: Text("Workout Program").font(.headline)) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Program Title", text: $programTitle, prompt: Text("Enter a title"))
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)

                        Section {
                            Section(header: Text("Session").font(.subheadline)) {
                                TextField("Session Name", text: $sessionName)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            
                            Section(header: Text("Exercise").font(.subheadline)) {
                                TextField("Exercise Name", text: $exerciseName)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                TextField("Sets", text: $sets)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                TextField("Reps", text: $reps)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                TextField("Rest", text: $rest)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }

                        Button {
                            if !programTitle.isEmpty,
                               !sessionName.isEmpty,
                               !exerciseName.isEmpty,
                               !sets.isEmpty,
                               !reps.isEmpty,
                               !rest.isEmpty {
                                workoutProgramsData.addWorkoutProgram(title: programTitle)
                                if var lastProgram = workoutProgramsData.workoutPrograms.last {
                                    workoutProgramsData.addSession(to: &lastProgram, sessionName: sessionName)
                                    if var lastSession = lastProgram.sessions.last {
                                        workoutProgramsData.addExercise(to: &lastSession, exerciseName: exerciseName, sets: sets, reps: reps, rest: rest)
                                    }
                                }
                                printWorkoutPrograms()
                                programTitle = ""
                                sessionName = ""
                                exerciseName = ""
                                sets = ""
                                reps = ""
                                rest = ""
                            }
                            print(workoutProgramsData.workoutPrograms.count)
                        } label: {
                            HStack {
                                Text("Add Program")
                                Image(systemName: "plus")
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .navigationTitle("Add Workout Program")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func printWorkoutPrograms() {
        for program in workoutProgramsData.workoutPrograms {
            print("Workout Program: \(program.title)")
            for session in program.sessions {
                print("  Session: \(session.name)")
                for exercise in session.exercises {
                    print("    Exercise: \(exercise.name)")
                }
            }
        }
    }
}

#Preview {
    AddWorkoutProgramView()
        .environmentObject(WorkoutProgramsData())
}
