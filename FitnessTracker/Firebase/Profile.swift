//
//  EditProfile.swift
//  FitnessTracker
//
//  Created by Matt on 2/8/26.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var theme = ThemeManager.shared
    
    @State private var isEditing = false
    
    // Temporary state for textfields
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var feet: String = ""
    @State private var inches: String = ""
    @State private var gender: String = ""
    @State private var unitSystem: String = "Imperial"

    var body: some View {
        NavigationStack {
            List {
                Section("Personal Information") {
                    profileRow(label: "Name", value: $name, placeholder: "Enter Name", suffix: "")
                    profileRow(label: "Gender", value: $gender, placeholder: "e.g. Male, Female, Other", suffix: "")
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                
                Section("Units") {
                    Picker("Unit System", selection: $unitSystem) {
                        Text("Imperial (lbs/ft)").tag("Imperial")
                        Text("Metric (kg/cm)").tag("Metric")
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Biometrics") {
                    profileRow(label: "Age", value: $age, placeholder: "0", suffix: "yrs", keyboard: .numberPad)
                    
                    HStack {
                        Text("Height")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 110, alignment: .leading)
                        
                        HStack {
                            if isEditing {
                                if unitSystem == "Imperial" {
                                    HStack(spacing: 8) {
                                        // Feet Input
                                        HStack(spacing: 2) {
                                            TextField("5", text: $feet)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.trailing)
                                            Text("ft").font(.caption).foregroundColor(.gray)
                                        }
                                        .frame(width: 60)
                                        .padding(6)
                                        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                                        
                                        // Inches Input
                                        HStack(spacing: 2) {
                                            TextField("11", text: $inches)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.trailing)
                                            Text("in").font(.caption).foregroundColor(.gray)
                                        }
                                        .frame(width: 60)
                                        .padding(6)
                                        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                                    }
                                } else {
                                    // Metric cm Input
                                    HStack(spacing: 4) {
                                        TextField("170", text: $height)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                        Text("cm").foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(6)
                                    .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                                }
                            } else {
                                let total = auth.profile?.biometrics.height ?? 0
                                if unitSystem == "Imperial" {
                                    Text("\(total / 12) ft \(total % 12) in")
                                        .foregroundColor(.white)
                                } else {
                                    Text("\(total) cm")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    
                    profileRow(
                        label: "Weight",
                        value: $weight,
                        placeholder: "0",
                        suffix: unitSystem == "Metric" ? "kg" : "lbs",
                        keyboard: .decimalPad
                    )
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                .onTapGesture {
                    // This allows the user to dismiss the keyboard by tapping the row
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
            }
            .scrollContentBackground(.hidden)
            .applyGradientBackground()
            .tint(theme.currentTheme.accent)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveChanges()
                        } else {
                            // Inside the Toolbar (Edit button)
                            if let profile = auth.profile {
                                // ... other lines ...
                                let h = Double(profile.biometrics.height ?? 0)
                                loadHeightIntoFields(totalHeight: h)
                            }

                            // Inside .onAppear
                            let profileHeight = Double(auth.profile?.biometrics.height ?? 0)
                            loadHeightIntoFields(totalHeight: profileHeight)
                            // Safe unwrap of profile
                            if let profile = auth.profile {
                                name = profile.display_name
                                age = profile.biometrics.age != nil ? "\(profile.biometrics.age!)" : ""
                                weight = profile.biometrics.weight != nil ? "\(profile.biometrics.weight!)" : ""
                                gender = profile.biometrics.gender ?? ""
                                loadHeightIntoFields(totalHeight: Double(profile.biometrics.height ?? 0))
                            }
                            isEditing = true
                        }
                    }
                }
            }
            .onAppear {
                let profileHeight = Double(auth.profile?.biometrics.height ?? 0)
                name = auth.profile?.display_name ?? ""
                age = "\(auth.profile?.biometrics.age ?? 0)"
                weight = "\(auth.profile?.biometrics.weight ?? 0)"
                gender = auth.profile?.biometrics.gender ?? ""
                
                // This fills the feet/inches/height strings correctly
                loadHeightIntoFields(totalHeight: profileHeight)
            }
        }
    }

    // A helper function to toggle between Text and TextField
    @ViewBuilder
    func profileRow(label: String, value: Binding<String>, placeholder: String, suffix: String, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            if isEditing {
                HStack(spacing: 4) {
                    TextField(placeholder, text: value)
                        .keyboardType(keyboard)
                        .multilineTextAlignment(.trailing) // Keeps numbers next to the unit
                        .foregroundColor(.white)
                    
                    if !suffix.isEmpty {
                        Text(suffix)
                            .foregroundColor(.white.opacity(0.5)) // Faded unit label
                    }
                }
                .frame(maxWidth: 120) // Prevents the field from pushing the label off-screen
                .padding(6)
                .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            } else {
                // View Mode
                Text(value.wrappedValue == "0" || value.wrappedValue.isEmpty ? "Not Set" : "\(value.wrappedValue) \(suffix)")
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }

    func saveChanges() {
        // Compute height consistently based on selected unit system
        // We'll store as Double. If your backend expects centimeters, convert inches to cm.
        let finalHeight: Double = {
            if unitSystem == "Imperial" {
                // total inches as Double
                return Double(calculateTotalInches())
            } else {
                // metric centimeters from text field
                return Double(Int(height) ?? 0)
            }
        }()

        let finalWeight: Double = Double(weight) ?? 0.0

        Task {
            await auth.updateUserProfile(
                name: name,
                age: Int(age) ?? 0,
                weight: finalWeight,
                height: finalHeight,
                gender: gender.isEmpty ? "Unknown" : gender
            )
            isEditing = false
        }
    }

    private func calculateTotalInches() -> Int {
        let f = Int(feet) ?? 0
        let i = Int(inches) ?? 0
        return (f * 12) + i
    }

    private func loadHeightIntoFields(totalHeight: Double) {
        if unitSystem == "Imperial" {
            // Convert to Int just for the ft/in math
            let totalInches = Int(totalHeight)
            feet = totalInches > 0 ? "\(totalInches / 12)" : ""
            inches = totalInches > 0 ? "\(totalInches % 12)" : ""
        } else {
            // For Metric, convert the Double to a String
            // %.0f removes decimals (e.g., 170.0 becomes "170")
            height = totalHeight > 0 ? String(format: "%.0f", totalHeight) : ""
        }
    }
    
}

