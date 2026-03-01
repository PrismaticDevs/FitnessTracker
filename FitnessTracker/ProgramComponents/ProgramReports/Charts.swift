//
//  Charts.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//
import SwiftUI
import Charts

struct ChartSection: View {
    @ObservedObject var theme = ThemeManager.shared
    let sessions: [CompletedSession]
    let range: ProgramReportView.ReportRange

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(range == .weekly ? "WEEKLY ACTIVITY" : "MONTHLY PROGRESS")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
            
            Chart {
                ForEach(sessions) { session in
                    BarMark(
                        x: .value("Date", session.date, unit: range == .weekly ? .day : .weekOfYear),
                        y: .value("Count", 1)
                    )
                    // BRANDING: Use a gradient based on your accent color
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.currentTheme.accent2, theme.currentTheme.accent2.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .frame(height: 180) // Give the chart some breathing room
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: range == .weekly ? .day : .month)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(.white.opacity(0.05))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding()
        // BRANDING: Frosted glass background
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        // Subtle border to catch the light from your main background gradient
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct StatCard: View {
    @ObservedObject var theme = ThemeManager.shared

    let title: String
    let value: String
    let icon: String
    let color: Color // This will be your theme.currentTheme.accent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // BRANDING: Subtle background so it doesn't fight the main gradient
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct MetricRow: View {
    @ObservedObject var theme = ThemeManager.shared
    let label: String
    let value: String
    let icon: String
    var iconColor: Color = ThemeManager.shared.currentTheme.accent

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .bold()
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        // BRANDING: Semi-transparent background
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}
