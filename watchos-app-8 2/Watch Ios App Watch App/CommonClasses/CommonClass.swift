
import SwiftUI
import CoreLocation

class CommonClass {
    
    class func getDeviceID ()-> UUID {

        guard let deviceIDExtract = WKInterfaceDevice.current().identifierForVendor?.uuidString else {
       //    print("******Error: Failed to retrieve device ID")
           return UUID() // Return a placeholder UUID in case of error
        }
        return UUID(uuidString: deviceIDExtract)!

    }
    
    class func sendSMS(to recipient: String, location: CLLocation ) {
                
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        let speedInMilesPerSec: Double
        if location.speed * 0.000621371 <= 0 {
            speedInMilesPerSec = 0
        }
        else{
            speedInMilesPerSec = location.speed * 0.000621371
        }
        
        
        let mapsURLString = "https://maps.google.com/maps?q=loc:\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)"
        

        let message = "SOS!,\nDevice ID: \(currDeviceID.uuidString),\nLocation: \(latitude) \(longitude),\nDirection: \(userDirections) ,\nSpeed: \(String(format: "%.2f", speedInMilesPerSec)) \(mapsURLString)"
        
//        print(recipient)
       
//        print(message)
        
        let encodedBody = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: "sms:\(recipient)?&body=\(encodedBody)")!
        
        WKExtension.shared().openSystemURL(url)
      
    }
    
    class func validatePhoneNumber(_ number: String) -> Bool {
        let phoneRegex = #"^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return predicate.evaluate(with: number)
    }
    
    class func updateBatteryLevel()-> Float{
        let device = WKInterfaceDevice.current()
        device.isBatteryMonitoringEnabled = true
        
        let batteryLevel = device.batteryLevel
        let batteryPercentage = batteryLevel * 100
        return batteryPercentage
    }
    
    class func sendDataToServer(_ location: CLLocation) {
        
        // Get network type
//        networkMonitor.checkNetworkType()
//        print("########", NetworkReachability.isNetworkAvailable())
//        print("speedInMilesPerSec: \(location.speed)")
        
        // Get battery level
        let deviceBatteryPercentage = abs(updateBatteryLevel())
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        // Get speed`
        let speed: Double
        let speedInMiles: String
        if location.speed * 0.000621371 <= 0 {
            speed = 0.0000
            speedInMiles = String(format: "%.2f", speed)
        }else{
            speed = location.speed * 0.000621371
            speedInMiles = String(format: "%.2f", speed)
        }
        
        let currentTime = CommonClass.getCurrrentDateTime()
        // Create DeviceTelemetry object
        let telemetryData = DeviceTelemetry(
            deviceID: currDeviceID,
            longitude: longitude,
            latitude: latitude,
            batteryLevel: deviceBatteryPercentage,
            speed: speedInMiles,
            direction: userDirections, timeandDate : currentTime
        )

        lastTelemetryData = telemetryData

       // print(lastTelemetryData!)
        guard let lastTelemetryData = lastTelemetryData else {
            print("Telemetry data not available")
            return
        }

        let fileName = createJSONFile(from: lastTelemetryData)
     //   print("filename",fileName)
        let azureStorageHelper = AzureStorageHelper()
        azureStorageHelper.createAndUploadFile(fileName: fileName)
    }
    
    class func createJSONFile(from telemetryData: DeviceTelemetry)->String {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        do {
            // Encode telemetryData to JSON data
            let jsonData = try jsonEncoder.encode(telemetryData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""

            // Create a unique filename using deviceID and timestamp
            let deviceIDString = telemetryData.deviceID.uuidString
           let timestampString = String(Int(Date().timeIntervalSince1970))
            
           // let currentTime = CommonClass.getCurrrentDateTime()
            
            let fileName = "\(deviceIDString)_\(timestampString).json"
         print("****FileName",fileName)
            // Save the JSON string to a file
          try jsonString.write(to: getDocumentsDirectory().appendingPathComponent(fileName), atomically: true, encoding: .utf8)

         //   print("JSON file created: \(fileName)")
            return fileName
        } catch {
         //   print("Error creating JSON file: \(error)")
        }
        return ""
    }
    
   class func getCurrrentDateTime() -> String
    {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"

        let myString = formatter.string(from: Date()) // string purpose I add here
    
        return myString
    }
    
    
    
    class func getDocumentsDirectory() -> URL {
        // Helper function to get the documents directory URL
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getAvailableStorageSpace() -> Int64 {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = attributes[.systemFreeSize] as? Int64 {
            return freeSize
        }
        return 0
    }
    func bytesToGigabytes(bytes: Int64) -> Double {
        return Double(bytes) / 1_073_741_824
    }
    
    
    func retrieveFromUserDefaults() -> [String: Any]? {
        if let data = UserDefaults.standard.data(forKey: "userINFO") {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return jsonObject
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        } else {
            print("No data found in UserDefaults for the key 'iotData'.")
        }
        return nil
    }
    
//     func dataParas(from jsonData: [String: Any]) -> DataModel? {
//        // Extract hostName
//        guard let hostNameDict = jsonData["hostName"] as? [String: String] else {
//            print("Failed to parse hostName")
//            return nil
//        }
//        
//        // Extract IoTHubDevices
//        guard let ioTHubDevicesDict = jsonData["IoTHubDevices"] as? [String: String] else {
//            print("Failed to parse IoTHubDevices")
//            return nil
//        }
//        
//        // Convert IoTHubDevices dictionary to an array of IoTHubDeviceOption
//        var ioTHubDevices: [IoTHubDeviceOption] = []
//        for (key, value) in ioTHubDevicesDict {
//            let deviceOption = IoTHubDeviceOption(option1: key, option2: value)
//            ioTHubDevices.append(deviceOption)
//        }
//        
//        // Extract iotHubSASToken
//        guard let iotHubSASTokenDict = jsonData["IotHubSASToken"] as? [String: String] else {
//            print("Failed to parse IotHubSASToken")
//            return nil
//        }
//        
//        // Construct DataModel
//        let dataModel = DataModel(
//            hostName: hostNameDict,
//            ioTHubDevices: ioTHubDevices,
//            iotHubSASToken: iotHubSASTokenDict
//        )
//        
//        return dataModel
//    }
    
}
