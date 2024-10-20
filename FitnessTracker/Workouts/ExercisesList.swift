import SwiftUI
import Combine

@Observable class ExerciseList {
    var Chest = ["Close Grip Bench Press",
                 "Converging Chest Press","Incline Barbell Bench Press",
                 "Chest Press",
                 "Cable Crossover",
                 "Chest Fly",
                 "Flat Dumbbell Bench Press",]
    var Shoulders = ["Bent-Over Barbell Row",
                     "Dumbbell Pullover",
                     "Shoulder Press",
                     "Converging Shoulder Press",
                     "Wide Grip Lat Pulldown",
                     "Diverging Lat Pull Down",
                     "Pulldown",
                     "Seated Row",
                     "Row",
                     "Dumbbell Rear Delt Fly",
                     "Rear Delt Machine",
                     "Cable Face Pull",
                     "Dumbbell Shrug","Seated Lateral Raise",
                     "Lateral Raise Mx",
                     "Single Arm Cable Lateral Raise"]
    var Abdominals = ["Abdominal Machine","Cable Crunch","Leg Raise","Plank"]
    var Legs = ["Deadlift",
                "Lying Leg Curl",
                "Walking Lunge",
                "Back Squat",
                "Hack Squat",
                "Leg Extension",
                "Seated Calf Raise",
                "Standing Calf Raise",
                "Calf Press",
                "Leg Press",
                "Hip Abduction"]
    var Arms = ["Barbell Curl",
                "Hammer Curl",
                "Cable Curl",
                "Preacher Curl Mx",
                "Biceps Curl Mx","Rope Tricep Extension",
                "Tricep Extension Mx",
                "Triceps Press","Weighted Dip"]
}

struct WorkoutList: View {
    let Arms = ExerciseList().Arms
    let Legs = ExerciseList().Legs
    let Abdominals = ExerciseList().Abdominals
    let Shoulders = ExerciseList().Shoulders
    let Chest = ExerciseList().Chest

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Arms")) {
                        ForEach(Arms.indices, id: \.self) { exercise in
                            Text(Arms[exercise])
                                .foregroundColor(Color.white)
                        }
                    }
                    Section(header: Text("Chest")) {
                        ForEach(Chest.indices, id: \.self) { exercise in
                            Text(Chest[exercise])
                                .foregroundColor(Color.white)
                        }
                    }
                    Section(header: Text("Shoulders")) {
                        ForEach(Shoulders.indices, id: \.self) { exercise in
                            Text(Shoulders[exercise])
                                .foregroundColor(Color.white)
                        }
                    }
                    Section(header: Text("Abdominals")) {
                        ForEach(Abdominals.indices, id: \.self) { exercise in
                            Text(Abdominals[exercise])
                                .foregroundColor(Color.white)
                        }
                    }
                    Section(header: Text("Legs")) {
                        ForEach(Legs, id: \.self) { exercise in
                            Text(exercise)
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .background(Color.white)
            }
            .navigationTitle("Workout List")
        }
    }
}

#Preview {
    WorkoutList()
}
