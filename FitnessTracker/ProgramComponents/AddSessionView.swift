//
//  AddSessionView.swift
//  FitnessTracker
//
//  Created by Matt on 12/21/25.
//

import SwiftUI
import SwiftData

struct AddSessionView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var theme: ThemeManager
    
    // 1. Pass in the program you want to add sessions to
    @Bindable var program: WorkoutProgram
    
    // We only need local state for the session we are currently building
    @State private var sessionName: String = ""
    @State private var selectedExercises: [Exercise] = []
    
    @FocusState private var isFocused: Bool?
    
    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Add Session to")
                            .font(.headline).bold()
                            .foregroundColor(.white)
                        Text("\(program.title)")
                            .font(.title).bold()
                            .foregroundColor(.white)

                        // Section for the New Session Name
                        VStack(alignment: .leading) {
                            Text("Session Name").font(.headline).foregroundColor(.white)
                            TextField("e.g. Upper Body A", text: $sessionName)
                                .focused($isFocused, equals: true)
                                .padding()
                                .background(theme.currentTheme.accent)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }

                        // Section for Exercises in this new session
                        VStack(alignment: .leading) {
                            Text("Exercises").font(.headline).foregroundColor(.white)
                            
                            if selectedExercises.isEmpty {
                                ContentUnavailableView(label: {
                                    Label("No exercises added yet", systemImage: "list.bullet.rectangle.portrait")
                                        .foregroundColor(.white)
                                }, description: {
                                    Text("Start adding exercises")
                                        .foregroundColor(.white)
                                })
                            } else {
                                ForEach(selectedExercises) { exercise in
                                    HStack {
                                        Text(exercise.name)
                                        Spacer()
                                        Button(action: {
                                            selectedExercises.removeAll(where: { $0.id == exercise.id })
                                        }) {
                                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Reuse your toolbar to add to the local list
                            ExerciseToolbar(
                                exerciseName: .constant(""),
                                exercisesSelected: selectedExercises.map { $0.name },
                                onExerciseSelected: { name in
                                    let newExercise = Exercise(name: name)
                                    selectedExercises.append(newExercise)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onTapGesture {
            isFocused = nil
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save Session") {
                    saveSessionToProgram()
                }
                .disabled(sessionName.isEmpty || selectedExercises.isEmpty)
            }
        }
    }
    
    private func saveSessionToProgram() {
        // 2. Create the session and attach it to the existing program
        let newSession = Session(name: sessionName, exercises: selectedExercises)
        program.sessions.append(newSession)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Error saving session: \(error)")
        }
    }
}
