import SwiftUI
import Combine

@Observable class ExerciseList {
    var id: UUID = UUID()
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
