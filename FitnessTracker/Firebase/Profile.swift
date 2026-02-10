//
//  EditProfile.swift
//  FitnessTracker
//
//  Created by Matt on 2/8/26.
//
import SwiftUI
import FirebaseAuth

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
    
    // Account
    @State private var showEmailChange = false
    @State private var showPasswordChange = false

    var body: some View {
        NavigationStack {
            List {
                Section("Personal Information") {
                    profileRow(label: "Name", value: $name, placeholder: "Enter Name", suffix: "")
                    profileRow(label: "Gender", value: $gender, placeholder: "e.g. Male, Female, Other", suffix: "")
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                
                Section {
                    // --- Change Email Button ---
                    Button(action: { showEmailChange = true }) {
                        HStack(spacing: 15) {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(theme.currentTheme.accent.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Email Address")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(auth.user?.email ?? "Not Set")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.vertical, 4)
                    }

                    // --- Change Password Button (Conditional) ---
                    // Only show if the user actually has a password provider (not just Google)
                    if let providerData = auth.user?.providerData,
                       providerData.contains(where: { $0.providerID == "password" }) {
                        
                        Button(action: { showPasswordChange = true }) {
                            HStack(spacing: 15) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Password")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("••••••••••••")
                                        .font(.body)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        // Shown for Google/Social users
                        HStack(spacing: 15) {
                            Image(systemName: " person.badge.shield.checkmark.fill")
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Text("Managed via Google")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Login & Security").foregroundColor(.gray)
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.5))
                
                Section {
                    Picker("Unit System", selection: Binding(
                        get: { unitSystem },
                        set: { newValue in
                            if unitSystem != newValue {
                                convertUnits(to: newValue)
                                unitSystem = newValue
                            }
                        }
                    )) {
                        Text("Imperial (lbs/ft)").tag("Imperial")
                        Text("Metric (kg/cm)").tag("Metric")
                    }
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.8))

                Section("Biometrics") {
                    profileRow(label: "Age", value: $age, placeholder: "0", suffix: "yrs", keyboard: .numberPad)
                    
                    HStack {
                        Text("Height")
                            .foregroundColor(.gray)
                            .frame(width: 100, alignment: .leading)
                        
                        if isEditing {
                            if unitSystem == "Imperial" {
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        TextField("5", text: $feet)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                        Text("ft").font(.caption).foregroundColor(.gray)
                                    }
                                    .frame(width: 60)
                                    .padding(6)
                                    .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                                    
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
                                HStack(spacing: 4) {
                                    TextField("170", text: $height)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                    Text("cm").foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: 120)
                                .padding(6)
                                .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                            }
                        } else {
                            // View Mode: Display based on current local state
                            if unitSystem == "Imperial" {
                                Text("\(feet) ft \(inches) in")
                                    .foregroundColor(.white)
                            } else {
                                Text("\(height) cm")
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                    }
                    
                    profileRow(
                        label: "Weight",
                        value: $weight,
                        placeholder: "0",
                        suffix: unitSystem == "Metric" ? "kg" : "lbs",
                        keyboard: .numberPad
                    )
                }
                .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                .onTapGesture {
                    // This allows the user to dismiss the keyboard by tapping the row
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
            }
            .sheet(isPresented: $showEmailChange) {
                UpdateEmailView()
                    .environmentObject(auth) // Pass the auth manager to the sheet
            }
            .sheet(isPresented: $showPasswordChange) {
                UpdatePasswordView() // We'll define this below
                    .environmentObject(auth)
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
                            // Populate text fields with current profile data before entering edit mode
                            if let profile = auth.profile {
                                name = profile.display_name
                                age = profile.biometrics.age != nil ? "\(profile.biometrics.age!)" : ""
                                weight = profile.biometrics.weight != nil ? "\(profile.biometrics.weight!)" : ""
                                gender = profile.biometrics.gender ?? ""
                                
                                let h = Double(profile.biometrics.height ?? 0)
                                loadHeightIntoFields(totalHeight: h)
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
    // MARK: - Update Email
    struct UpdateEmailView: View {
        @EnvironmentObject var auth: AuthManager
        @Environment(\.dismiss) var dismiss
        @ObservedObject var theme = ThemeManager.shared
        @State private var newEmail = ""
        @State private var errorMsg = ""
        @State private var emailSent = false // Track if we sent the link

        var body: some View {
            NavigationStack {
                Form {
                    if !emailSent {
                        Section("New Email Address") {
                            TextField("Email", text: $newEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                            
                            Text("Firebase will send a link to this address. Your account email won't change until you verify the new one.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                    } else {
                        Section {
                            Text("✅ Verification link sent! Please check \(newEmail) and click the link to finalize the change.")
                                .multilineTextAlignment(.center)
                                .padding(.vertical)
                        }
                        .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                    }
                    
                    if !errorMsg.isEmpty {
                        Text(errorMsg).foregroundColor(.red).font(.caption)
                    }
                }
                .scrollContentBackground(.hidden)
                .applyGradientBackground()
                .navigationTitle("Update Email")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        if !emailSent {
                            Button("Send Link") {
                                updateFlow()
                            }
                        } else {
                            Button("Done") { dismiss() }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }

        func updateFlow() {
            Task {
                do {
                    // Using the non-deprecated method from your AuthManager
                    try await auth.startEmailChange(to: newEmail)
                    emailSent = true
                } catch let error as NSError {
                    // FIX: Use AuthErrorCode.Code to avoid 'out of scope'
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        errorMsg = "Security timeout. Please log out and back in to change your email."
                    } else {
                        errorMsg = error.localizedDescription
                    }
                }
            }
        }
    }
    
    // MARK: - Update Password
    struct UpdatePasswordView: View {
        @EnvironmentObject var auth: AuthManager
        @Environment(\.dismiss) var dismiss
        @ObservedObject var theme = ThemeManager.shared
        @State private var newPassword = ""
        @State private var confirmPassword = ""
        @State private var errorMsg = ""
        @FocusState private var isInputActive: Bool

        var body: some View {
            NavigationStack {
                Form {
                    Section("Update Password") {
                        SecureField("New Password", text: $newPassword)
                            .focused($isInputActive, equals: true)
                        SecureField("Confirm New Password", text: $confirmPassword)
                            .focused($isInputActive, equals: true)
                    }
                    .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                    
                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Section {
                        Button(action: submitPassword) {
                            Text("Update Password")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding() // This creates the "height" of your button
                                .background(
                                    // Use a Gradient or Solid color that stands out
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(newPassword.isEmpty || newPassword != confirmPassword ?
                                              Color.gray.opacity(0.3) : theme.currentTheme.accent)
                                )
                        }
                        .buttonStyle(.plain) // 👈 This removes the "blue rectangle" overlay
                        .disabled(newPassword.isEmpty || newPassword != confirmPassword)
                        if !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword != confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(Color.clear) // 👈 This lets the button float on the gradient
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)) // Adds some breathing room
                }
                .scrollContentBackground(.hidden)
                .applyGradientBackground()
                .navigationTitle("Password")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }

        func submitPassword() {
            isInputActive = false
            guard newPassword == confirmPassword else {
                errorMsg = "Passwords do not match"
                return
            }

            Task {
                do {
                    try await auth.updatePassword(to: newPassword)
                    dismiss()
                } catch let error as NSError {
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        errorMsg = "Security timeout. Please log out and back in to change your password."
                    } else {
                        errorMsg = error.localizedDescription
                    }
                }
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
    
    func handlePasswordChange() {
        Task {
            do {
                try await auth.updatePassword(to: "NewPassword123!")
            } catch let error as NSError {
                // Updated to the correct enum path
                if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    print("Needs re-auth")
                    // Trigger your re-auth UI here
                }
            }
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
    
    private func convertUnits(to newSystem: String) {
        // --- Weight Conversion ---
        if let currentWeight = Double(weight) {
            if newSystem == "Metric" {
                // lbs to kg: lbs / 2.20462
                let kg = currentWeight / 2.20462
                weight = String(format: "%.0f", kg) // Rounded to whole number
            } else {
                // kg to lbs: kg * 2.20462
                let lbs = currentWeight * 2.20462
                weight = String(format: "%.0f", lbs) // Rounded to whole number
            }
        }

        // --- Height Conversion ---
        if newSystem == "Metric" {
            // Imperial (ft/in) to Metric (cm)
            let totalInches = (Double(feet) ?? 0) * 12 + (Double(inches) ?? 0)
            let cm = totalInches * 2.54
            height = String(format: "%.0f", cm)
        } else {
            // Metric (cm) to Imperial (ft/in)
            let totalCm = Double(height) ?? 0
            let totalInches = totalCm / 2.54
            let roundedInches = Int(round(totalInches))
            feet = "\(roundedInches / 12)"
            inches = "\(roundedInches % 12)"
        }
    }
    
}

