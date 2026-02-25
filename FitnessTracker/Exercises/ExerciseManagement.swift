//
//  ExerciseManagement.swift
//  FitnessTracker
//
//  Created by Matt on 1/17/26.
//
import SwiftUI
import SwiftData
import FirebaseAuth

struct ExerciseManagement: View {
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedType: ExerciseType = .strength
    
    @Query var categories: [ExerciseCategory] = []
    @State private var newCategoryName: String = ""
    @State private var selectedCategoryID: PersistentIdentifier? // Use this as the single source of truth
    @State private var expandedCategories: Set<PersistentIdentifier> = []
    @State private var exerciseToDelete: Exercise?
    @State private var dragOffset: CGFloat = 0
    @FocusState private var isFocused: Bool?
    
    let userId: String
    let exerciseTypes: [ExerciseType] = [.strength, .cardio, .mobility]

    init(userId: String) {
        self.userId = userId
        let predicate = #Predicate<ExerciseCategory> { category in
            category.userId == userId || category.userId == "system"
        }
        _categories = Query(filter: predicate, sort: \.name)
        
        // Custom Segmented Control Appearance
        let appearance = UISegmentedControl.appearance()
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        appearance.selectedSegmentTintColor = UIColor(ThemeManager.shared.currentTheme.accent2)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
    }

    var filteredResults: [ExerciseCategory] {
        if searchText.isEmpty { return categories }
        return categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText) ||
            category.exercises.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var exactMatchFound: Bool {
        categories.contains { cat in
            cat.exercises.contains { $0.name.caseInsensitiveCompare(searchText) == .orderedSame }
        }
    }

    var body: some View {
        ZStack {
            Form {
                // 1. Management: Create Category
                managementSection
                
                // 2. Creation: Add Exercise to existing/new category
                creationSection
                
                // 3. Library: Browse all
                librarySection
            }
            .offset(x: dragOffset)
            .padding(.top, 130)
            .scrollContentBackground(.hidden)
            
            // Drag to dismiss logic stays the same...
            leadingDragOverlay
        }
        .onAppear {
            if categories.isEmpty { ExerciseSeeder.seed(context: context) }
        }
        .onTapGesture { isFocused = nil }
        .applyGradientBackground()
        .brandedBackButton(title: "Add Exercise", theme: theme.currentTheme, dismiss: dismiss)
        .confirmationDialog(
            "Are you sure?",
            isPresented: Binding(
                get: { exerciseToDelete != nil },
                set: { if !$0 { exerciseToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove Exercise", role: .destructive) {
                deleteTargetExercise()
            }
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
        } message: {
            Text("This will permanently delete '\(exerciseToDelete?.name ?? "this exercise")'. Any previous workout data associated with it will no longer show the exercise name.")
        }
    }
}

// MARK: - Sub-Views
extension ExerciseManagement {
    
    private var managementSection: some View {
        Section(header: Text("Quick Actions").foregroundColor(.white.opacity(0.6))) {
            HStack {
                TextField("", text: $newCategoryName, prompt: Text("New Category (e.g. Kettlebells)").foregroundColor(.white.opacity(0.6)))
                    .focused($isFocused, equals: true)
                
                Button(action: createNewCategory) {
                    Label("", systemImage: "folder.badge.plus")
                        .fontWeight(.bold)
                        .foregroundColor(newCategoryName.isEmpty ? .gray : .yellow)
                }
                .disabled(newCategoryName.isEmpty)
            }
        }
        .listRowBackground(theme.currentTheme.accent.opacity(0.8))
    }

    private var creationSection: some View {
        Section(header: Text("Add New Exercise").foregroundColor(.white.opacity(0.6))) {
            // Category Picker linked to ID
            Picker("Target Category", selection: $selectedCategoryID) {
                Text("Select Category").tag(nil as PersistentIdentifier?)
                ForEach(categories) { cat in
                    Text(cat.name).tag(cat.id as PersistentIdentifier?)
                }
            }
            .pickerStyle(.menu)
            .tint(.yellow)

            TextField("", text: $searchText, prompt: Text("Exercise Name (e.g. Bench Press)").foregroundColor(.white.opacity(0.7)))
                .focused($isFocused, equals: true)

            if !searchText.isEmpty && !exactMatchFound {
                VStack(spacing: 12) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(exerciseTypes, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Button(action: createNewExercise) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Create '\(searchText)'")
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(selectedCategoryID == nil ? Color.gray.opacity(0.3) : Color.yellow.opacity(0.8))
                        .cornerRadius(10)
                    }
                    .disabled(selectedCategoryID == nil || searchText.isEmpty)
                }
                .padding(.vertical, 8)
            }
        }
        .listRowBackground(theme.currentTheme.accent)
    }

    private var librarySection: some View {
        Section(header: Text("Exercise Library").foregroundColor(.white.opacity(0.6))) {
            ForEach(filteredResults) { category in
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedCategories.contains(category.id) || !searchText.isEmpty },
                        set: { isExpanded in
                            if isExpanded { expandedCategories.insert(category.id) }
                            else { expandedCategories.remove(category.id) }
                        }
                    ),
                    content: {
                        let displayExercises = category.exercises.filter {
                            searchText.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(searchText)
                        }
                        ForEach(displayExercises) { exercise in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name).foregroundColor(.white)
                                    Text(exercise.type?.rawValue.capitalized ?? "Strength").font(.caption2).foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Button { exerciseToDelete = exercise } label: {
                                    Image(systemName: "trash").foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    },
                    label: {
                        Text(category.name).fontWeight(.medium).foregroundColor(.white)
                    }
                )
            }
        }
        .listRowBackground(theme.currentTheme.accent.opacity(0.4))
    }
    
    // Abstracted dismissal gesture
    private var leadingDragOverlay: some View {
        GeometryReader { geo in
            Color.clear
                .frame(width: 24)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    DragGesture().onChanged { val in
                        if val.startLocation.x < 24 && val.translation.width > 0 {
                            dragOffset = val.translation.width
                        }
                    }
                    .onEnded { val in
                        if dragOffset > 80 { dismiss() }
                        else { withAnimation { dragOffset = 0 } }
                    }
                )
        }
    }
}

