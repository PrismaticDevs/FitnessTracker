//
//  PrebuiltPrograms.swift
//  FitnessTracker
//
//  Created by Matt on 3/25/25.
//
import SwiftUI
import Foundation
import SwiftData

func createPrebuiltWorkoutPrograms() -> [WorkoutProgram] {
    let programsData: [(String, [(String, [String])])] = [
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
    
    var workoutPrograms: [WorkoutProgram] = []
    
    for (programTitle, sessionsData) in programsData {
        var sessions: [Session] = []
        
        for (sessionTitle, exercises) in sessionsData {
            let exerciseObjects = exercises.map { Exercise(name: $0) }
            let session = Session(name: sessionTitle, exercises: exerciseObjects) // Assuming a default duration
            sessions.append(session)
        }
        
        let workoutProgram = WorkoutProgram(title: programTitle, sessions: sessions)
        workoutPrograms.append(workoutProgram)
    }
    
    return workoutPrograms
}

struct PrebuiltSessionDetailView: View {
    let session: Session

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(session.name)
                    .font(.largeTitle)
                    .padding()
                
                Text("Exercises:")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(session.exercises, id: \.id) { exercise in
                    Text(exercise.name)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle(session.name)
        }
        .padding(.top, 16)
        .applyGradientBackground()
    }
}

struct PrebuiltProgramsView: View {
    @Environment(\.dismiss) var dismiss
    let workoutPrograms: [WorkoutProgram] = createPrebuiltWorkoutPrograms()
    @Environment(\.modelContext) var context

    var body: some View {
        NavigationView {
                List {
                    ForEach(workoutPrograms, id: \.id) { program in
                        HStack {
                            CustomSectionHeader(title: program.title) {
                                addProgramToUserList(program)
                            }
                        }
                        .listRowBackground(Color.clear)
                            ForEach(program.sessions, id: \.id) { session in
                                NavigationLink(destination: PrebuiltSessionDetailView(session: session)) {
                                    Text(session.name)
                                        .foregroundColor(.white)
                                }
                            }
                            .listRowBackground(ColorPalette.accent)
                    }
                }
                .navigationTitle("Prebuilt Workout Programs")
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .padding()
                .applyGradientBackground()
        }
        .navigationBarTitleTextColor(.white)
    }
    
     func addProgramToUserList(_ program: WorkoutProgram) {
        // Create a new instance of WorkoutProgram and add it to the user's list
        let newProgram = WorkoutProgram(title: "\(program.title)", sessions: program.sessions)
        context.insert(newProgram)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

struct CustomSectionHeader: View {
    var title: String
    var addAction: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(ColorPalette.primary)

            Spacer()

            Button(action: {
                addAction()
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle()) // Optional: to remove button styling
        }
    }
}

struct ProgramHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(ColorPalette.primary)
            .padding()
            .background(Color.clear) // Ensure the background is clear
    }
}

struct PrebuiltProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        PrebuiltProgramsView()
    }
}

