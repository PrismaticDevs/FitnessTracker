//
//  UserOwned.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/26.
//

import SwiftData
import Foundation
import FirebaseAuth

typealias FBAuth = FirebaseAuth.Auth

protocol UserOwned: PersistentModel {
    var userId: String { get set }
}
