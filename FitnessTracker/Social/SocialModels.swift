////
////  User.swift
////  FitnessTracker
////
////  Created by Matt on 12/3/25.
////
//
//import Foundation
//
//public struct User: Codable, Identifiable, Hashable {
//    public let id: String
//    public let firstName: String
//    public let lastName: String
//    public let age: Int
//    public let gender: String
//    public let height: Double
//    public let weight: Double
//    public let profilePicture: URL?
//}
//
//public struct Message: Identifiable, Hashable {
//    
//    public enum Status: Equatable {
//        case sending
//        case sent
//        case received
//        case read
//        case error
//    }
//    
//    public var id: String
//    public var user: User
//    public var Status: Status?
//    public var createdAt: Date
//    
//    public var text: String
//    public var attachments: [Attachment]
//}
