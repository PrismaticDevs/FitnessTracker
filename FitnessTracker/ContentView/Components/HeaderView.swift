//
//  HeaderView.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("FitnessTracker")
                .font(.title)
            Text("1.0")
                .font(.system(size: 18))
            Image("white-outline")
                .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
                    .padding(0)
        }
    }
}
