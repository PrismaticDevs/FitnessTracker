//
//  WorkoutPostCard.swift
//  FitnessTracker
//
//  One post in the FiT Social feed: author, caption and a summary of the workout.
//

import SwiftUI

struct WorkoutPostCard: View {
    let post: WorkoutPost
    var isMine = false
    var onDelete: (() -> Void)?

    @ObservedObject var theme = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
            }
            WorkoutSummaryView(workout: post.workout)
        }
        .padding()
        .background(theme.currentTheme.accent2.opacity(0.85))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.strokeSubtle, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            AvatarView(text: initials, size: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(post.authorDisplayName).font(.subheadline.bold())
                Text("@\(post.authorUsername) · \(timestamp)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            Spacer()
            if isMine, let onDelete {
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Post", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .contentShape(Rectangle())
                }
            }
        }
    }

    private var initials: String {
        let parts = post.authorDisplayName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? String(post.authorUsername.prefix(1)).uppercased() : letters.uppercased()
    }

    private var timestamp: String {
        guard let date = post.createdAt else { return "just now" }
        return date.formatted(.relative(presentation: .named))
    }
}

/// The workout part of a post. Also used as the preview when sharing.
struct WorkoutSummaryView: View {
    let workout: WorkoutSnapshot
    @ObservedObject var theme = ThemeManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.sessionName).font(.headline)
                Text("\(workout.programTitle) · \(workout.date.formatted(.dateTime.month().day()))")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            HStack(spacing: 8) {
                if !workout.strength.isEmpty {
                    statPill(icon: "dumbbell.fill", text: "\(workout.totalSets) sets")
                }
                if !workout.cardio.isEmpty {
                    statPill(icon: "figure.run", text: workout.totalMiles > 0
                             ? String(format: "%.1f mi", workout.totalMiles)
                             : "\(workout.totalCardioMinutes) min")
                }
                if !workout.mobility.isEmpty {
                    statPill(icon: "figure.flexibility", text: "\(workout.mobility.count) mobility")
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(workout.strength.enumerated()), id: \.offset) { _, item in
                    exerciseRow(item.exercise, detail: strengthDetail(item))
                }
                ForEach(Array(workout.cardio.enumerated()), id: \.offset) { _, item in
                    exerciseRow(item.exercise, detail: cardioDetail(item))
                }
                ForEach(Array(workout.mobility.enumerated()), id: \.offset) { _, item in
                    exerciseRow(item.exercise, detail: "\(item.rounds) rounds · \(item.holdSeconds)s hold")
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.currentTheme.accent.opacity(0.35))
        .cornerRadius(12)
    }

    private func statPill(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.fillSubtle)
            .clipShape(Capsule())
    }

    private func exerciseRow(_ name: String, detail: String) -> some View {
        HStack {
            Text(name).font(.subheadline)
            Spacer()
            Text(detail)
                .font(.caption.bold())
                .foregroundColor(.textSecondary)
        }
    }

    private func strengthDetail(_ item: WorkoutSnapshot.StrengthSummary) -> String {
        let weight = item.topWeight > 0 ? " · top \(item.topWeight) lb" : ""
        return "\(item.sets) sets · \(item.totalReps) reps\(weight)"
    }

    private func cardioDetail(_ item: WorkoutSnapshot.CardioSummary) -> String {
        let minutes = "\(item.durationSeconds / 60) min"
        if let miles = item.distanceMiles, miles > 0 {
            return String(format: "%.2f mi · ", miles) + minutes
        }
        return minutes
    }
}

struct AvatarView: View {
    let text: String
    var size: CGFloat = 40
    @ObservedObject var theme = ThemeManager.shared

    var body: some View {
        Text(text)
            .font(.system(size: size * 0.4, weight: .bold))
            .frame(width: size, height: size)
            .background(
                LinearGradient(colors: theme.currentTheme.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.strokeSubtle, lineWidth: 1))
    }
}
