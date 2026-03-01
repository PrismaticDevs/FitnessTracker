//
//  ProgramReportView.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//
import SwiftUI
import SwiftData
import Charts // For the visual reports

struct ProgramReportView: View {
    @Environment(\.modelContext) var context
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    var program: WorkoutProgram
    
    // Query all sessions belonging to this specific program
    @Query private var allCompleted: [CompletedSession]
    
    // Filter sessions to only those matching this program's ID or Name
    var filteredHistory: [CompletedSession] {
        allCompleted.filter { $0.programTitle == program.title }
            .sorted { $0.date > $1.date }
    }
    
    @State private var reportRange: ReportRange = .weekly

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Range Picker
                Picker("Report Range", selection: $reportRange) {
                    Text("Weekly").tag(ReportRange.weekly)
                    Text("Monthly").tag(ReportRange.monthly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onAppear {
                    // Force the selected segment to your theme's accent color
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(theme.currentTheme.accent)
                    
                    // Force the text to be white for both states
                    let whiteAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
                    UISegmentedControl.appearance().setTitleTextAttributes(whiteAttributes, for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes(whiteAttributes, for: .normal)
                }

                // 1. High-Level Summary Cards
                HStack(spacing: 15) {
                    StatCard(title: "Sessions", value: "\(filteredHistory.count)", icon: "bolt.fill", color: .orange)
                    StatCard(title: "Mobility", value: formatTime(calculateTotalMobility()), icon: "figure.flexibility", color: .blue)
                }
                .padding(.horizontal)

                // 2. The Main Chart (Adaptive to Range)
                VStack(alignment: .leading) {
                    Text(reportRange == .weekly ? "Weekly Activity" : "Monthly Progress")
                        .font(.headline)
                        .padding(.leading)
                    
                    ChartSection(sessions: filteredHistory, range: reportRange)
                        .frame(height: 200)
                        .padding()
                }
                .background(Color(theme.currentTheme.accent))
                .cornerRadius(15)
                .padding(.horizontal)

                // 3. Detailed Metrics Breakdown
                VStack(spacing: 12) {
                    MetricRow(label: "Avg Cardio Heart Rate", value: "\(calculateAvgHR()) bpm", icon: "heart.fill")
                    MetricRow(label: "Total Distance", value: String(format: "%.2f mi", calculateTotalDistance()), icon: "figure.run")
                    MetricRow(label: "Total Mobility Rounds", value: "\(calculateTotalRounds())", icon: "repeat")
                }
                .padding()
            }
            .padding(.top, 130)
        }
        .brandedBackButton(title: "\(program.title) Report", theme: theme.currentTheme, dismiss: dismiss)
        .applyAppBranding()
//        .navigationTitle("\(program.title) Report")
        .background(Color(.systemGroupedBackground))
    }
}

extension ProgramReportView {
    enum ReportRange { case weekly, monthly }
    
    // 1. Total Weight (Volume) = Sum of (combined weight * reps)
        private func calculateTotalWeight() -> Int {
            filteredHistory.reduce(0) { total, session in
                // Flatten the nested structure: Session -> StrengthEntry -> SetRecord
                total + session.strengthEntries.reduce(0) { exerciseTotal, exercise in
                    exerciseTotal + exercise.sets.reduce(0) { setTotal, set in
                        // FIXED: Changed .weight to .combined to match your SetRecord model
                        setTotal + (set.combined * set.reps)
                    }
                }
            }
        }

        // 2. Total Sets = Count of all SetRecords
        private func calculateTotalSets() -> Int {
            filteredHistory.reduce(0) { total, session in
                total + session.strengthEntries.reduce(0) { $0 + $1.sets.count }
            }
        }

        // 3. Total Reps = Sum of all reps
        private func calculateTotalReps() -> Int {
            filteredHistory.reduce(0) { total, session in
                total + session.strengthEntries.reduce(0) { exerciseTotal, exercise in
                    exerciseTotal + exercise.sets.reduce(0) { $0 + $1.reps }
                }
            }
        }

    private func calculateTotalMobility() -> TimeInterval {
        filteredHistory.reduce(0) { total, session in
            total + session.mobilityEntries.reduce(0) { $0 + $1.holdTime }
        }
    }

    private func calculateTotalDistance() -> Double {
        filteredHistory.reduce(0) { total, session in
            total + session.cardioEntries.compactMap { $0.distance }.reduce(0, +)
        }
    }

    private func calculateTotalRounds() -> Int {
        filteredHistory.reduce(0) { total, session in
            total + session.mobilityEntries.reduce(0) { $0 + $1.rounds }
        }
    }

    private func calculateAvgHR() -> Int {
        let allHR = filteredHistory.flatMap { $0.cardioEntries.compactMap { $0.heartRate } }
        guard !allHR.isEmpty else { return 0 }
        return allHR.reduce(0, +) / allHR.count
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        return "\(mins)m"
    }
}

#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: WorkoutProgram.self,
            Session.self,
            CompletedSession.self,
            MobilityEntry.self,
            CardioEntry.self,
            configurations: config
        )
        
        let context = container.mainContext
        
        // 1. Create the Program Template
        let mockProgram = WorkoutProgram(userId: "test_user", title: "Hypertrophy Phase 1", sessions: [])
        context.insert(mockProgram)

        let calendar = Calendar.current
        for dayOffset in [-10, -7, -3, 0] {
            let sessionDate = calendar.date(byAdding: .day, value: dayOffset, to: .now)!
            
            // 2. FIXED: Added 'sessionName' to match your model's new initializer
            let completedRecord = CompletedSession(
                date: sessionDate,
                programTitle: mockProgram.title,
                sessionName: "General Session" // Added this to fix the error
            )
            
            // 3. Add mock data to the record
            completedRecord.mobilityEntries.append(MobilityEntry(exercise: "Pigeon Pose", holdTime: 90, rounds: 2))
            
            if dayOffset % 2 == 0 {
                completedRecord.cardioEntries.append(CardioEntry(exercise: "Stairmaster", duration: 900, distance: 0.5))
            }
            
            context.insert(completedRecord)
        }
        
        return container
    }()

    return NavigationStack {
        // Ensuring the program title here matches the programTitle in the CompletedSessions above
        ProgramReportView(program: WorkoutProgram(userId: "test_user", title: "Hypertrophy Phase 1", sessions: []))
            .modelContainer(container)
    }
}
