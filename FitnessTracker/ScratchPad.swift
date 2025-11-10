//
//  ScratchPad.swift
//  FitnessTracker
//
//  Created by Matt on 10/11/25.
//

//                        if defaults.bool(forKey: "iso\(exercise)") {
//                            VStack {
//
//                                HStack {
//                                    VStack {
//                                        Text("Left")
//                                            .padding(-4)
//                                            .font(.subheadline)
//                                        TextField("Left Weight", text: $leftInput, prompt: Text("Weight Left").foregroundColor(.white.opacity(0.5)))
//                                            .padding()
//                                            .background(combinedInput == "" && leftInput == "" && rightInput == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
//                                            .onChange(of: leftInput) { oldValue, newValue in
//                                                if let value = Int(newValue) {
//                                                    left = value
//                                                } else {
//                                                    left = 0
//                                                }
//                                                defaults.set(left, forKey: "left\(exercise)")
//                                            }
//                                            .onAppear {
//                                                leftInput = "\(defaults.integer(forKey: "left\(exercise)"))"
//                                            }
//                                    }
//                                    VStack {
//                                        Text("Right")
//                                            .padding(-4)
//                                            .font(.subheadline)
//                                        TextField("Right Weight", text: $rightInput, prompt: Text("Right Weight").foregroundColor(.white.opacity(0.5)))
//                                            .padding()
//                                            .background(combinedInput == "" && leftInput == "" && rightInput == "" ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
//                                            .onChange(of: rightInput) { oldValue, newValue in
//                                                if let value = Int(newValue) {
//                                                    right = value
//                                                } else {
//                                                    right = 0
//                                                }
//                                                defaults.set(right, forKey: "right\(exercise)")
//                                            }
//                                            .onAppear {
//                                                rightInput = "\(defaults.integer(forKey: "right\(exercise)"))"
//                                            }
//                                    }
//                                }
//                            }
//                        } else {
//                            VStack {
//                                Text("Combined").font(.subheadline)
//                                    .padding(-4)
//                                TextField("Combined", text: $combinedInput, prompt: Text("Combined Weight").foregroundColor(.white.opacity(0.5)))
//                                    .padding()
//                                    .background((combinedInput == "") && (leftInput == "" && rightInput == "") ? Color.red.opacity(0.6).cornerRadius(10) : Color.blue.opacity(0.8).cornerRadius(10))
//                                    .onChange(of: combinedInput) { oldValue, newValue in
//                                        if let value = Int(newValue) {
//                                            combinedInput = value
//                                        } else {
//                                            combinedInput = ""
//                                        }
//                                        defaults.set(combined, forKey: "combined\(exercise)")
//                                    }
//                                    .onAppear {
//                                        combinedInput = "\(defaults.integer(forKey: "combined\(exercise)"))"
//                                    }
//                            }
//                        }
//                    }
//
//                    HStack {
//                        VStack {
//                            Text("Reps")
//                                .padding(-4)
//                                .font(.subheadline)
//                            TextField("Reps", text: $reps, prompt: Text("Reps").foregroundColor(.white.opacity(0.5)))
//                                .padding() .background(Color.blue.opacity(0.8).cornerRadius(10))
//                                .onChange(of: reps) { oldValue, newValue in
//                                    reps = newValue
//                                    defaults.set(reps, forKey: "reps\(exercise)")
//                                }
//
//                        }
//                        VStack {
//                            Text("Rest")
//                                .padding(-4)
//                                .font(.subheadline)
//                            TextField("Rest (sec)", text: $rest, prompt: Text("Rest (sec)").foregroundColor(.white.opacity(0.5)))
//                                .padding()
//                                .background(Color.blue.opacity(0.8).cornerRadius(10))
//                                .onChange(of: rest) { oldValue, newValue in
//                                    rest = newValue
//                                    defaults.set(rest, forKey: "rest\(exercise)")
//                                }
//                        }
//                    }
