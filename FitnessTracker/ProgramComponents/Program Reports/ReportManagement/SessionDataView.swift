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
    @Environment(\.modelContext) private var context
    @ObservedObject var theme = ThemeManager.shared
    @State private var dragOffset: CGFloat = 0
    @Query(sort: \CompletedSession.date, order: .reverse) private var allSessions: [CompletedSession]
    
    // Standard access to UserDefaults
    let defaults = UserDefaults.standard

    @State private var showDeleteConfirm = false
    @State private var pendingSession: CompletedSession?
    @State private var pendingStrengthEntry: StrengthEntry?
    @State private var pendingCardioEntry: CardioEntry?
    @State private var pendingMobilityEntry: MobilityEntry?

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 100)
                
                List {
                    let filtered = allSessions.filter { $0.programTitle == programTitle }
                    
                    ForEach(filtered) { session in
                        Section {

                            // Session header row with swipe-to-delete for the whole completed session
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.sessionName)
                                        .font(.headline)
                                    HStack {
                                        Text(session.date.formatted(.dateTime.month().day().hour().minute()))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("Swipe to delete")
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.5))
                                    }
                                }
                                Spacer()
                            }
                            .listRowBackground(theme.currentTheme.accent2)
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    pendingSession = session
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete Session", systemImage: "trash")
                                }
                            }

                            // 1. STRENGTH SECTION
                            if !session.strengthEntries.isEmpty {
                                DisclosureGroup("Strength Raw Data") {
                                    ForEach(session.strengthEntries) { entry in
                                        VStack(alignment: .leading, spacing: 8) {
                                            // Header with Exercise Name and CURRENT Default Value
                                            HStack {
                                                Text(entry.exercise).font(.subheadline.bold()).foregroundColor(.orange)
                                                Spacer()
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
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                pendingStrengthEntry = entry
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
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
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                pendingCardioEntry = entry
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
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
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                pendingMobilityEntry = entry
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
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
        .confirmationDialog(
            "Are you sure you want to delete?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            if let s = pendingSession {
                Button("Delete Session", role: .destructive) {
                    withAnimation {
                        context.delete(s)
                        do { try context.save() } catch { print("[SessionDataView] Failed to delete session: \(error)") }
                        pendingSession = nil
                    }
                }
            }
            if let e = pendingStrengthEntry {
                Button("Delete Strength Entry", role: .destructive) {
                    withAnimation {
                        if let parent = e.session,
                           let idx = parent.strengthEntries.firstIndex(where: { $0.id == e.id }) {
                            parent.strengthEntries.remove(at: idx)
                        }
                        do { try context.save() } catch { print("[SessionDataView] Failed to delete strength entry: \(error)") }
                        pendingStrengthEntry = nil
                    }
                }
            }
            if let e = pendingCardioEntry {
                Button("Delete Cardio Entry", role: .destructive) {
                    withAnimation {
                        if let parent = e.session,
                           let idx = parent.cardioEntries.firstIndex(where: { $0.id == e.id }) {
                            parent.cardioEntries.remove(at: idx)
                        }
                        do { try context.save() } catch { print("[SessionDataView] Failed to delete cardio entry: \(error)") }
                        pendingCardioEntry = nil
                    }
                }
            }
            if let e = pendingMobilityEntry {
                Button("Delete Mobility Entry", role: .destructive) {
                    withAnimation {
                        if let parent = e.session,
                           let idx = parent.mobilityEntries.firstIndex(where: { $0.id == e.id }) {
                            parent.mobilityEntries.remove(at: idx)
                        }
                        do { try context.save() } catch { print("[SessionDataView] Failed to delete mobility entry: \(error)") }
                        pendingMobilityEntry = nil
                    }
                }
            }
            Button("Cancel") {
                pendingSession = nil
                pendingStrengthEntry = nil
                pendingCardioEntry = nil
                pendingMobilityEntry = nil
            }
            Button("Cancel", role: .cancel) {
                pendingSession = nil
                pendingStrengthEntry = nil
                pendingCardioEntry = nil
                pendingMobilityEntry = nil
            }
        }
    }
}

