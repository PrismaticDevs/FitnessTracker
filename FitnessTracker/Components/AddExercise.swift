//
//  AddExercise.swift
//  FitnessTracker
//
//  Created by Matt on 1/17/26.
//

import SwiftUI
import SwiftData

struct AddExercise: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Exercise.name) var exercises: [Exercise] = []
    @Query(sort: \ExerciseCategory.name) var categories: [ExerciseCategory] = []
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var exerciseTypes = ["Strength", "Cardio", "Mobility"]
    @State private var exerciseCategory: ExerciseCategory?
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Add New Exercise")) {
                    Picker("Category", selection: $exerciseCategory) {
                        ForEach(categories, id: \.id) { category in
                            Text(category.name)
                        }
                    }
                    .tint(ColorPalette.primary)
                    .listRowBackground(ColorPalette.accent)
                    TextField(
                        "", // You can leave the title empty if using prompt
                        text: $name,
                        prompt: Text("Exercise Name")
                            .foregroundColor(ColorPalette.primary.opacity(0.8))
                    )
                    .listRowBackground(ColorPalette.accent) // Applied to the TextField
                    .overlay(
                        Button(action: {
                            name = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(name.isEmpty ? 0 : 1)
                                .padding()
                        }
                        .foregroundColor(ColorPalette.primary)
                        .padding(),
                        alignment: .trailing
                    )
                    Text("Choose Exercise Type")
                        .listRowBackground(ColorPalette.accent)
                    Picker("Type", selection: $type) {
                        ForEach(exerciseTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .tint(ColorPalette.primary)
                    .listRowBackground(ColorPalette.accent)
                    Section {
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Add Exercise")
                                Spacer()
                                Image(systemName: "plus")
                            }
                        }
                        .listRowBackground(ColorPalette.accent2)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        .applyGradientBackground()
    }
}

#Preview {
    let mockAuthManager = MockAuthManager()
    AddExercise()
        .environmentObject(mockAuthManager)
}
