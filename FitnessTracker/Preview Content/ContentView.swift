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
                        ForEach(programs) { program in
                            NavigationLink(destination: SessionsView(program: program)) {
                                Text(program.title)
                                    .bold()
                                    .font(.system(size: 24))
                                    .padding()
                                    .foregroundColor(.white) // Change text color to white for better contrast
                            }
                            .listRowBackground(Color.blue) // Set the background color for the entire row
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding()
                }
            }
            .navigationTitle("Programs")
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
