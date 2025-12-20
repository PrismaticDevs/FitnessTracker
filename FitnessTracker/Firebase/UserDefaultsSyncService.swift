//  UserDefaultsSyncService.swift
//  FitnessTracker
//
//  Created by Assistant on 12/14/25.

import Foundation

/// Simple sync layer to read/write per-user UserDefaults values and provide a payload for cloud sync.
@MainActor
final class UserDefaultsSyncService: ObservableObject {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Read a value for a per-user key.
    func value<T>(for userId: String, key: String) -> T? {
        let k = namespacedKey(userId: userId, key: key)
        return defaults.object(forKey: k) as? T
    }

    /// Write a value for a per-user key.
    func set(_ value: Any?, for userId: String, key: String) {
        let k = namespacedKey(userId: userId, key: key)
        defaults.set(value, forKey: k)
    }

    /// Build a dictionary payload of selected keys to upload for a user.
    /// - Parameters:
    ///   - userId: The authenticated user id
    ///   - keys: The logical keys (without userId prefix) to include
    func payload(for userId: String, keys: [String]) -> [String: Any] {
        var dict: [String: Any] = [:]
        for key in keys {
            let k = namespacedKey(userId: userId, key: key)
            if let value = defaults.object(forKey: k) {
                dict[key] = value
            }
        }
        return dict
    }

    func namespacedKey(userId: String, key: String) -> String {
        "\(userId).\(key)"
    }
}