// MARK: - Logic Fixes
extension ExerciseManagement {
    private func createNewExercise() {
        guard let id = selectedCategoryID,
              let category = categories.first(where: { $0.id == id }),
              !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let name = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Avoid duplicate exercise names within the same category (case-insensitive)
        let duplicate = category.exercises.contains { $0.name.caseInsensitiveCompare(name) == .orderedSame }
        guard !duplicate else {
            // Simply reset focus to hint the user nothing happened due to duplicate
            isFocused = nil
            return
        }

        let newEx = Exercise(name: name, type: selectedType)
        newEx.userId = userId

        // Ensure the object is tracked by the context so it receives a persistent ID
        context.insert(newEx)
        category.exercises.append(newEx)

        do {
            try context.save()
            // Expand the category to show the new exercise
            expandedCategories.insert(category.id)
        } catch {
            // If save fails, remove the appended exercise to keep local state consistent
            category.exercises.removeAll { $0.id == newEx.id }
        }

        // Reset fields
        searchText = ""
        isFocused = nil
        
        dismiss()
    }

    private func createNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        let newCat = ExerciseCategory(name: newCategoryName, exercises: [])
        newCat.userId = userId
        context.insert(newCat)
        
        // CRITICAL FIX: Save context to generate the ID, then select it
        try? context.save()
        selectedCategoryID = newCat.id
        
        newCategoryName = ""
    }

    private func deleteTargetExercise() {
        guard let exercise = exerciseToDelete else { return }
        // Find the category containing this exercise
        if let category = categories.first(where: { $0.exercises.contains(where: { $0.id == exercise.id }) }) {
            category.exercises.removeAll(where: { $0.id == exercise.id })
            context.delete(exercise)
            try? context.save()
        }
        exerciseToDelete = nil
    }
}

