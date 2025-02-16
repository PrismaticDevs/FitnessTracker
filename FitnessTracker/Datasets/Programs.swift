//
//  Programs.swift
//  FitnessTracker
//
//  Created by Matt on 2/11/25.
//

import SwiftUI

// Global data for workout programs
class WorkoutProgramsData: ObservableObject {
    @Published var workoutPrograms: [WorkoutProgram] = []
    init() {
           loadInitialPrograms()
       }

       private func loadInitialPrograms() {
           let initialPrograms: [(String, [(String, [String])])] = [
               ("Big and Strong Advanced", [
                   ("Push Power Day", ["Military Press", "Incline Bench Press", "Dumbbell Bench Press", "Tricep Dip", "Overhead EZ Bar Tricep Extension"]),
                   ("Legs Power Day", ["Front Squat", "Pause Back Squat", "Hack Squat or Leg Press", "Seated Leg Curl", "Leg Extension"]),
                   ("Pull Power Day", ["Trap Bar or Barbell Rack Pull", "Pull Ups", "One Arm Dumbbell Row", "Concentration Curl", "Shrug (with hold)"]),
                   ("Lower Dynamic Day", ["Speed Front Squat", "Speed Pause Squat", "Leg Press", "Seated Calf Raise", "Lying Leg Raise"]),
                   ("Upper Dynamic Day", ["Speed Barbell Press", "Speed Trap Bar or Barbell Rack Pull", "Lateral Raise", "Barbell Curl", "Tricep Extension"])
               ]),
               ("8 Week Mass Building Hypertrophy Workout", [
                   ("Chest and Side Delts", ["Incline Barbell Bench Press", "Flat Dumbbell Bench Press", "Cable Crossover", "Seated Lateral Raise", "Single Arm Cable Lateral Raise"]),
                   ("Upper Back and Rear Delts", ["Bent-Over Barbell Row", "Dumbbell Pullover", "Wide Grip Lat Pulldown", "Dumbbell Rear Delt Fly", "Cable Face Pull", "Dumbbell Shrug"]),
                   ("Arms and Abs", ["Close Grip Bench Press", "Weighted Dip", "Rope Tricep Extension", "Lying Leg Raise", "Cable Crunch", "Barbell Curl", "Hammer Curl", "Cable Curl"]),
                   ("Legs", ["Deadlift", "Lying Leg Curl", "Walking Lunge", "Front Squat", "Leg Extension", "Dumbbell Side Lunge"])
               ]),
               ("4 Day Maximum Mass Workout", [
                   ("Back and Biceps", ["Deadlift", "One Arm Dumbbell Row", "Wide Grip Pull Up or Lat Pull Down", "Barbell Row", "Seated Cable Row or Machine Row", "EZ Bar Preacher Curl", "Concentration Curl", "Seated Dumbbell Curl"]),
                   ("Chest and Triceps", ["Bench Press", "Incline Dumbbell Bench Press", "Chest Dip", "Cable Crossover or Pec Dec", "Machine Press or Dumbbell Bench Press", "EZ Bar Skullcrusher", "Two Arm Seated Dumbbell Extension", "Cable Tricep Extension"]),
                   ("Quads, Hamstrings, and Calves", ["Squat", "Leg Press", "Hack Squat or Dumbbell Lunge", "Leg Extension", "Stiff Leg Deadlift", "Leg Curl", "Standing Calf Raise", "Seated Calf Raise"]),
                   ("Shoulders, Traps, and Forearms", ["Seated Barbell Press", "Seated Arnold Press", "Dumbbell Lateral Raise", "Hammer Strength Press or Smith Press", "Upright Row", "Barbell Shrug or Dumbbell Shrug", "Seated Barbell Wrist Curl", "Barbell Static Hold"])
               ])
           ]

           for (title, sessions) in initialPrograms {
               let workoutProgram = WorkoutProgram(title: title, sessions: sessions.map { (sessionName, exerciseNames) in
                   Session(name: sessionName, exercises: exerciseNames.map { Exercise(name: $0) })
               })
               workoutPrograms.append(workoutProgram)
           }
       }

    func addWorkoutProgram(title: String) {
        let newProgram = WorkoutProgram(title: title, sessions: [])
        workoutPrograms.append(newProgram)
    }

    func addSession(to program: inout WorkoutProgram, sessionName: String) {
        let session = Session(id: UUID(), name: sessionName, exercises: [])
        program.sessions.append(session)
    }

    func addExercise(to session: inout Session, exerciseName: String, sets: String, reps: String, rest: String) {
        let exercise = Exercise(name: exerciseName)
        session.exercises.append(exercise)
    }
}
