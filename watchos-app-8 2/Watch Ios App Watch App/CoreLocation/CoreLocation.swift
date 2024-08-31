import Foundation
import WatchKit
import CoreLocation
import Combine
import CoreData
import CommonCrypto

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let persistentContainer = PersistentContainer.shared
    @Published var userLocation: CLLocation?
    @Published var userDirection: String?
    private var lastSentLocation: CLLocation?
    private var defaultUpdateFrequency: Double = 5
    private var clientDirection: String = "Unknown"
    var checkCall: Int = 0
    var isConnected: Bool = false
    
    @Published var updateFrequency: Double {
        didSet {
            UserDefaults.standard.set(updateFrequency, forKey: updateFrequencyUserDefaultsKey)
            updateLocationManagerWithFrequency()
        }
    }
    
    @Published var count = 0
    
    override init() {
        
        
        if let storedFrequency = UserDefaults.standard.value(forKey: updateFrequencyUserDefaultsKey) as? Double {
            updateFrequency = storedFrequency
        } else {
            updateFrequency = defaultUpdateFrequency
        }
        
      
        super.init()
            
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingHeading()
        updateLocationManagerWithFrequency()
        
        // Add observer for UserDefaults changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func userDefaultsDidChange() {
        if let storedFrequency = UserDefaults.standard.value(forKey: updateFrequencyUserDefaultsKey) as? Double {
            if storedFrequency != updateFrequency {
                updateFrequency = storedFrequency
            }
        }
    }
    
    func updateLocationManagerWithFrequency() {
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = updateFrequency
        print("StartUpdatingLocation")
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        checkCall += 1
        print("****latitude",newLocation.coordinate.latitude)
        print("****longitude",newLocation.coordinate.longitude)
        print("checkCall :\(checkCall)")
        
        print(ConnectivityManager.shared.isConnected)
        
        if ConnectivityManager.shared.isConnected {
            
            print("Internet connection is available >>>>>> * <<<<<< ")
            let selectedDeviceIndex = UserDefaults.standard.integer(forKey: "currentDeviceIndex")
            selectedDeviceIndex == 0 ? sendCurrentLocationToIOTHUB(from: newLocation) : CommonClass.sendDataToServer(newLocation)
            let userStoredLocations = CoredataManager.shared.fetchStoredLocations()
            //CoreDataHelper.shared.fetchStoredLocations()
            if userStoredLocations.isEmpty {
                print("No data found in local storage.")
            }else{
                print(userStoredLocations.count)
                for (index, userStoredLocation) in userStoredLocations.enumerated() {
                    print("Location \(index): \(String(describing: userStoredLocation.timeStamp))")
                }
            }

        }else {
            print("No internet connection")
            if CommonClass().getAvailableStorageSpace() > persistentContainer.minAllowedStorageSize {
                print("current size :- \(CommonClass().getAvailableStorageSpace())")
                CoredataManager.shared.saveUserIntoToLocally(location: newLocation)
            } else {
                CoredataManager.shared.clearCoreDataWhenFilled(limit: 100, newLocation: newLocation)
            }

        }
        
        
//        InternetChecker.shared.networkCall { [weak self] isConnected in
//            guard let self = self else { return }
//            
//            if isConnected {
//                print("Internet connection is available >>>>>> * <<<<<< ")
//                let selectedDeviceIndex = UserDefaults.standard.integer(forKey: "currentDeviceIndex")
//                selectedDeviceIndex == 0 ? sendCurrentLocationToIOTHUB(from: newLocation) : CommonClass.sendDataToServer(newLocation)
//                let userStoredLocations = CoreDataHelper.shared.fetchStoredLocations()
//                if userStoredLocations.isEmpty {
//                    print("No data found in local storage.")
//                }else{
//                    print(userStoredLocations.count)
//                    for (index, userStoredLocation) in userStoredLocations.enumerated() {
//                        print("Location \(index): \(String(describing: userStoredLocation.timeStamp))")
//                    }
//                }
//                
//            } else {
//                print("No internet connection")
//                if CommonClass().getAvailableStorageSpace() > persistentContainer.minAllowedStorageSize {
//                    print("current size :- \(CommonClass().getAvailableStorageSpace())")
//                    CoreDataHelper.shared.userInfoToLocal(location: newLocation)
//                } else {
//                    CoreDataHelper.shared.delete50UserInfoEntries(location: newLocation)
//                }
//            }
//            
//            DispatchQueue.main.sync {
//                self.userLocation = newLocation
//                
//            }
//            
//        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let magneticHeading = newHeading.magneticHeading
        let direction = getCardinalDirection(from: magneticHeading)
        userDirection = direction
        clientDirection = direction
        userDirections = userDirection!
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationFail")
    }
    
    
    func getCardinalDirection(from heading: CLLocationDirection) -> String {
        switch heading {
        case 0...22.5, 337.5...360:
            return "North"
        case 22.5...67.5:
            return "NorthEast"
        case 67.5...112.5:
            return "East"
        case 112.5...157.5:
            return "SouthEast"
        case 157.5...202.5:
            return "South"
        case 202.5...247.5:
            return "SouthWest"
        case 247.5...292.5:
            return "West"
        case 292.5...337.5:
            return "NorthWest"
        default:
            // Should never happen, but handle unexpected values gracefully
            return "Unknown"
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle authorization changes
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("Location authorization status: Authorized Always")
        case .authorizedWhenInUse:
            print("Location authorization status: Authorized When In Use")
            locationManager.requestAlwaysAuthorization()
            
        case .denied:
            print("Location authorization status: Denied")
            
        case .notDetermined:
            print("Location authorization status: Not Determined")
            
        case .restricted:
            print("Location authorization status: Restricted")
            
            
        @unknown default:
            print("Location authorization status: Unknown")
        }
    }
    
    
}

