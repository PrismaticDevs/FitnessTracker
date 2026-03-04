//
//  ExerciseListSection.swift
//  FitnessTracker
//
//  Created by Matt on 2/23/26.
//
import SwiftUI
import SwiftData

struct ExerciseListSection: View {
    @Environment(\.modelContext) private var context
    var session: Session
    @Binding var completedExerciseIds: Set<UUID>
    var onDelete: (UUID) -> Void
    
    // Tabs for Unfinished and Completed Exercises
    @State private var selectedTab: WorkoutTab = .unfinished
    
    enum WorkoutTab: String, CaseIterable {
        case unfinished = "Unfinished"
        case completed = "Completed"
    }

    private var unfinishedExercises: [Exercise] {
        session.exercises
            .filter { !$0.isCompleted }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    private var completedExercises: [Exercise] {
        session.exercises
            .filter { $0.isCompleted }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    @State private var showDeleteConfirmation = false
    @State private var exerciseToInstance: Exercise?

    var body: some View {
        VStack(spacing: 0) {
            // --- TAB PICKER ---
            HStack(spacing: 0) {
                ForEach(WorkoutTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.snappy) { selectedTab = tab }
                    }) {
                        VStack(spacing: 8) {
                            Text("\(tab.rawValue) (\(tab == .unfinished ? unfinishedExercises.count : completedExercises.count))")
                                .font(.subheadline.bold())
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                            
                            // Animated Selection Indicator
                            Rectangle()
                                .fill(selectedTab == tab ? ThemeManager.shared.currentTheme.accent : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 10)
            .background(Color.black.opacity(0.2))

            // --- THE LIST ---
            ScrollViewReader { proxy in
                List {
                    if selectedTab == .unfinished {
                        if unfinishedExercises.isEmpty {
                            // --- COMPLETION CARD ---
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                VStack(spacing: 8) {
                                    Text("Session Complete!")
                                        .font(.title2.bold())
                                    Text("All exercises are marked finished.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: {
                                    // This triggers the same logic as the BottomControls save
                                    NotificationCenter.default.post(name: NSNotification.Name("TriggerSave"), object: nil)
                                }) {
                                    Text("Save to Workout History")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(ThemeManager.shared.currentTheme.accent)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, 40)
                            }
                            .padding(.vertical, 40)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                        } else {
                            ForEach(unfinishedExercises) { exercise in
                                createEntryRow(for: exercise)
                            }
                        }
                    } else {
                        ForEach(completedExercises) { exercise in
                            createEntryRow(for: exercise)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .confirmationDialog("Remove Exercise", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let id = exerciseToInstance?.id { onDelete(id) }
            }
            Button("Cancel", role: .cancel) { exerciseToInstance = nil }
        } message: {
            Text("Are you sure you want to remove \(exerciseToInstance?.name ?? "this exercise") from this session?")
        }
    }
    
    // MARK: Entry Row
    @ViewBuilder
    private func createStrengthEntryRow(for exercise: Exercise) -> some View {
        StrengthEntryView(
            isCompleted: Binding(
                get: { exercise.isCompleted },
                set: { newValue in
                    withAnimation(.spring()) {
                        exercise.isCompleted = newValue
                        // Trigger a save so it survives an app kill
                        try? context.save()
                    }
                }
            ),
            exercise: exercise,
            allExercises: session.exercises,
            deleteExercise: { _ in
                self.exerciseToInstance = exercise
                self.showDeleteConfirmation = true
            }
        )
        .id(exercise.id)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    @ViewBuilder
    private func createEntryRow(for exercise: Exercise) -> some View {
        let isCompletedBinding = Binding(
            get: { exercise.isCompleted },
            set: { newValue in
                withAnimation(.spring()) {
                    exercise.isCompleted = newValue
                    try? context.save()
                }
            }
        )

        switch exercise.type {
        case .cardio:
            CardioEntryView(
                isCompleted: isCompletedBinding,
                exercise: exercise.name,
                deleteExercise: { _ in triggerDelete(exercise) } // Removed the unused "_"
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .id(exercise.id)

        case .mobility:
            MobilityEntryView(
                isCompleted: isCompletedBinding,
                exercise: exercise,
                deleteExercise: { _ in triggerDelete(exercise) } // Keep if Mobility expects ID
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .id(exercise.id)

        default:
            StrengthEntryView(
                isCompleted: isCompletedBinding,
                exercise: exercise,
                allExercises: session.exercises,
                deleteExercise: { _ in triggerDelete(exercise) }
            )
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .id(exercise.id)
        }
    }
    
    private func triggerDelete(_ exercise: Exercise) {
        self.exerciseToInstance = exercise
        self.showDeleteConfirmation = true
    }
}
