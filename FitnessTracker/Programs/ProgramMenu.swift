//
//  ProgramMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI

struct WeightEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    let date: String
    let weight: Int
    let left: Int
    let right: Int
    let note: String
}

struct ProgramMenu: View {
    @State var ShowAddProgram = false
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
    var body: some View {
        NavigationStack {
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
                        .foregroundColor(Color.white)
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
            .background(Image("AppIcon")
                .scaledToFit()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all))
            .toolbar {
                ToolbarItem {
                    Button(action: { ShowAddProgram = true}) {
                        Label("Add Program", systemImage: "plus.circle.fill")
                    }
                }

            }
            .navigationDestination(isPresented: $ShowAddProgram) {
                            AddProgram()
                        }
        }
        .accentColor(Color.white)
    }
}

#Preview {
    ProgramMenu()
}
