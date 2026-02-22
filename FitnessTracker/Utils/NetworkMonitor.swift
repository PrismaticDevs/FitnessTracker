//
//  NetworkMonitor.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import Network
import Observation

@Observable
class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    var isConnected = true

    init() {
        monitor.pathUpdateHandler = { path in
            Task { @MainActor in
                // Only "connected" if we have cellular or wifi
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
