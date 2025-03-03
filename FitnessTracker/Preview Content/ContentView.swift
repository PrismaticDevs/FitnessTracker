//
//  ProgramMenu.swift
//  FitnessTracker
//
//  Created by Matt on 10/26/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Query(sort: \WorkoutProgram.title) var programs: [WorkoutProgram] = []
    @State var ShowAddProgram = false
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Text("FitnessTracker")
                            .font(.title )
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 36))
                        Text("0.1")
                            .font(.system(size: 18))
                    }
                    .padding(5)
                    .padding(.top, 10)
                    Text("Select a Program")
                        .font(.system(size: 24, weight: .bold))
                        .padding(0)
                        .foregroundColor(Color.white)
                    List {
                        ForEach(programs.sorted { $0.starred && !$1.starred }) { program in
                            NavigationLink(destination: SessionsView(program: program)) {
                                HStack {
                                    Text(program.title)
                                    if program.starred {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .listRowBackground(Color.blue)
                            .padding()
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding()
                }
            }
            .navigationTitle("Your Programs")
            .navigationBarTitleTextColor(.white)
            .applyGradientBackground()
            .overlay {
                if programs.isEmpty {
                    ContentUnavailableView(label: {
                        Label("No programs to list", systemImage: "list.bullet.rectangle.portrait")
                            .foregroundColor(.white)
                    }, description: {
                        Text("Start by creating a program")
                            .foregroundColor(.white)
                    },actions: {
                        NavigationLink(destination: AddWorkoutProgramView()) {
                            HStack {
                                   Image(systemName: "plus.circle.fill")
                                   Text("Add Program")
                                       .font(.headline)
                               }
                               .padding()
   
                               .cornerRadius(8)
                           }
                           .padding()
                    })
                }
            }
            .toolbar {
               if !programs.isEmpty {
                   ToolbarItem {
                       NavigationLink(destination: AddWorkoutProgramView()) {
                           HStack {
                                  Image(systemName: "plus.circle.fill")
                                   Text("Add Program")
                                      .font(.headline)
                              }
                              .padding()
                              .foregroundColor(.white)
                              .cornerRadius(8)
                          }
                          .padding()
                   }
                }

            }
        }
        .accentColor(Color.white)
    }
}

#Preview {
    ContentView()
}
