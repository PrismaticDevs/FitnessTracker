//
//  Charts.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//


import SwiftUI
import Charts
import SwiftData

// MARK: - Chart Components

struct ChartSection: View {
    // UPDATED: Now uses your new Grand Container model
    let sessions: [CompletedSession]
    let range: ReportRange

    var body: some View {
        Chart {
            ForEach(sessions) { session in
                BarMark(
                    x: .value("Date", session.date, unit: range == .weekly ? .day : .weekOfYear),
                    // We are counting occurrences of sessions
                    y: .value("Count", 1)
                )
                .foregroundStyle(LinearGradient(colors: [.purple, .blue], startPoint: .bottom, endPoint: .top))
                .cornerRadius(4)
            }
        }
        // Allows the chart to look clean by hiding the 0, 1, 2 axis
        .chartYAxis(.hidden)
        // Ensures the X-axis labels make sense for the chosen range
        .chartXAxis {
            if range == .weekly {
                AxisMarks(values: .stride(by: .day))
            } else {
                AxisMarks(values: .stride(by: .weekOfYear))
            }
        }
    }
}

// MARK: - UI Components

struct StatCard: View {
    @ObservedObject var theme = ThemeManager.shared
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(value)
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.8) // Prevents text clipping
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(theme.currentTheme.accent)
        .cornerRadius(12)
    }
}

struct MetricRow: View {
    @ObservedObject var theme = ThemeManager.shared
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            // Label bundles the icon and text
            Label {
                Text(label)
                    .foregroundColor(.white) // Forced White
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(.white) // Forced White
            }
            .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white) // Forced White
        }
        .padding()
        .cornerRadius(10)
    }
}

// MARK: - Enums

enum ReportRange: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
}
