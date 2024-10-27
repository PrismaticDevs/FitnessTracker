//
//  ProgramMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct ProgramMenu: View {
    @State var ShowAddProgram = false
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    var body: some View {
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("FitnessTracker")
                            .foregroundColor(.white)
                            .font(.title )
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(.white)
                            .font(.system(size: 36))
                        Text("0.1")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .padding(5)
                    .padding(.top, 10)
                    Text("Select a Program")
                        .font(.system(size: 24, weight: .bold))
                        .padding(0)
                    List {
                        NavigationLink("Hypertrophy Mass Building", destination: Hypertrophy())
                            .bold()
                            .listRowBackground(Color.blue)
                            .foregroundStyle(.white, .white)
                            .font(.system(size: 24))
                    }
                    .scrollContentBackground(.hidden)
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: { ShowAddProgram = true}) {
                        Label("Add Program", systemImage: "plus.circle.fill")
                    }
                }

            }
            .background(
                NavigationLink(destination: AddProgram(), isActive: $ShowAddProgram) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .accentColor(Color.white)
    }
}

#Preview {
    ProgramMenu()
}