extension LocationManager {
    
    //MARK: - Azure IOT API CALL
    
    private func sendCurrentLocationToIOTHUB(from location : CLLocation ){
        
        var speed: Double
        var speedInMiles: String = ""
        if location.speed * 0.000621371 <= 0 {
            speed = 0.0000
            speedInMiles = String(format: "%.2f", speed)
        }
        else{
            speed = location.speed * 0.000621371
            speedInMiles = String(format: "%.2f", speed)
        }
        
        var userDirection =  userDirection ?? ""
        let data = DeviceTelemetry(deviceID: currDeviceID,
                                   longitude: location.coordinate.longitude,
                                   latitude: location.coordinate.latitude,
                                   batteryLevel: CommonClass.updateBatteryLevel(),
                                   speed:speedInMiles,
                                   direction: userDirection,
                                   timeandDate: ISO8601DateFormatter().string(from: Date())
        )
        IoTHubClient.shared.sendClientDataToIOT(userInfo: data ) { result in
            switch result {
            case .success(let success):
                print("Current sended to iot : \(success) ++++++++++ >>>> ***")
            case .failure(let failure):
                print(failure.localizedDescription)
            }
            
        }
    }
    
//    private func sendPastLocationToIOTHUB(from location : UserInfo, index : Int) {
//        
//        let requiredData = DeviceTelemetry(deviceID: currDeviceID,
//                                           longitude: location.longitude,
//                                           latitude:location.latitude,
//                                           batteryLevel: location.batteryLevel,
//                                           speed: location.speed ?? "",
//                                           direction: location.direction ?? "",
//                                           timeandDate: location.timeStamp ?? "")
//        
//        
//        IoTHubClient.shared.sendClientDataToIOT(userInfo: requiredData) { result in
//            switch result {
//            case .success(let success):
//                print("Past sended to iot : \(success) ++++++++++ >>>> *")
//                CoreDataHelper.shared.deletePerticularLocationFromCoreData(location: location, index: index)
//            case .failure(let failure):
//                print(failure.localizedDescription)
//            }
//        }
//        
//    }
    
}
