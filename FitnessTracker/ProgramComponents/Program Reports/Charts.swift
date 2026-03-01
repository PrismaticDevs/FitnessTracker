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
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
                .minimumScaleFactor(0.8) // Prevents text clipping
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Enums

enum ReportRange: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
}
