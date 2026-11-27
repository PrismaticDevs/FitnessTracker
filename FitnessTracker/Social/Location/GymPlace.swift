//
//  GymPlace.swift
//  FitnessTracker
//
//  A gym chosen from Apple Maps (or typed by hand). Stored on the public profile
//  as `homeGymPlace`, so later features can group users who train at the same gym.
//  Only the gym's own public location is stored — never the user's location.
//

import Foundation
import CoreLocation
import MapKit

struct GymPlace: Codable, Equatable, Hashable, Identifiable {
    /// Apple Maps place ID when available; otherwise a stable key built from name + rounded coordinates.
    var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Fallback ID for places without an Apple Maps identifier. Coordinates are rounded to
    /// ~11 m so the same gym found twice produces the same key.
    static func fallbackID(name: String, latitude: Double, longitude: Double) -> String {
        let slug = name.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        return String(format: "%@@%.4f,%.4f", slug, latitude, longitude)
    }

    /// Distance from `location` in miles, or nil without a location.
    func miles(from location: CLLocation?) -> Double? {
        guard let location else { return nil }
        let meters = location.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        return meters / 1_609.344
    }

    static func distanceText(miles: Double?) -> String? {
        guard let miles else { return nil }
        return miles < 0.1 ? "nearby" : String(format: "%.1f mi", miles)
    }
}

extension GymPlace {
    init?(mapItem: MKMapItem) {
        let name = mapItem.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else { return nil }

        let coordinate: CLLocationCoordinate2D
        let address: String
        if #available(iOS 26.0, *) {
            coordinate = mapItem.location.coordinate
            address = mapItem.address?.shortAddress ?? mapItem.address?.fullAddress ?? ""
        } else {
            coordinate = mapItem.placemark.coordinate
            address = Self.legacyAddress(mapItem.placemark)
        }

        self.name = name
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.id = mapItem.identifier?.rawValue
            ?? Self.fallbackID(name: name, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    private static func legacyAddress(_ placemark: MKPlacemark) -> String {
        let street = [placemark.subThoroughfare, placemark.thoroughfare].compactMap { $0 }.joined(separator: " ")
        return [street, placemark.locality, placemark.administrativeArea]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
