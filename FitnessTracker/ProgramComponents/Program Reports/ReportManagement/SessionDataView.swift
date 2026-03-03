//
//  ReportManagementView.swift
//  FitnessTracker
//
//  Created by Matt on 3/3/26.
//
import SwiftUI
import SwiftData

struct SessionDataView: View {
    let programTitle: String
    @Environment(\.dismiss) var dismiss
    @ObservedObject var theme = ThemeManager.shared
    @State private var dragOffset: CGFloat = 0
    @Query(sort: \CompletedSession.date, order: .reverse) private var allSessions: [CompletedSession]
    
    // Standard access to UserDefaults
    let defaults = UserDefaults.standard

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 100)
                
                List {
                    let filtered = allSessions.filter { $0.programTitle == programTitle }
                    
                    ForEach(filtered) { session in
                        Section(header: Text("\(session.sessionName) • \(session.date.formatted(.dateTime.month().day().hour().minute()))")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption.bold())) {
                            
                            // 1. STRENGTH SECTION
                            if !session.strengthEntries.isEmpty {
                                DisclosureGroup("Strength Raw Data") {
                                    ForEach(session.strengthEntries) { entry in
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Header with Exercise Name and CURRENT Default Value
                                            HStack {
                                                Text(entry.exercise).font(.subheadline.bold()).foregroundColor(.orange)
                                                Spacer()
                                                // Fetching current default for this exercise
                                                let currentDefault = defaults.double(forKey: "\(entry.exercise)_last_weight")
                                                Text("Current Default: \(currentDefault, specifier: "%.1f")")
                                                    .font(.caption2).padding(4).background(.white.opacity(0.1)).cornerRadius(4)
                                            }
                                            
                                            // Raw recorded set data
                                            ForEach(entry.sets.indices, id: \.self) { i in
                                                let set = entry.sets[i]
                                                Text("Set \(i+1) → C: \(set.combined) L: \(set.left) R: \(set.right) | Reps: \(set.reps)")
                                                    .font(.system(.caption2, design: .monospaced))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .listRowBackground(theme.currentTheme.accent)
                            }

                            // 2. CARDIO SECTION
                            if !session.cardioEntries.isEmpty {
                                DisclosureGroup("Cardio Raw Data") {
                                    ForEach(session.cardioEntries) { entry in
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text(entry.exercise).font(.subheadline.bold()).foregroundColor(.blue)
                                                Spacer()
                                                let defDist = defaults.double(forKey: "\(entry.exercise)_last_distance")
                                                Text("Default Dist: \(defDist, specifier: "%.1f")").font(.caption2)
                                            }
                                            Text("Recorded: \(entry.distance ?? 0, specifier: "%.2f") mi | \(entry.duration / 60)m | \(entry.calories ?? 0) kcal")
                                                .font(.system(.caption2, design: .monospaced))
                                        }
                                    }
                                }
                                .listRowBackground(theme.currentTheme.accent)
                            }

                            // 3. MOBILITY SECTION
                            if !session.mobilityEntries.isEmpty {
                                DisclosureGroup("Mobility Raw Data") {
                                    ForEach(session.mobilityEntries) { entry in
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text(entry.exercise).font(.subheadline.bold()).foregroundColor(.green)
                                                Spacer()
                                                let defHold = defaults.integer(forKey: "\(entry.exercise)_last_hold")
                                                Text("Default Hold: \(defHold)s").font(.caption2)
                                            }
                                            Text("Recorded: \(Int(entry.holdTime))s hold x \(entry.rounds) rounds")
                                                .font(.system(.caption2, design: .monospaced))
                                        }
                                    }
                                }
                                .listRowBackground(theme.currentTheme.accent)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .offset(x: dragOffset)
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    // Only respond to drags that start near the leading edge and move right
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
        }
        .applyAppBranding()
        .brandedBackButton(title: "Session Data", theme: theme.currentTheme, dismiss: dismiss)
        .toolbar(.hidden, for: .navigationBar)
    }
}
