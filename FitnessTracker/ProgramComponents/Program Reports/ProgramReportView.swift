//
//  ProgramReportView.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftUI
import SwiftData
import Charts

struct ProgramReportView: View {
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    var program: WorkoutProgram
    
    @Query private var allCompletedSessions: [CompletedSession]
    
    var filteredSessions: [CompletedSession] {
        allCompletedSessions
            .filter { $0.programTitle == program.title }
            .sorted { $0.date > $1.date }
    }
    
    @State private var reportRange: ReportRange = .weekly

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Picker("Report Range", selection: $reportRange) {
                    Text("Weekly").tag(ReportRange.weekly)
                    Text("Monthly").tag(ReportRange.monthly)
                }
                .pickerStyle(.segmented)
                .padding()

                HStack(spacing: 15) {
                    StatCard(title: "Sessions", value: "\(filteredSessions.count)", icon: "bolt.fill", color: .orange)
                    // This calls the function below
                    StatCard(title: "Mobility", value: formatTime(calculateTotalMobility()), icon: "figure.flexibility", color: .blue)
                }
                .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text(reportRange == .weekly ? "Weekly Activity" : "Monthly Progress")
                        .font(.headline)
                        .padding(.leading)
                    
                    ChartSection(sessions: filteredSessions, range: reportRange)
                        .frame(height: 200)
                        .padding()
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)

                VStack(spacing: 12) {
                    MetricRow(label: "Avg Cardio Heart Rate", value: "\(calculateAvgHR()) bpm", icon: "heart.fill")
                    MetricRow(label: "Total Distance", value: String(format: "%.2f mi", calculateTotalDistance()), icon: "figure.run")
                    MetricRow(label: "Total Mobility Rounds", value: "\(calculateTotalRounds())", icon: "repeat")
                }
                .padding()
            }
            .padding(.top, 130)
        }
        .applyAppBranding()
        .brandedBackButton(title: "\(program.title) Report", theme: theme.currentTheme, dismiss: dismiss)
//        .navigationTitle("\(program.title) Report")
        .background(Color(.systemGroupedBackground))
    }

    // --- MARK: - DATA LOGIC FUNCTIONS ---

        func calculateTotalMobility() -> Int {
            var totalSeconds: Double = 0
            for session in filteredSessions {
                for entry in session.mobilityEntries {
                    // Using your actual model: holdTime * rounds
                    totalSeconds += (entry.holdTime * Double(entry.rounds))
                }
            }
            return Int(totalSeconds)
        }

        func calculateTotalDistance() -> Double {
            var total: Double = 0.0
            for session in filteredSessions {
                for entry in session.cardioEntries {
                    // Since distance is Double?, we safely unwrap it with ?? 0
                    total += (entry.distance ?? 0.0)
                }
            }
            return total
        }

        func calculateAvgHR() -> Int {
            // NOTE: Your current CardioEntry model is missing 'averageHeartRate'.
            // If you want to track this, add 'var averageHeartRate: Int?' to CardioEntry.swift
            // For now, this returns 0 to stop the compiler error.
            return 0
        }

        func calculateTotalRounds() -> Int {
            var count = 0
            for session in filteredSessions {
                for entry in session.mobilityEntries {
                    count += entry.rounds
                }
            }
            return count
        }

        func formatTime(_ seconds: Int) -> String {
            let m = seconds / 60
            let s = seconds % 60
            return "\(m)m \(s)s"
        }
    
}
