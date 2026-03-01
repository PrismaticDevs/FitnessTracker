import SwiftUI
import Combine
import SwiftData

@MainActor
class ExerciseSeeder {
    static func seed(context: ModelContext) {
        let descriptor = FetchDescriptor<ExerciseCategory>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        // Only seed if the database is empty
        guard existingCount == 0 else { return }
        
        // Pull the hardcoded list
        let seedData = ExerciseList().categories
        
        for category in seedData {
            category.userId = "system" // Force the tag
            
            // Tag children as well to ensure total consistency
            for exercise in category.exercises {
                exercise.userId = "system"
            }
            
            context.insert(category)
        }
        
        try? context.save()
    }
}

// Define the ExerciseList class
class ExerciseList: ObservableObject {
    @Published var categories: [ExerciseCategory] = [
        ExerciseCategory(name: "Chest", exercises: [
            Exercise(name: "Close Grip Bench Press", type: .strength),
            Exercise(name: "Converging Chest Press", type: .strength),
            Exercise(name: "Incline Barbell Bench Press", type: .strength),
            Exercise(name: "Chest Press", type: .strength),
            Exercise(name: "Cable Crossover", type: .strength),
            Exercise(name: "Chest Fly", type: .strength),
            Exercise(name: "Flat Dumbbell Bench Press", type: .strength),
            Exercise(name: "Dumbbell Fly", type: .strength),
            Exercise(name: "Incline Dumbbell Fly", type: .strength),
            Exercise(name: "Pec Deck Machine", type: .strength),
            Exercise(name: "Push-Up Variations", type: .strength)
        ]),
        ExerciseCategory(name: "Shoulders", exercises: [
            Exercise(name: "Shoulder Press", type: .strength),
            Exercise(name: "Converging Shoulder Press", type: .strength),
            Exercise(name: "Dumbbell Rear Delt Fly", type: .strength),
            Exercise(name: "Rear Delt Machine", type: .strength),
            Exercise(name: "Cable Face Pull", type: .strength),
            Exercise(name: "Dumbbell Shrug", type: .strength),
            Exercise(name: "Seated Lateral Raise", type: .strength),
            Exercise(name: "Lateral Raise Mx", type: .strength),
            Exercise(name: "Single Arm Cable Lateral Raise", type: .strength),
            Exercise(name: "Arnold Press", type: .strength),
            Exercise(name: "Upright Row", type: .strength),
            Exercise(name: "Front Raise", type: .strength),
            Exercise(name: "Cable Lateral Raise", type: .strength),
            Exercise(name: "Dumbbell Front Raise", type: .strength)
        ]),
        ExerciseCategory(name: "Abdominals", exercises: [
            Exercise(name: "Abdominal Machine", type: .strength),
            Exercise(name: "Cable Crunch", type: .strength),
            Exercise(name: "Leg Raise", type: .strength),
            Exercise(name: "Plank", type: .strength),
            Exercise(name: "Russian Twist", type: .strength),
            Exercise(name: "Bicycle Crunch", type: .strength),
            Exercise(name: "Hanging Leg Raise", type: .strength),
            Exercise(name: "Medicine Ball Slam", type: .strength),
            Exercise(name: "Side Plank", type: .strength),
            Exercise(name: "Dead Bug", type: .strength),
            Exercise(name: "Stability Ball Rollouts", type: .strength)
        ]),
        ExerciseCategory(name: "Legs", exercises: [
            Exercise(name: "Deadlift", type: .strength),
            Exercise(name: "Lying Leg Curl", type: .strength),
            Exercise(name: "Walking Lunge", type: .strength),
            Exercise(name: "Back Squat", type: .strength),
            Exercise(name: "Hack Squat", type: .strength),
            Exercise(name: "Leg Extension", type: .strength),
            Exercise(name: "Seated Calf Raise", type: .strength),
            Exercise(name: "Standing Calf Raise", type: .strength),
            Exercise(name: "Calf Press", type: .strength),
            Exercise(name: "Leg Press", type: .strength),
            Exercise(name: "Hip Abduction", type: .strength),
            Exercise(name: "Front Squat", type: .strength),
            Exercise(name: "Sumo Deadlift", type: .strength),
            Exercise(name: "Bulgarian Split Squat", type: .strength),
            Exercise(name: "Step-Up", type: .strength),
            Exercise(name: "Glute Bridge", type: .strength),
            Exercise(name: "Single-Leg Deadlift", type: .strength),
            Exercise(name: "Hip Adduction", type: .strength)
        ]),
        ExerciseCategory(name: "Arms", exercises: [
            Exercise(name: "Barbell Curl", type: .strength),
            Exercise(name: "Hammer Curl", type: .strength),
            Exercise(name: "Cable Curl", type: .strength),
            Exercise(name: "Preacher Curl Mx", type: .strength),
            Exercise(name: "Biceps Curl Mx", type: .strength),
            Exercise(name: "Rope Tricep Extension", type: .strength),
            Exercise(name: "Tricep Extension Mx", type: .strength),
            Exercise(name: "Triceps Press", type: .strength),
            Exercise(name: "Weighted Dip", type: .strength),
            Exercise(name: "Skull Crusher", type: .strength),
            Exercise(name: "Concentration Curl", type: .strength),
            Exercise(name: "Cable Tricep Pushdown", type: .strength),
            Exercise(name: "Dumbbell Kickback", type: .strength),
            Exercise(name: "Zottman Curl", type: .strength)
        ]),
        ExerciseCategory(name: "Back", exercises: [
            Exercise(name: "Bent-Over Barbell Row", type: .strength),
            Exercise(name: "Bent-Over Dumbbell Row", type: .strength),
            Exercise(name: "Dumbbell Pullover", type: .strength),
            Exercise(name: "Wide Grip Lat Pulldown", type: .strength),
            Exercise(name: "Diverging Lat Pull Down", type: .strength),
            Exercise(name: "Pulldown", type: .strength),
            Exercise(name: "Seated Row", type: .strength),
            Exercise(name: "Row", type: .strength),
            Exercise(name: "T-Bar Row", type: .strength),
            Exercise(name: "Pull-Up/Chin-Up", type: .strength),
            Exercise(name: "Single-Arm Dumbbell Row", type: .strength)
        ]),
        ExerciseCategory(name: "Cardio", exercises: [
            Exercise(name: "Treadmill", type: .cardio),
            Exercise(name: "Stationary Bike", type: .cardio),
            Exercise(name: "Rowing Machine", type: .cardio),
            Exercise(name: "Stairmaster", type: .cardio),
            Exercise(name: "Elliptical Trainer", type: .cardio),
            Exercise(name: "Jump Rope", type: .cardio),
            Exercise(name: "Outdoor Run", type: .cardio),
            Exercise(name: "Swimming", type: .cardio),
            Exercise(name: "Battle Ropes", type: .cardio),
            Exercise(name: "Burpees", type: .cardio),
            Exercise(name: "Shuttle Runs", type: .cardio),
            Exercise(name: "HIIT", type: .cardio)
        ]),
        ExerciseCategory(name: "Mobility & Flexibility", exercises: [
            // Lower Body
            Exercise(name: "Couch Stretch", type: .mobility),
            Exercise(name: "90/90 Hip Switch", type: .mobility),
            Exercise(name: "Pigeon Pose", type: .mobility),
            Exercise(name: "Frog Stretch", type: .mobility),
            Exercise(name: "World's Greatest Stretch", type: .mobility),
            Exercise(name: "Ankle Dorsiflexion", type: .mobility),
            Exercise(name: "Hamstring PNF Stretch", type: .mobility),
            // Upper Body
            Exercise(name: "Thoracic Spine Extensions", type: .mobility),
            Exercise(name: "Shoulder Dislocations (PVC)", type: .mobility),
            Exercise(name: "Scapular CARs", type: .mobility),
            Exercise(name: "Puppy Pose", type: .mobility),
            // Spine & Balance
            Exercise(name: "Cat-Cow", type: .mobility),
            Exercise(name: "Deep Squat Hold", type: .mobility),
            Exercise(name: "Downward Dog", type: .mobility),
            Exercise(name: "Cobra Pose", type: .mobility),
            Exercise(name: "Child’s Pose", type: .mobility),
            Exercise(name: "Foam Rolling", type: .mobility),
            Exercise(name: "Bosu Ball Balance", type: .mobility),
            Exercise(name: "Tai Chi Movements", type: .mobility)
        ]),
        ExerciseCategory(name: "Full Body & Plyos", exercises: [
            Exercise(name: "Kettlebell Swing", type: .strength),
            Exercise(name: "Thrusters", type: .strength),
            Exercise(name: "Medicine Ball Toss", type: .strength),
            Exercise(name: "Box Jumps", type: .strength),
            Exercise(name: "Jump Squats", type: .strength),
            Exercise(name: "Lateral Bounds", type: .strength)
        ])
    ]
}
