//
//  SetDetailInputsView.swift
//  FitnessTracker
//
//  Created by Matt on 2/19/26.
//

import SwiftUI

struct SetDetailInputsView: View {
    let exercise: String
    @Binding var selectedSetIndex: Int
    @Binding var iso: Bool
    @Binding var leftInputs: [String]
    @Binding var rightInputs: [String]
    @Binding var combinedInputs: [String]
    @Binding var repsInputs: [String]
    @Binding var restInputs: [String]
    var keyScope: DefaultsKeyScope
    var defaults = UserDefaults.standard
    var isFocused: FocusState<Bool?>.Binding
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 10) {
                    if iso {
                        HStack {
                            SetRow(
                                text: Binding(get: { leftInputs[selectedSetIndex] }, set: { leftInputs[selectedSetIndex] = $0 }),
                                title: "Left Weight",
                                keyScope: keyScope,
                                baseKey: "left\(exercise)_set\(selectedSetIndex)"
                            )
                            .focused(isFocused, equals: true)
                            SetRow(
                                text: Binding(get: { rightInputs[selectedSetIndex] }, set: { rightInputs[selectedSetIndex] = $0 }),
                                title: "Right Weight",
                                keyScope: keyScope,
                                baseKey: "right\(exercise)_set\(selectedSetIndex)"
                            )
                            .focused(isFocused, equals: true)
                        }
                    } else {
                        SetRow(
                               text: Binding(get: { combinedInputs[selectedSetIndex] }, set: { combinedInputs[selectedSetIndex] = $0 }),
                               title: "Combined Weight",
                               keyScope: keyScope,
                               baseKey: "weight\(exercise)_set\(selectedSetIndex)"
                        )
                        .focused(isFocused, equals: true)
                    }
                }
                Button {
                    iso.toggle()
                    defaults.set(iso, forKey: keyScope.scoped("iso\(exercise)"))
                    print(iso)
                } label: {
                    Image(systemName: iso ? "arrow.right.and.line.vertical.and.arrow.left" : "arrow.left.and.line.vertical.and.arrow.right")
                }
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
            }
            HStack {
                SetRow(
                       text: Binding(get: { repsInputs[selectedSetIndex] }, set: { repsInputs[selectedSetIndex] = $0 }),
                       title: "Reps",
                       keyScope: keyScope,
                       baseKey: "reps\(exercise)_set\(selectedSetIndex)"
                )
                .focused(isFocused, equals: true)
                SetRow(
                       text: Binding(get: { restInputs[selectedSetIndex] }, set: { restInputs[selectedSetIndex] = $0 }),
                       title: "Rest",
                       keyScope: keyScope,
                       baseKey: "rest\(exercise)_set\(selectedSetIndex)"
                )
                .focused(isFocused, equals: true)
            }
        }
        .onAppear {
            iso = defaults.bool(forKey: keyScope.scoped("iso\(exercise)"))
        }
    }
}
