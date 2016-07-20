//
//  LocationManager.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 19/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import UIKit
import CoreLocation

let desiredAccuracyMapDictionary = [kCLLocationAccuracyBestForNavigation: "Mejor precisión para navegación",
                                kCLLocationAccuracyBest:"Mejor precisión",
                                kCLLocationAccuracyNearestTenMeters:"Precisión cercana a 10mts",
                                kCLLocationAccuracyHundredMeters:"Precisión cercana a 100mts",
                                kCLLocationAccuracyKilometer:"Precisión cercana a 1km",
                                kCLLocationAccuracyThreeKilometers:"Precisión cercana a 3kms"]

let authorizationStatusMapDictionary = [CLAuthorizationStatus.NotDetermined: "Sin definir",
                                        CLAuthorizationStatus.Restricted: "Restringido",
                                        CLAuthorizationStatus.Denied: "Denegado",
                                        CLAuthorizationStatus.AuthorizedWhenInUse: "Mientras se use",
                                        CLAuthorizationStatus.AuthorizedAlways: "Siempre"]

class LocationManager : NSObject  {
    
    var locationManager = CLLocationManager()
    
    var json : [NSObject : NSObject] = [:]
    
    private var distanceFilter : Double = 25 {
        didSet {
            NSUserDefaults.save(NSNumber(double:distanceFilter), forKey: "DistanceFilterKey")
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    private var desiredAccuracy : CLLocationAccuracy = kCLLocationAccuracyBest {
        didSet {
            NSUserDefaults.save(NSNumber(double:desiredAccuracy), forKey: "DesiredAccuracyKey")
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    override init() {
        super.init()
        self.restoreUserPreferences()
        locationManager.delegate = self
        locationManager.desiredAccuracy = self.desiredAccuracy
        locationManager.distanceFilter = self.distanceFilter
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = CLActivityType.Fitness
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func restoreUserPreferences() {
        //Restauro el filtor de distancia guardado
        let storedDistanceFilter:NSNumber? = NSUserDefaults.retrieve("DistanceFilterKey") as? NSNumber
        if let storedDistanceFilter = storedDistanceFilter {
            self.distanceFilter = storedDistanceFilter.doubleValue
        }
        
        //Restauro la precision deseada guardada
        let storedDesiredAccuracy:NSNumber? = NSUserDefaults.retrieve("DesiredAccuracyKey") as? NSNumber
        if let storedDesiredAccuracy = storedDesiredAccuracy {
            self.desiredAccuracy = storedDesiredAccuracy.doubleValue
        }
    }
    
    func startGPS() {
        locationManager.startUpdatingLocation()
    }

    func stopGPS() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func isAuthorized() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        
        let isEnable = CLLocationManager.locationServicesEnabled()
        let hasAuthorizedStatus = (status == .AuthorizedAlways &&
                                   status == .AuthorizedWhenInUse)
        
        return isEnable && hasAuthorizedStatus
    }
    
    
    func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func askAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func authorizationStatusString() -> String {
        return authorizationStatusMapDictionary[self.authorizationStatus()]!
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let eventDate = location.timestamp
            let howRecent = eventDate.timeIntervalSinceNow
            
            // Detecto cuanto tiempo paso desde el ultimo trackeo
            if abs(howRecent) < 1.0 {
                self.log(location)
            }
        }
    }
    
    func log(location:CLLocation) {
        
//        let fileString = "JSON.dat"
        
        let newPoint = ["latitude":"\(location.coordinate.latitude)",
                        "longitude":"\(location.coordinate.longitude)",
                        "timeStamp":"\(NSDate())",
                        "gpsDetectionMethod":"standard",
                        "deciredAccuracy":"\(self.desiredAccuracyString())",
                        "distanceFilter":"\(self.distanceFilterString())"]
        
        if self.json["coordinates"] == nil {
            self.json["coordinates"] = [newPoint]
        } else {
            var coordinates:[NSObject] = self.json["coordinates"] as! [NSObject]
            coordinates.append(newPoint)
            self.json["coordinates"] = coordinates
        }
        
        
        NSUserDefaults.save(self.json, forKey: "JSONRecord-20-07-2015-2")
    }
    
    func printJSON() {
        let newdata:[NSObject : NSObject] =  NSUserDefaults.retrieve("JSONRecord-20-07-2015-2") as! [NSObject : NSObject]
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(newdata, options:[])
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            print(dataString)
            
            // do other stuff on success
            
        } catch {
            print("JSON serialization failed:  \(error)")
        }
    }
    
}


//MARK: Distance Filter methods
extension LocationManager {
    func distanceFilterString() -> String {
        return "\(Int(self.distanceFilter))"
    }
    
    func updateDistanceFilter(distanceFilter : String) {
        self.distanceFilter = Double(distanceFilter)!
    }
}

//MARK: Desired Accuracy methods 
extension LocationManager {
    func desiredAccuracyString() -> String {
        return desiredAccuracyMapDictionary[self.desiredAccuracy]!
    }
    
    func desiredAccuracyStringArray() -> [String] {
        var array : [String] = []
        for key in desiredAccuracyMapDictionary.keys {
            array.append(desiredAccuracyMapDictionary[key]!)
        }
        return array
    }
    
    func updateDesiredAccuracy(desiredAccuracy:String) {
        for key in desiredAccuracyMapDictionary.keys {
            if desiredAccuracyMapDictionary[key] == desiredAccuracy {
                self.desiredAccuracy = key
            }
        }
    }
}











