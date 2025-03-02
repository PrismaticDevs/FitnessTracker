import SwiftUI
import Combine

// Define the ExerciseList class
class ExerciseList: ObservableObject {
    @Published var categories: [ExerciseCategory] = [
        ExerciseCategory(name: "Chest", exercises: [
            Exercise(name: "Close Grip Bench Press"),
            Exercise(name: "Converging Chest Press"),
            Exercise(name: "Incline Barbell Bench Press"),
            Exercise(name: "Chest Press"),
            Exercise(name: "Cable Crossover"),
            Exercise(name: "Chest Fly"),
            Exercise(name: "Flat Dumbbell Bench Press"),
            Exercise(name: "Dumbbell Fly"),
            Exercise(name: "Incline Dumbbell Fly"),
            Exercise(name: "Pec Deck Machine"),
            Exercise(name: "Push-Up Variations (e.g., Decline Push-Up, Plyometric Push-Up)")
        ]),
        ExerciseCategory(name: "Shoulders", exercises: [
            Exercise(name: "Bent-Over Barbell Row"),
            Exercise(name: "Dumbbell Pullover"),
            Exercise(name: "Shoulder Press"),
            Exercise(name: "Converging Shoulder Press"),
            Exercise(name: "Wide Grip Lat Pulldown"),
            Exercise(name: "Diverging Lat Pull Down"),
            Exercise(name: "Pulldown"),
            Exercise(name: "Seated Row"),
            Exercise(name: "Row"),
            Exercise(name: "Dumbbell Rear Delt Fly"),
            Exercise(name: "Rear Delt Machine"),
            Exercise(name: "Cable Face Pull"),
            Exercise(name: "Dumbbell Shrug"),
            Exercise(name: "Seated Lateral Raise"),
            Exercise(name: "Lateral Raise Mx"),
            Exercise(name: "Single Arm Cable Lateral Raise"),
            Exercise(name: "Arnold Press"),
            Exercise(name: "Upright Row"),
            Exercise(name: "Front Raise"),
            Exercise(name: "Cable Lateral Raise"),
            Exercise(name: "Dumbbell Front Raise")
        ]),
        ExerciseCategory(name: "Abdominals", exercises: [
            Exercise(name: "Abdominal Machine"),
            Exercise(name: "Cable Crunch"),
            Exercise(name: "Leg Raise"),
            Exercise(name: "Plank"),
            Exercise(name: "Russian Twist"),
            Exercise(name: "Bicycle Crunch"),
            Exercise(name: "Hanging Leg Raise"),
            Exercise(name: "Medicine Ball Slam"),
            Exercise(name: "Side Plank")
        ]),
        ExerciseCategory(name: "Legs", exercises: [
            Exercise(name: "Deadlift"),
            Exercise(name: "Lying Leg Curl"),
            Exercise(name: "Walking Lunge"),
            Exercise(name: "Back Squat"),
            Exercise(name: "Hack Squat"),
            Exercise(name: "Leg Extension"),
            Exercise(name: "Seated Calf Raise"),
            Exercise(name: "Standing Calf Raise"),
            Exercise(name: "Calf Press"),
            Exercise(name: "Leg Press"),
            Exercise(name: "Hip Abduction"),
            Exercise(name: "Front Squat"),
            Exercise(name: "Sumo Deadlift"),
            Exercise(name: "Bulgarian Split Squat"),
            Exercise(name: "Step-Up"),
            Exercise(name: "Glute Bridge"),
            Exercise(name: "Single-Leg Deadlift")
        ]),
        ExerciseCategory(name: "Arms", exercises: [
            Exercise(name: "Barbell Curl"),
            Exercise(name: "Hammer Curl"),
            Exercise(name: "Cable Curl"),
            Exercise(name: "Preacher Curl Mx"),
            Exercise(name: "Biceps Curl Mx"),
            Exercise(name: "Rope Tricep Extension"),
            Exercise(name: "Tricep Extension Mx"),
            Exercise(name: "Triceps Press"),
            Exercise(name: "Weighted Dip"),
            Exercise(name: "Skull Crusher"),
            Exercise(name: "Concentration Curl"),
            Exercise(name: "Cable Tricep Pushdown"),
            Exercise(name: "Dumbbell Kickback"),
            Exercise(name: "Zottman Curl")
        ]),
        ExerciseCategory(name: "Back", exercises: [
            Exercise(name: "Bent-Over Dumbbell Row"),
            Exercise(name: "T-Bar Row"),
            Exercise(name: "Pull-Up/Chin-Up"),
            Exercise(name: "Seated Cable Row"),
            Exercise(name: "Single-Arm Dumbbell Row")
        ]),
        ExerciseCategory(name: "Full Body", exercises: [
            Exercise(name: "Kettlebell Swing"),
            Exercise(name: "Burpees"),
            Exercise(name: "Thrusters"),
            Exercise(name: "Battle Ropes"),
            Exercise(name: "Medicine Ball Toss")
        ]),
        ExerciseCategory(name: "Cardio", exercises: [
            Exercise(name: "Treadmill Running"),
            Exercise(name: "Stationary Biking"),
            Exercise(name: "Rowing Machine"),
            Exercise(name: "Jump Rope"),
            Exercise(name: "Elliptical Trainer")
        ]),
            ExerciseCategory(name: "Core", exercises: [
                Exercise(name: "Plank"),
                Exercise(name: "Side Plank"),
                Exercise(name: "Hanging Knee Raises"),
                Exercise(name: "Medicine Ball Russian Twists"),
                Exercise(name: "Stability Ball Rollouts"),
                Exercise(name: "Dead Bug")
            ]),
            ExerciseCategory(name: "Plyometrics", exercises: [
                Exercise(name: "Box Jumps"),
                Exercise(name: "Jump Squats"),
                Exercise(name: "Burpee Tuck Jumps"),
                Exercise(name: "Plyometric Push-Ups"),
                Exercise(name: "Lateral Bounds")
            ]),
            ExerciseCategory(name: "Flexibility and Mobility", exercises: [
                Exercise(name: "Dynamic Stretching"),
                Exercise(name: "Static Stretching"),
                Exercise(name: "Downward Dog"),
                Exercise(name: "Cobra Pose"),
                Exercise(name: "Foam Rolling"),
                Exercise(name: "Hip Openers")
            ]),
            ExerciseCategory(name: "Balance and Stability", exercises: [
                Exercise(name: "Single-Leg Deadlifts"),
                Exercise(name: "Bosu Ball Exercises"),
                Exercise(name: "Stability Ball Pass"),
                Exercise(name: "Balance Board Exercises"),
                Exercise(name: "Tai Chi Movements")
            ]),
            ExerciseCategory(name: "Agility", exercises: [
                Exercise(name: "Ladder Drills"),
                Exercise(name: "Cone Drills"),
                Exercise(name: "Shuttle Runs"),
                Exercise(name: "Hurdle Drills"),
                Exercise(name: "Quick Feet Drills")
            ]),
            ExerciseCategory(name: "Endurance", exercises: [
                Exercise(name: "Long-Distance Running"),
                Exercise(name: "Cycling"),
                Exercise(name: "Swimming"),
                Exercise(name: "Rowing"),
                Exercise(name: "High-Intensity Interval Training (HIIT)")
            ])
        ]
    }
