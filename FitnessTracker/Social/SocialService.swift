//
//  SocialService.swift
//  FitnessTracker
//
//  Firestore access for FiT Social: public profiles, username claims and posts.
//
//  Collections:
//    profiles/{uid}         PublicProfile (readable by any signed-in user)
//    usernames/{username}   { uid } — makes usernames unique
//    posts/{postId}         WorkoutPost
//

import Foundation
import FirebaseFirestore

enum SocialError: LocalizedError {
    case notSignedIn
    case usernameTaken
    case invalidUsername(String)
    case noProfile
    case emptyWorkout

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Sign in to use FiT Social."
        case .usernameTaken: return "That username is already taken."
        case .invalidUsername(let message): return message
        case .noProfile: return "Set up your FiT Social profile first."
        case .emptyWorkout: return "This session has no exercises to share."
        }
    }
}

@MainActor
final class SocialService: ObservableObject {
    static let shared = SocialService()

    @Published private(set) var myProfile: PublicProfile?
    @Published private(set) var hasLoadedProfile = false
    @Published private(set) var feed: [WorkoutPost] = []
    @Published private(set) var isLoadingFeed = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var profiles: CollectionReference { db.collection("profiles") }
    private var usernames: CollectionReference { db.collection("usernames") }
    private var posts: CollectionReference { db.collection("posts") }

    private init() {}

    // MARK: - Profile

    func loadMyProfile(uid: String) async {
        do {
            let snapshot = try await profiles.document(uid).getDocument()
            myProfile = snapshot.exists ? try snapshot.data(as: PublicProfile.self) : nil
        } catch {
            errorMessage = "Couldn't load your profile: \(error.localizedDescription)"
        }
        hasLoadedProfile = true
    }

    /// Creates or updates the signed-in user's profile, claiming the username atomically.
    func saveProfile(uid: String, username rawUsername: String, displayName: String, bio: String, homeGym: String) async throws {
        let username = UsernameRules.normalize(rawUsername)
        if let message = UsernameRules.validationMessage(for: username) {
            throw SocialError.invalidUsername(message)
        }

        let previousUsername = myProfile?.username
        let profileRef = profiles.document(uid)
        let usernameRef = usernames.document(username)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        var fields: [String: Any] = [
            "username": username,
            "displayName": trimmedName.isEmpty ? username : trimmedName,
            "bio": String(bio.prefix(160)),
            "homeGym": homeGym.trimmingCharacters(in: .whitespacesAndNewlines),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if myProfile == nil {
            fields["createdAt"] = FieldValue.serverTimestamp()
            fields["followerCount"] = 0
            fields["followingCount"] = 0
            fields["postCount"] = 0
        }

        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let claim = try transaction.getDocument(usernameRef)
                    if claim.exists, (claim.data()?["uid"] as? String) != uid {
                        errorPointer?.pointee = SocialError.usernameTaken as NSError
                        return nil
                    }
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
                if let previousUsername, previousUsername != username {
                    transaction.deleteDocument(self.usernames.document(previousUsername))
                }
                transaction.setData(["uid": uid], forDocument: usernameRef)
                transaction.setData(fields, forDocument: profileRef, merge: true)
                return nil
            }
        } catch let error as NSError where error.domain == String(reflecting: SocialError.self) {
            throw SocialError.usernameTaken
        }

        await loadMyProfile(uid: uid)
    }

    // MARK: - Posts

    func shareWorkout(_ session: CompletedSession, caption: String, uid: String) async throws {
        guard let profile = myProfile else { throw SocialError.noProfile }
        let snapshot = WorkoutSnapshot(session: session)
        guard !snapshot.isEmpty else { throw SocialError.emptyWorkout }

        let post = WorkoutPost(
            authorId: uid,
            authorUsername: profile.username,
            authorDisplayName: profile.displayName,
            caption: String(caption.trimmingCharacters(in: .whitespacesAndNewlines).prefix(500)),
            workout: snapshot
        )

        let batch = db.batch()
        let postRef = posts.document()
        try batch.setData(from: post, forDocument: postRef)
        batch.updateData(["postCount": FieldValue.increment(Int64(1))], forDocument: profiles.document(uid))
        try await batch.commit()

        await loadMyProfile(uid: uid)
        await refreshFeed()
    }

    func deletePost(_ post: WorkoutPost, uid: String) async throws {
        guard let id = post.id, post.authorId == uid else { return }
        let batch = db.batch()
        batch.deleteDocument(posts.document(id))
        batch.updateData(["postCount": FieldValue.increment(Int64(-1))], forDocument: profiles.document(uid))
        try await batch.commit()
        feed.removeAll { $0.id == id }
        await loadMyProfile(uid: uid)
    }

    /// Latest posts from everyone. Becomes "people you follow" once follows exist.
    func refreshFeed(limit: Int = 50) async {
        isLoadingFeed = true
        defer { isLoadingFeed = false }
        do {
            let snapshot = try await posts
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .getDocuments()
            feed = snapshot.documents.compactMap { try? $0.data(as: WorkoutPost.self) }
        } catch {
            errorMessage = "Couldn't load the feed: \(error.localizedDescription)"
        }
    }

    func reset() {
        myProfile = nil
        hasLoadedProfile = false
        feed = []
    }
}
