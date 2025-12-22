import Foundation
import SwiftUI

/// A small helper that builds namespaced UserDefaults keys for the current user.
/// Pass this into views instead of raw `(String) -> String` closures to keep things consistent.
struct DefaultsKeyScope {
    /// The resolved user identifier used to namespace keys (e.g. preview ID, auth uid, or fallback).
    let userID: String

    /// Builds a fully-scoped key by prefixing with `user_<id>.`.
    func scoped(_ base: String) -> String {
        return "user_\(userID).\(base)"
    }
}

/// Convenience for accessing a scoped key builder from environment objects.
extension DefaultsKeyScope {
    /// Create a scope using information from an AuthManager-like object.
    /// - Parameters:
    ///   - previewUserID: A preview/testing user id if available.
    ///   - liveUserID: The authenticated user's id if available.
    /// - Returns: A DefaultsKeyScope that prefers preview id, then live id, then "guest".
    static func from(previewUserID: String?, liveUserID: String?) -> DefaultsKeyScope {
        let uid = previewUserID ?? liveUserID ?? "guest"
        return DefaultsKeyScope(userID: uid)
    }
}
