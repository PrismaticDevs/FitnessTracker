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
                            Button {
                                print("\(Arms[exercise])")
                                      
                            } label: {
                                Text(Arms[exercise])
                                .foregroundColor(Color.white)
                            }
                                
                            
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
            .toolbar {
                Menu {
                    Menu {
                        ForEach(ExerciseList().Abdominals, id: \.self) { exercise in
                            Button {
                                print(exercise)
                            } label: {
                                Label(exercise, systemImage: "plus.circle.fill")
                            }
                        }
                    } label: {
                        Label("Abdominals", systemImage: "plus.circle.fill")
                    }
                    Menu {
                        ForEach(ExerciseList().Arms, id: \.self) { exercise in
                            Button {
                                print(exercise)
                            } label: {
                                Label(exercise, systemImage: "plus.circle.fill")
                            }
                        }
                    } label: {
                        Label("Arms", systemImage: "plus.circle.fill")
                    }
                    Menu {
                        ForEach(ExerciseList().Chest, id: \.self) { exercise in
                            Button {
                                print(exercise)
                            } label: {
                                Label(exercise, systemImage: "plus.circle.fill")
                            }
                        }
                    } label: {
                        Label("Chest", systemImage: "plus.circle.fill")
                    }
                    Menu {
                        ForEach(ExerciseList().Shoulders, id: \.self) { exercise in
                            Button {
                                print(exercise)
                            } label: {
                                Label(exercise, systemImage: "plus.circle.fill")
                            }
                        }
                    } label: {
                        Label("Shoulders", systemImage: "plus.circle.fill")
                    }
                    Menu {
                        ForEach(ExerciseList().Legs, id: \.self) { exercise in
                            Button {
                                print(exercise)
                            } label: {
                                Label(exercise, systemImage: "plus.circle.fill")
                            }
                        }
                    } label: {
                        Label("Legs", systemImage: "plus.circle.fill")
                    }
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                }
            }
        }
    }
}

#Preview {
    WorkoutList()
}

