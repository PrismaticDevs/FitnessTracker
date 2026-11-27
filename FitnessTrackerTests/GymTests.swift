//
//  GymTests.swift
//  FitnessTrackerTests
//
//  Unit tests for home-gym selection (no MapKit network calls).
//

import Testing
import Foundation
import CoreLocation
import FirebaseFirestore
@testable import FitnessTracker

private func gym(_ id: String, _ name: String = "Gym", lat: Double, lon: Double) -> GymPlace {
    GymPlace(id: id, name: name, address: "", latitude: lat, longitude: lon)
}

@Suite("GymPlace")
struct GymPlaceTests {

    @Test("fallback ID slugs the name and rounds coordinates")
    func fallbackID() {
        let id = GymPlace.fallbackID(name: "Gold's Gym – Venice!", latitude: 33.994_123_9, longitude: -118.474_987_1)
        #expect(id == "gold-s-gym-venice@33.9941,-118.4750")
    }

    @Test("same gym found twice gets the same fallback ID")
    func fallbackIDStable() {
        let a = GymPlace.fallbackID(name: "Iron Temple", latitude: 40.712_80, longitude: -74.006_01)
        let b = GymPlace.fallbackID(name: "iron temple", latitude: 40.712_82, longitude: -74.006_03)
        #expect(a == b)
    }

    @Test("miles is nil without a location")
    func milesWithoutLocation() {
        #expect(gym("a", lat: 0, lon: 0).miles(from: nil) == nil)
    }

    @Test("miles converts meters to miles")
    func milesConversion() throws {
        // One degree of latitude is ~69 miles.
        let place = gym("a", lat: 1, lon: 0)
        let miles = try #require(place.miles(from: CLLocation(latitude: 0, longitude: 0)))
        #expect(abs(miles - 69.1) < 0.5)
    }

    @Test("distance text", arguments: [
        (nil as Double?, nil as String?),
        (0.05, "nearby"),
        (0.1, "0.1 mi"),
        (2.345, "2.3 mi")
    ])
    func distanceText(miles: Double?, expected: String?) {
        #expect(GymPlace.distanceText(miles: miles) == expected)
    }

    @Test("encodes only the fields the Firestore rules allow")
    func firestoreFields() throws {
        let place = GymPlace(id: "I123", name: "Iron Temple", address: "1 Main St", latitude: 40.7, longitude: -74.0)
        let fields = try Firestore.Encoder().encode(place)
        #expect(Set(fields.keys) == ["id", "name", "address", "latitude", "longitude"])
        let decoded = try Firestore.Decoder().decode(GymPlace.self, from: fields)
        #expect(decoded == place)
    }
}

@Suite("GymSearchService sorting")
struct GymSearchSortingTests {

    @Test("removes duplicate places")
    func dedupes() {
        let places = [gym("a", lat: 0, lon: 0), gym("b", lat: 0, lon: 0), gym("a", lat: 0, lon: 0)]
        #expect(GymSearchService.dedupedAndSorted(places, from: nil).map(\.id) == ["a", "b"])
    }

    @Test("keeps Apple Maps order without a location")
    func keepsOrderWithoutLocation() {
        let places = [gym("far", lat: 1, lon: 1), gym("near", lat: 0, lon: 0)]
        #expect(GymSearchService.dedupedAndSorted(places, from: nil).map(\.id) == ["far", "near"])
    }

    @Test("sorts nearest first when location is known")
    func sortsByDistance() {
        let places = [gym("far", lat: 0.2, lon: 0), gym("near", lat: 0.01, lon: 0), gym("mid", lat: 0.05, lon: 0)]
        let sorted = GymSearchService.dedupedAndSorted(places, from: CLLocation(latitude: 0, longitude: 0))
        #expect(sorted.map(\.id) == ["near", "mid", "far"])
    }
}

@Suite("GymChoice")
struct GymChoiceTests {

    @Test("a map place carries its name and place")
    func placeChoice() {
        let place = gym("a", "Iron Temple", lat: 0, lon: 0)
        let choice = GymChoice.place(place)
        #expect(choice.name == "Iron Temple")
        #expect(choice.place == place)
    }

    @Test("typed text has a name but no place")
    func manualChoice() {
        let choice = GymChoice.manual("Garage gym")
        #expect(choice.name == "Garage gym")
        #expect(choice.place == nil)
    }
}
