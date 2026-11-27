//
//  PublicProfile.swift
//  FitnessTracker
//
//  Public-facing FiT Social profile. Stored at `profiles/{uid}`, separate from the
//  private `users/{uid}` document (which holds biometrics and preferences).
//

import Foundation
import FirebaseFirestore

struct PublicProfile: Codable, Identifiable, Equatable {
    @DocumentID var id: String?
    var username: String          // unique, lowercase, used as @handle
    var displayName: String
    var bio: String
    var homeGym: String
    /// Set when the gym was picked from Apple Maps; nil when typed by hand.
    var homeGymPlace: GymPlace? = nil
    var followerCount: Int = 0
    var followingCount: Int = 0
    var postCount: Int = 0
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?

    /// Initials for the avatar placeholder (no photo upload yet).
    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        let letters = parts.compactMap { $0.first }.map(String.init).joined()
        return letters.isEmpty ? String(username.prefix(1)).uppercased() : letters.uppercased()
    }
}

enum UsernameRules {
    static let minLength = 3
    static let maxLength = 20

    /// Lowercases and strips anything other than a–z, 0–9, `_` and `.`.
    static func normalize(_ raw: String) -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789_.")
        return String(raw.lowercased().filter { allowed.contains($0) })
    }

    static func validationMessage(for username: String) -> String? {
        if username.count < minLength { return "Username must be at least \(minLength) characters." }
        if username.count > maxLength { return "Username must be \(maxLength) characters or fewer." }
        if username != normalize(username) { return "Use only letters, numbers, _ and ." }
        return nil
    }
}
