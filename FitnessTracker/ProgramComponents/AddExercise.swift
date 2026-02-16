//
//  AddExercise.swift
//  FitnessTracker
//
//  Created by Matt on 1/17/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct AddExercise: View {
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Query(sort: \ExerciseCategory.name) var categories: [ExerciseCategory] = []
    
    @State private var name: String = ""
    @State private var type: String = ""
    @State private var exerciseTypes = ["Strength", "Cardio", "Mobility"]
    @State private var selectedExercise = "Strength"
    @State private var exerciseCategory: ExerciseCategory?
    @State private var searchText: String = ""
    @State private var showCreateConfirmation = false
    @FocusState private var isFocused: Bool?
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        let predicate = #Predicate<ExerciseCategory> { category in
            category.userId == userId
        }
        _categories = Query(filter: predicate, sort: \.name)
    }
    
    var filteredResults: [ExerciseCategory] {
        if searchText.isEmpty {
            return categories
        }
        return categories.compactMap { category in
            let matchingExercises = category.exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(searchText)
            }
            
            if category.name.localizedCaseInsensitiveContains(searchText) || !matchingExercises.isEmpty {
                return category
            }
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    TextField("", text: $searchText, prompt: Text("Search or Add New...").foregroundColor(.white.opacity(0.7)))
                        .focused($isFocused, equals: true)
                        .textFieldStyle(.plain)
                        .listRowBackground(theme.currentTheme.accent)
                    if !searchText.isEmpty {
                        ForEach(filteredResults) { category in
                            // Filter the specific exercises for display in this section
                            let displayExercises = category.exercises.filter {
                                $0.name.localizedCaseInsensitiveContains(searchText)
                            }
                            
                            Section(header: Text(category.name).foregroundColor(.white)) {
                                ForEach(displayExercises) { exercise in
                                    Button {
                                        addExerciseToSession(exercise)
                                    } label: {
                                        HStack {
                                            Text(exercise.name).foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                            }
                            .listRowBackground(theme.currentTheme.accent.opacity(0.5))
                        }
                    }
                }
                Section(header: Text("Add New Exercise")) {
                    Picker("Category", selection: $exerciseCategory) {
                        ForEach(categories, id: \.id) { category in
                            Text(category.name)
                        }
                    }
                    .padding(.horizontal)
                    .tint(.white)
                    .listRowBackground(theme.currentTheme.accent)
                    TextField(
                        "", // You can leave the title empty if using prompt
                        text: $name,
                        prompt: Text("Exercise Name")
                            .foregroundColor(.white.opacity(0.8))
                    )
                    .listRowBackground(theme.currentTheme.accent) // Applied to the TextField
                    .overlay(
                        Button(action: {
                            name = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(name.isEmpty ? 0 : 1)
                                .padding()
                        }
                            .foregroundColor(.white)
                        .padding(),
                        alignment: .trailing
                    )

                    Picker("Exercise Type", selection: $selectedExercise) {
                        ForEach(exerciseTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    .tint(.white)
                    .listRowBackground(theme.currentTheme.accent)
                    Section {
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Add Exercise")
                                Spacer()
                                Image(systemName: "plus")
                            }
                        }
                        .listRowBackground(theme.currentTheme.accent)
                    }
                }
            }
            .padding(.top, 130)
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        .applyGradientBackground()
        .brandedBackButton(title: "Add Exercise", theme: theme.currentTheme, dismiss: dismiss)
    }
    
    // MARK: - Logic Parts
        
    private func addExerciseToSession(_ exercise: Exercise) {
        // Here you would logic to add it to the specific workout session
        print("Adding \(exercise.name) to current workout")
        dismiss()
    }

    private func createNewExercise() {
        let newEx = Exercise(name: searchText, type: .strength) // Default to strength or use a picker
        // Logic to find a "Custom" or "Misc" category or add to first
        if let firstCategory = categories.first {
            firstCategory.exercises.append(newEx)
        }
        try? context.save()
        searchText = ""
        isFocused = nil
    }

    private func deleteFromLibrary(_ exercise: Exercise, in category: ExerciseCategory) {
        // Remove relationship and delete object
        if let index = category.exercises.firstIndex(where: { $0.id == exercise.id }) {
            category.exercises.remove(at: index)
            context.delete(exercise)
            try? context.save()
        }
    }
}

