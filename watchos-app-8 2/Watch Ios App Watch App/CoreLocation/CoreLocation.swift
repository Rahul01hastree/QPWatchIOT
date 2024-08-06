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
        print("Is Network Available \(NetworkReachability().isInternetAvailable())")
        NetworkMonitor().checkNetworkType()
        
      //  sendDataToIoTHub(from: newLocation, direction: "")

        let selectedDeviceIndex = UserDefaults.standard.integer(forKey: "currentDeviceIndex")
        selectedDeviceIndex == 0 ? sendDataToIoTHub(from: newLocation, direction: "") : CommonClass.sendDataToServer(newLocation)

        
        
        if NetworkReachability.isNetworkAvailable() {
           // CommonClass.sendDataToServer(newLocation)
            self.userLocation = newLocation
        }else{
            if performNetwork(){
               // CommonClass.sendDataToServer(newLocation)
                self.userLocation = newLocation
                
                self.fetchUserInfoFromCoreData()
               
            }else{
                print("Network Error.")
                
                if CommonClass().getAvailableStorageSpace() > persistentContainer.minAllowedStorageSize {
                    print("current size :- \(CommonClass().getAvailableStorageSpace())")
                    self.userInfoToLocal(location: newLocation)
                }else{
                    delete50UserInfoEntries(location: newLocation)
                }
                self.userLocation = newLocation
            }
 
        }
   
        
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
    
    //MARK: - check Internet
    
    private func performNetworkRequest()-> Bool {
        var request = URLRequest(url: URL(string: "https://www.google.com")!)
        request.httpMethod = "HEAD"
        var result: Bool = false
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                result = true
            } else {
                result = false
            }
        }
        task.resume()
        return result
    }
    
    private func performNetwork() -> Bool {
        
        guard let url = URL(string: "https://www.google.com") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
//        let dispatchGroup = DispatchGroup()
//        dispatchGroup.enter()
//        
//        var result: Bool = false
//        let task = URLSession.shared.dataTask(with: request) { _, response, error in
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                result = true
//            } else {
//                result = false
//            }
//            dispatchGroup.leave()
//        }
//        task.resume()
//        
//        dispatchGroup.wait() // Wait for the network request to complete
//        return result
        return true
    }
    
    //MARK: - Store In Core Data
    
    
    private func userInfoToLocal( location: CLLocation){
        
        var userId = CommonClass.getDeviceID().uuidString
        var deviceBatteryPercentage = abs(CommonClass.updateBatteryLevel())
        var latitude = location.coordinate.latitude
        var longitude = location.coordinate.longitude
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
        var currentTime = CommonClass.getCurrrentDateTime()
        
        self.saveLocationData(latitude: latitude, longitude: longitude, batteryLevel: deviceBatteryPercentage, deviceID: userId , speed: speedInMiles, direction: "", timeStamp: currentTime)
        
        
    }
    
    
    private func saveLocationData(latitude: Double, longitude: Double, batteryLevel: Float, deviceID: String, speed: String, direction: String, timeStamp: String) {
        
        let userInfo = UserInfo(context: persistentContainer.context)
        
        userInfo.timeStamp = timeStamp
        userInfo.batteryLevel = batteryLevel
        userInfo.deviceID = deviceID
        userInfo.direction = direction
        userInfo.latitude = latitude
        userInfo.longitude = longitude
        userInfo.speed = speed
        
        persistentContainer.saveContext()
    }
    
    //MARK: - Fetch from Core Data
    
    private func fetchUserInfoFromCoreData(){
        
        do {
            guard let result = try persistentContainer.context.fetch(UserInfo.fetchRequest()) as? [UserInfo] else { return }
            
            for userInfo in result {
                print("DeviceID: \(userInfo.deviceID ?? "No Name")")
                print("Time: \(userInfo.timeStamp ?? "No Email")")
                print("Long: \(userInfo.longitude)")
                print("Battery Level : \(userInfo.batteryLevel)")
                print("Speed : \(userInfo.speed ?? "")")
                print("Direction : \(userInfo.direction ?? "null")")
            }
            
        }catch (let err){
            debugPrint(err)
        }
    }
    
    
    //MARK: - Delete from Core Data
    
    private func delete50UserInfoEntries(location: CLLocation) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserInfo.fetchRequest()  // Use the fetch request defined
        fetchRequest.fetchLimit = 50  // Set the limit to 10 to fetch only 10 entries
        
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = persistentContainer.context
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as! [UserInfo]
            for object in fetchedObjects {
                context.delete(object)
            }
            try context.save()
            print("Deleted 10 UserInfo entries based on oldest timeStamp.")
            self.userInfoToLocal(location: location)
        } catch {
            let nserror = error as NSError
            print("Error while deleting UserInfo entries: \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    
    
    
    private func deleteAllEntries() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserInfo.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let context = PersistentContainer.shared.context
        context.perform {
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("Successfully deleted all entries.")
            } catch {
                print("Failed to delete entries: \(error)")
            }
        }
    }
    
    //}
    
    //MARK: - IOT API CALL
    func sendDataToIoTHub(from location : CLLocation, direction: String ){
        
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
        
        let data = DeviceTelemetry(deviceID: currDeviceID,
                                   longitude: location.coordinate.longitude,
                                   latitude: location.coordinate.latitude,
                                   batteryLevel: CommonClass.updateBatteryLevel(),
                                   speed:speedInMiles,
                                   direction: direction,
                                   timeandDate: ISO8601DateFormatter().string(from: Date())
        )
        
        IoTHubClient.shared.sendClientDataToIOT(userInfo: data ) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
            
        }
    }
    
}

