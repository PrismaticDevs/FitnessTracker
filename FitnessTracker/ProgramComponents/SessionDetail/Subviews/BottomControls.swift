//
//  BottomControls.swift
//  FitnessTracker
//
//  Created by Matt on 2/23/26.
//
import SwiftUI

struct BottomControls: View {
    var session: Session
    var theme: ThemeManager
    var isUploading: Bool
    var isOnline: Bool
    var hasSavedLocally: Bool
    var onRename: () -> Void
    var onAdd: (String) -> Void
    var onSave: () -> Void
    
    var completedCount: Int {
        session.exercises.filter { $0.isCompleted }.count
    }

    var body: some View {
        FloatingActionBar {
            Spacer()
            Button(action: onRename) {
                Image(systemName: "pencil").foregroundColor(.white)
            }
            Spacer()
            ExerciseToolbar(
                title: "",
                exerciseName: .constant(""),
                exercisesSelected: session.exercises.map { $0.name },
                onExerciseSelected: onAdd
            )
            Spacer()
            Button(action: onSave) {
                Image(systemName: isUploading ? "arrow.clockwise" : (hasSavedLocally ? "icloud.and.arrow.up" : "square.and.arrow.down"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(completedCount == 0 ? .white.opacity(0.3) : .white)
            }
            .disabled(completedCount == 0)
            .opacity((hasSavedLocally && !isOnline) ? 0.5 : 1.0)
            Spacer()
        }
        .frame(height: 50)
        .background(theme.currentTheme.accent)
        .cornerRadius(30)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}
