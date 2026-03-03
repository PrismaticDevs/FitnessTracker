//
//  ProgramReportView.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftUI
import SwiftData
import Charts

enum Timeframe: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct ProgramReportView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset: CGFloat = 0
    var program: WorkoutProgram
    
    @State private var selectedMetric: EntryType = .strength

    enum EntryType: String, CaseIterable {
        case strength = "Strength"
        case cardio = "Cardio"
        case mobility = "Mobility"
    }
    
    @Query private var allCompletedSessions: [CompletedSession]
    
    var filteredSessions: [CompletedSession] {
        allCompletedSessions
            .filter { $0.programTitle == program.title }
            .sorted { $0.date > $1.date }
    }
    
    @State private var selectedTimeframe: Timeframe = .weekly
    
    var startDate: Date {
        let days = (reportRange == .monthly) ? -30 : -7
        return Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }
    
    var displaySessions: [CompletedSession] {
        let filtered = filteredSessions.filter{ $0.date >= startDate }
        if filtered.isEmpty {
            // Create a 'Transient' session (not saved to SwiftData)
            let mockSession = CompletedSession(
                programTitle: program.title,
                sessionName: "No Data Recorded"
            )
            
            // Add one empty entry of each type so the loops run once with 0s
            mockSession.strengthEntries = [StrengthEntry(exercise: "None", date: .now, sets: [])]
            mockSession.cardioEntries = [CardioEntry(exercise: "None", duration: 0, distance: 0, calories: 0)]
            mockSession.mobilityEntries = [MobilityEntry(exercise: "None", holdTime: 0, rounds: 0)]
            
            return [mockSession]
        } else {
            return filtered
        }
    }
    
    @State private var reportRange: ReportRange = .weekly

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 120)
                ScrollView {
                    VStack(spacing: 20) {
                        Picker("Report Range", selection: $reportRange) {
                            Text("Weekly").tag(ReportRange.weekly)
                                .foregroundColor(.white)
                            Text("Monthly").tag(ReportRange.monthly)
                                .foregroundColor(.white)
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        // Top Level Stats
                        HStack(spacing: 15) {
                            StatCard(title: "Max Lift", value: "\(Int(calculateMaxLift())) lb", icon: "dumbbell.fill", color: .purple)
                            StatCard(title: "Cardio", value: formatTime(calculateTotalCalories()), icon: "figure.run", color: .blue)
                            StatCard(title: "Mobility", value: formatTime(calculateTotalMobility()), icon: "figure.flexibility", color: .blue)
                        }
                        .padding(.horizontal)
                        
                        // Main Chart Card
                        VStack(alignment: .leading) {
                            Text(reportRange == .weekly ? "Weekly Activity" : "Monthly Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding([.top, .leading])
                            
                            // Chart displaying sessions over time
                            VStack(alignment: .leading, spacing: 15) {
                                // 1. The Metric Picker
                                Picker("Metric", selection: $selectedMetric) {
                                    ForEach(EntryType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)

                                // 2. The Dynamic Chart
                                Chart {
                                    ForEach(displaySessions) { session in
                                        BarMark(
                                            x: .value("Day", session.date, unit: .day),
                                            y: .value("Value", getYValue(for: session))
                                        )
                                        .foregroundStyle(theme.currentTheme.accent2)
                                        .cornerRadius(6)
                                    }
                                }
                                // Axis Labels
                                .chartXAxisLabel(position: .bottom, alignment: .center) {
                                    Text(reportRange == .weekly ? "Past 7 Days" : "Past 30 Days")
                                        .font(.caption.bold())
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .chartYAxisLabel(position: .top, alignment: .leading) {
                                    Text(selectedMetric == .strength ? "Sets" : (selectedMetric == .cardio ? "Miles" : "Minutes"))
                                        .font(.caption.bold())
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .chartXAxis {
                                    if reportRange == .weekly {
                                        AxisMarks(values: .stride(by: .day)) { _ in
                                            AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                                                .foregroundStyle(.white)
                                        }
                                    } else {
                                        // Only show a label every 7 days for monthly so it's readable
                                        AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                            AxisValueLabel(format: .dateTime.month().day(), centered: true)
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                // Axis Values
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine().foregroundStyle(.white.opacity(0.1))
                                        AxisValueLabel {
                                            if let val = value.as(Double.self) {
                                                Text(formatYAxis(val))
                                                    .foregroundStyle(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { _ in
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .chartXScale(domain: Calendar.current.date(byAdding: .day, value: -6, to: .now)!...Date.now)
                                .frame(height: 180)
                                .padding([.horizontal, .bottom])
                            }
                            .background(theme.currentTheme.accent)
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        .background(theme.currentTheme.accent)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Replace your existing metric rows with this structure
                        VStack(spacing: 12) {
                            expandableSection(
                                label: "Strength",
                                value: "\(calculateTotalSets())",
                                icon: "dumbbell.fill",
                                content: aggregateStrength().map { ($0.key, "\($0.value)") }
                            )
                            
                            expandableSection(
                                label: "Cardio",
                                value: String(format: "%.2f mi", calculateTotalDistance()),
                                icon: "figure.run",
                                content: aggregateCardio().map { ($0.key, String(format: "%.2f mi", $0.value)) }
                            )
                            
                            expandableSection(
                                label: "Mobility",
                                value: formatTime(calculateTotalMobility()),
                                icon: "figure.flexibility",
                                content: aggregateMobility().map { ($0.key, "\($0.value) rounds") }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
                FloatingActionBar {
                    Spacer()
                    
                    // Custom Toolbar (If you have a global version, or just a placeholder)
                    Text("VEW SESSION DATA")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    // Management Link (Replacing Rename/Pencil)
                    NavigationLink(destination: SessionDataView(programTitle: program.title)) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .frame(height: 50)
                .background(theme.currentTheme.accent)
                .cornerRadius(30)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .offset(x: dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
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
        .brandedBackButton(title: "\(program.title) Report", theme: theme.currentTheme, dismiss: dismiss)
    }

    // MARK: - Expandable Section
    @ViewBuilder
    func expandableSection(label: String, value: String, icon: String, content: [(name: String, detail: String)]) -> some View {
        VStack {
            DisclosureGroup {
                VStack(spacing: 10) {
                    Divider().background(Color.white.opacity(0.3)) // Subtle separator
                    
                    if content.isEmpty {
                        Text("No data recorded")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 5)
                    } else {
                        ForEach(content, id: \.name) { item in
                            ExerciseSummaryRow(name: item.name, detail: item.detail)
                        }
                    }
                }
                .padding(.top, 5)
            } label: {
                MetricRow(label: label, value: value, icon: icon)
            }
            .accentColor(.white) // The arrow color
        }
        .padding() // Padding inside the colored box
        .background(theme.currentTheme.accent) // The unified background
        .cornerRadius(12)
    }
    
    // MARK: - DATA LOGIC
    func getYValue(for session: CompletedSession) -> Double {
        switch selectedMetric {
        case .strength:
            return Double(session.strengthEntries.reduce(0) { $0 + $1.sets.count })
        case .cardio:
            // Using Distance as the primary cardio metric
            return session.cardioEntries.reduce(0) { $0 + ($1.distance ?? 0) }
        case .mobility:
            // Using total minutes for mobility
            let totalSeconds = session.mobilityEntries.reduce(0) { $0 + $1.holdTime }
            return Double(totalSeconds) / 60.0
        }
    }

    func formatYAxis(_ value: Double) -> String {
        switch selectedMetric {
        case .strength: return "\(Int(value)) s"
        case .cardio: return String(format: "%.1f mi", value)
        case .mobility: return "\(Int(value)) m"
        }
    }
    
    func aggregateStrength() -> [String: Int] {
        var summary: [String: Int] = [:]
        for session in filteredSessions {
            for entry in session.strengthEntries {
                summary[entry.exercise, default: 0] += entry.sets.count
            }
        }
        return summary
    }

    func aggregateCardio() -> [String: Double] {
        var summary: [String: Double] = [:]
        for session in filteredSessions {
            for entry in session.cardioEntries {
                summary[entry.exercise, default: 0.0] += (entry.distance ?? 0.0)
            }
        }
        return summary
    }

    func aggregateMobility() -> [String: Int] {
        var summary: [String: Int] = [:]
        for session in filteredSessions {
            for entry in session.mobilityEntries {
                summary[entry.exercise, default: 0] += entry.rounds
            }
        }
        return summary
    }
    
    func calculateMaxLift() -> Double {
        var maxWeight: Double = 0
        
        for session in filteredSessions {
            for entry in session.strengthEntries {
                for set in entry.sets {
                    // Find the highest single value within this specific set record
                    // We compare the three columns: combined, left, and right
                    let highestValueInSet = [
                        Double(set.combined),
                        Double(set.left),
                        Double(set.right)
                    ].max() ?? 0
                    
                    // If this single value is higher than our global max, update it
                    if highestValueInSet > maxWeight {
                        maxWeight = highestValueInSet
                    }
                }
            }
        }
        return maxWeight
    }
    
    func calculateTotalStrengthVolume() -> Double {
        var totalVolume: Double = 0
        
        for session in filteredSessions {
            for entry in session.strengthEntries {
                for set in entry.sets {
                    // Sum the weight types: Combined (Barbell) + Left + Right
                    let totalWeightPerRep = Double(set.combined + set.left + set.right)
                    totalVolume += (totalWeightPerRep * Double(set.reps))
                }
            }
        }
        return totalVolume
    }

    func calculateTotalSets() -> Int {
        filteredSessions.reduce(0) { $0 + $1.strengthEntries.reduce(0) { $0 + $1.sets.count } }
    }

    func calculateTotalDistance() -> Double {
        filteredSessions.reduce(0.0) { $0 + $1.cardioEntries.reduce(0.0) { $0 + ($1.distance ?? 0.0) } }
    }

    func calculateTotalCalories() -> Int {
        filteredSessions.reduce(0) { $0 + $1.cardioEntries.reduce(0) { $0 + ($1.calories ?? 0) } }
    }

    func calculateTotalMobility() -> Int {
        var totalSeconds: Double = 0
        for session in filteredSessions {
            for entry in session.mobilityEntries {
                totalSeconds += (entry.holdTime * Double(entry.rounds))
            }
        }
        return Int(totalSeconds)
    }

    func calculateTotalRounds() -> Int {
        filteredSessions.reduce(0) { $0 + $1.mobilityEntries.reduce(0) { $0 + $1.rounds } }
    }

    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return "\(m)m \(s)s"
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Schema([WorkoutProgram.self, CompletedSession.self]), configurations: [config])

    let mockProgram: WorkoutProgram = {
        let p = WorkoutProgram(title: "Hypertrophy Phase 1", sessions: [])
        container.mainContext.insert(p)
        
        let calendar = Calendar.current
        let today = Date()
        
        // Let's create a mix of sessions over the last 10 days
        // Days ago: 0 (today), 2, 3, 6, 8
        let activeDays = [0, 2, 3, 6, 8]
        
        for daysAgo in activeDays {
            let sessionDate = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let completed = CompletedSession(
                date: sessionDate,
                userId: "123",
                programTitle: "Hypertrophy Phase 1",
                sessionName: "Session \(daysAgo)"
            )
            
            // Strength: Add a varying number of sets
            let setCounts = Int.random(in: 3...6)
            let sets = (1...setCounts).map { _ in
                SetRecord(id: UUID(), combined: 135, left: 0, right: 0, reps: 10, rest: 60)
            }
            completed.strengthEntries = [
                StrengthEntry(exercise: "Bench Press", date: sessionDate, sets: sets)
            ]
            
            // Cardio: Only on some days
            if daysAgo % 2 == 0 {
                completed.cardioEntries = [
                    CardioEntry(exercise: "Run", duration: 1200, distance: Double.random(in: 1.5...4.0), calories: 300)
                ]
            }
            
            // Mobility: On almost all days
            completed.mobilityEntries = [
                MobilityEntry(exercise: "Stretch", holdTime: 60, rounds: Int.random(in: 2...5))
            ]
            
            container.mainContext.insert(completed)
        }
        
        return p
    }()

    return NavigationStack {
        ProgramReportView(program: mockProgram)
            .modelContainer(container)
    }
}

