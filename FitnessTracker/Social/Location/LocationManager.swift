//
//  LocationManager.swift
//  FitnessTracker
//
//  One-shot "where am I" lookups for finding nearby gyms.
//  Only asks for When-In-Use permission, and the location is never saved or uploaded.
//

import Foundation
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorization: CLAuthorizationStatus
    @Published private(set) var location: CLLocation?
    @Published private(set) var isLocating = false
    @Published private(set) var errorMessage: String?

    private let manager = CLLocationManager()
    /// Set when the user asked for their location before granting permission,
    /// so we can fetch it as soon as permission arrives.
    private var wantsLocation = false

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var isAuthorized: Bool {
        authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    var isDenied: Bool {
        authorization == .denied || authorization == .restricted
    }

    /// Asks for permission if needed, then fetches the current location once.
    func requestLocation() {
        errorMessage = nil
        switch authorization {
        case .notDetermined:
            wantsLocation = true
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isLocating = true
            manager.requestLocation()
        default:
            errorMessage = "Location access is off. You can turn it on in Settings, or search and type a gym instead."
        }
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        authorization = status
        if wantsLocation, isAuthorized {
            wantsLocation = false
            requestLocation()
        } else if isDenied {
            wantsLocation = false
            isLocating = false
        }
    }

    private func handle(location newLocation: CLLocation?) {
        isLocating = false
        if let newLocation { location = newLocation }
    }

    private func handle(error: Error) {
        isLocating = false
        if (error as? CLError)?.code == .denied { return }
        errorMessage = "Couldn't get your location. Try again, or search for your gym by name."
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in self.handleAuthorizationChange(status) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latest = locations.last
        Task { @MainActor in self.handle(location: latest) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.handle(error: error) }
    }
}
