import SwiftUI
import Combine

class ExerciseList:ObservableObject {
    
    @Published var Chest = [
        "Close Grip Bench Press",
        "Converging Chest Press",
        "Incline Barbell Bench Press",
        "Chest Press",
        "Cable Crossover",
        "Chest Fly",
        "Flat Dumbbell Bench Press",
        "Dumbbell Fly",
        "Incline Dumbbell Fly",
        "Pec Deck Machine",
        "Push-Up Variations (e.g., Decline Push-Up, Plyometric Push-Up)"
    ]
    
    @Published var Shoulders = [
        "Bent-Over Barbell Row",
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
        "Dumbbell Shrug",
        "Seated Lateral Raise",
        "Lateral Raise Mx",
        "Single Arm Cable Lateral Raise",
        "Arnold Press",
        "Upright Row",
        "Front Raise",
        "Cable Lateral Raise",
        "Dumbbell Front Raise"
    ]
    
    @Published var Abdominals = [
        "Abdominal Machine",
        "Cable Crunch",
        "Leg Raise",
        "Plank",
        "Russian Twist",
        "Bicycle Crunch",
        "Hanging Leg Raise",
        "Medicine Ball Slam",
        "Side Plank"
    ]
    
    @Published var Legs = [
        "Deadlift",
        "Lying Leg Curl",
        "Walking Lunge",
        "Back Squat",
        "Hack Squat",
        "Leg Extension",
        "Seated Calf Raise",
        "Standing Calf Raise",
        "Calf Press",
        "Leg Press",
        "Hip Abduction",
        "Front Squat",
        "Sumo Deadlift",
        "Bulgarian Split Squat",
        "Step-Up",
        "Glute Bridge",
        "Single-Leg Deadlift"
    ]
    
    @Published var Arms = [
        "Barbell Curl",
        "Hammer Curl",
        "Cable Curl",
        "Preacher Curl Mx",
        "Biceps Curl Mx",
        "Rope Tricep Extension",
        "Tricep Extension Mx",
        "Triceps Press",
        "Weighted Dip",
        "Skull Crusher",
        "Concentration Curl",
        "Cable Tricep Pushdown",
        "Dumbbell Kickback",
        "Zottman Curl"
    ]
    
    // New categories
    @Published var Back = [
        "Bent-Over Dumbbell Row",
        "T-Bar Row",
        "Pull-Up/Chin-Up",
        "Seated Cable Row",
        "Single-Arm Dumbbell Row"
    ]
    
    @Published var FullBody = [
        "Kettlebell Swing",
        "Burpees",
        "Thrusters",
        "Battle Ropes",
        "Medicine Ball Toss"
    ]
    
    @Published var Cardio = [
        "Treadmill Running",
        "Stationary Biking",
        "Rowing Machine",
        "Jump Rope",
        "Elliptical Trainer"
    ]
}
