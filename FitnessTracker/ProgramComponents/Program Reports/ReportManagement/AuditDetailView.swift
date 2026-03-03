//
//  Untitled.swift
//  FitnessTracker
//
//  Created by Matt on 3/3/26.
//

import SwiftUI

struct AuditDetailView: View {
    let session: CompletedSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            auditLine(label: "Strength Sets", value: session.strengthEntries.reduce(0) { $0 + $1.sets.count })
            auditLine(label: "Cardio Miles", value: session.cardioEntries.reduce(0.0) { $0 + ($1.distance ?? 0.0) })
            auditLine(label: "Mobility Rounds", value: session.mobilityEntries.reduce(0) { $0 + $1.rounds })
        }
        .applyAppBranding()
        .padding(.vertical, 5)
    }
    
    @ViewBuilder
    func auditLine(label: String, value: Any) -> some View {
        HStack {
            Text(label)
            Spacer()
            let displayValue = "\(value)"
            Text(displayValue == "0" || displayValue == "0.0" ? "EMPTY / 0" : displayValue)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(displayValue == "0" || displayValue == "0.0" ? .red : .primary)
        }
    }
}
