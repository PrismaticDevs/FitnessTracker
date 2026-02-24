import Foundation
import SwiftUI

/// A small helper that builds namespaced UserDefaults keys for the current user.
/// Pass this into views instead of raw `(String) -> String` closures to keep things consistent.
struct DefaultsKeyScope {
    /// The resolved user identifier used to namespace keys (e.g. preview ID, auth uid, or fallback).
    let userID: String
    let programId: String?
    let sessionId: String?

    /// Builds a fully-scoped key by prefixing with `user_<id>.`.
    func scoped(_ base: String) -> String {
        if let pid = programId, let sid = sessionId {
            return "user_\(userID).\(pid).\(sid).\(base)"
        } else {
            return "user_\(userID).\(base)"
        }
    }

    /// Builds a legacy key that only includes the user prefix and base (no program/session).
    /// Use this for migrating from the older key format.
    func legacyScoped(_ base: String) -> String {
        return "user_\(userID).\(base)"
    }
}

extension DefaultsKeyScope {
    /// Create a scope using information from an AuthManager-like object.
    /// - Parameters:
    ///   - previewUserID: A preview/testing user id if available.
    ///   - liveUserID: The authenticated user's id if available.
    ///   - programId: The ID of the current workout program.
    ///   - sessionId: The ID of the current workout session.
    /// - Returns: A DefaultsKeyScope that prefers preview id, then live id, then "guest".
    static func from(
        previewUserID: String?,
        liveUserID: String?,
        programId: String? = nil,
        sessionId: String? = nil
    ) -> DefaultsKeyScope {
        let uid = previewUserID ?? liveUserID ?? "guest"
        return DefaultsKeyScope(
            userID: uid,
            programId: programId,
            sessionId: sessionId
        )
    }
}

