//
//  ExerciseSummaryRow.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/26.
//

import SwiftUI

struct ExerciseSummaryRow: View {
    let name: String
    let detail: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Text(detail)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 4)
    }
}

