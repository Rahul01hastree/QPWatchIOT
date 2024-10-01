//
//  DeviceTelemetryModel.swift
//  Watch Ios App Watch App
//
//  Created by Apps we love on 19/12/23.
//

import Foundation

struct DeviceTelemetry: Codable{
    let deviceID: UUID
    let longitude: Double
    let latitude: Double
    let batteryLevel: Float
    let speed: String
    let direction: String
    let timeandDate : String
}
