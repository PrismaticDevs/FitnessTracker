//
//  ExerciseListSection.swift
//  FitnessTracker
//
//  Created by Matt on 2/23/26.
//
import SwiftUI

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
                                .foregroundColor(selectedTab == tab ? .white : .secondary)
                            
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
                        ForEach(unfinishedExercises) { exercise in
                            createStrengthEntryRow(for: exercise)
                        }
                    } else {
                        ForEach(completedExercises) { exercise in
                            createStrengthEntryRow(for: exercise)
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
}
