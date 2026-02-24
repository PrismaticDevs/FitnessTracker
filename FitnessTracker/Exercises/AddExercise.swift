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
    //Shared Environment
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    // Search state
    @State private var searchText: String = ""
    @State private var selectedType: ExerciseType = .strength
    // Categories
    @Query var categories: [ExerciseCategory] = []
    @State private var newCategoryName: String = ""
    @State private var selectedCategoryID: PersistentIdentifier?
    @State private var selectedCategory: ExerciseCategory?
    @State private var expandedCategories: Set<PersistentIdentifier> = []
    //Exercise Deletion
    @State private var exerciseToDelete: Exercise?
    // Focus and swipe
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
        
        // --- CORRECTED STYLING ---
        let appearance = UISegmentedControl.appearance()
        
        // Text color for segments
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.7)], for: .normal)
        
        // Background color of the selected "sliding" segment
        appearance.selectedSegmentTintColor = UIColor(theme.currentTheme.accent2)
        
        // Background color of the whole picker track (using withAlphaComponent)
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

    // MARK: View body
    var body: some View {
        ZStack {
            Form {
                // 1. Management (New Category) moved to the top
                managementSection
                
                // 2. Creation (Exercise Details)
                creationSection
                
                // 3. Library (Browsing)
                librarySection
            }
            .offset(x: dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
            .padding(.top, 130)
            .scrollContentBackground(.hidden)
            
            // Side-drag dismiss area
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
        .onAppear {
            if categories.isEmpty { ExerciseSeeder.seed(context: context) }
        }
        .onTapGesture { isFocused = nil }
        .applyGradientBackground()
        .brandedBackButton(title: "Add Exercise", theme: theme.currentTheme, dismiss: dismiss)
        .alert("Remove Exercise?", isPresented: Binding(get: { exerciseToDelete != nil }, set: { if !$0 { exerciseToDelete = nil } })) {
            Button("Remove", role: .destructive) { deleteTargetExercise() }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// MARK: - Sub-Views for Form Sections
extension AddExercise {
    
    private var creationSection: some View {
        Section(header: Text("Exercise Details").foregroundColor(.white.opacity(0.6))) {
            // 1. Always visible Category Picker
            Picker("Category", selection: $selectedCategoryID) {
                Text("Select a Category").tag(nil as PersistentIdentifier?)
                ForEach(categories) { cat in
                    Text(cat.name)
                        .tag(cat.id as PersistentIdentifier?)
                }
            }
            .pickerStyle(.menu) // Force it to be a menu
            .tint(.yellow)      // Make it pop
            .buttonStyle(.borderless) // Prevents the Form from hijacking the tap
            
            // 2. Search / Name Input
            TextField("", text: $searchText, prompt: Text("Search or New Exercise Name...").foregroundColor(.white.opacity(0.7)))
                .focused($isFocused, equals: true)

            // 3. Type Picker (Only shows if we are actually creating something new)
            if !searchText.isEmpty && !exactMatchFound {
                Picker("Type", selection: $selectedType) {
                    ForEach(exerciseTypes, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 5)
                
                Button(action: createNewExercise) {
                    HStack {
                        Image(systemName: "sparkles").foregroundColor(.yellow)
                        Text("Create '\(searchText)'").foregroundColor(.white).fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "plus.circle.fill").foregroundColor(.yellow)
                    }
                }
                .disabled(selectedCategory == nil)
            }
        }
        .listRowBackground(theme.currentTheme.accent)
    }

    private var librarySection: some View {
        Section(header: Text("Browse Exercises by Category")) {
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
                                    Text((exercise.type?.rawValue.capitalized) ?? "Unknown").font(.caption2).foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Button { exerciseToDelete = exercise } label: {
                                    Image(systemName: "minus.circle").foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    },
                    label: {
                        HStack {
                            Text(category.name)
                        }
                        .contentShape(Rectangle())
                    }
                )
                .listRowBackground(theme.currentTheme.accent.opacity(0.5))
            }
        }
    }

    private var managementSection: some View {
        Section(header: Text("Create New Category").foregroundColor(.white.opacity(0.6))) {
            HStack {
                TextField("", text: $newCategoryName, prompt: Text("e.g. Kettlebells, Yoga...").foregroundColor(.white.opacity(0.6)))
                    .focused($isFocused, equals: true)
                
                Button(action: createNewCategory) {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(newCategoryName.isEmpty ? .gray : .white)
                        .font(.title3)
                }
                .disabled(newCategoryName.isEmpty)
            }
        }
        .listRowBackground(theme.currentTheme.accent)
    }
}

// MARK: - Helper Methods
extension AddExercise {
    private func createNewExercise() {
        // Find the category object using the ID
        guard let id = selectedCategoryID,
              let category = categories.first(where: { $0.id == id }),
              !searchText.isEmpty else { return }
              
        let newEx = Exercise(name: searchText, type: selectedType)
        newEx.userId = userId
        category.exercises.append(newEx)
        
        try? context.save()
        searchText = ""
        selectedCategoryID = nil // Reset using ID
        isFocused = nil
    }

    private func createNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        let newCat = ExerciseCategory(name: newCategoryName, exercises: [])
        newCat.userId = userId
        context.insert(newCat)
        
        // AUTO-SELECT the new category so the user can immediately add exercises to it
        selectedCategory = newCat
        
        newCategoryName = ""
        // isFocused = nil // Optional: hide keyboard after creating
    }

    private func deleteTargetExercise() {
        guard let exercise = exerciseToDelete else { return }
        if let category = categories.first(where: { $0.exercises.contains(where: { $0.id == exercise.id }) }) {
            if let index = category.exercises.firstIndex(where: { $0.id == exercise.id }) {
                category.exercises.remove(at: index)
                context.delete(exercise)
                try? context.save()
            }
        }
        exerciseToDelete = nil
    }
}
