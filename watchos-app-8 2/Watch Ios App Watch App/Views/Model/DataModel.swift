//
//  DataModel.swift
//  QP HT Applicationn
//
//  Created by Rahul Gangwar on 6.08.2024.
//

struct DataModel: Codable {
    
    let hostName: [String: String]
    let ioTHubDevices: [IoTHubDeviceOption]
    let iotHubSASToken: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case hostName = "hostName"
        case ioTHubDevices = "ioTHubDevices"
        case iotHubSASToken = "iotHubSASToken"
    }
}

struct IoTHubDeviceOption: Codable {
    let option1: String
    let option2: String
    
    enum CodingKeys: String, CodingKey {
        case option1 = "option1"
        case option2 = "option2"
    }
}
