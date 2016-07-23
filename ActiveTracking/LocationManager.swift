//
//  LocationManager.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 19/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    var minIntervalToLog : Double = 1 {
        didSet {
            NSUserDefaults.save(NSNumber(double:minIntervalToLog), forKey: "MinIntervalToLog")
        }
    }
    
    var minPrecisionToLog : Int = 60 {
        didSet {
            NSUserDefaults.save(NSNumber(integer:minPrecisionToLog), forKey: "MinPrecisionToLog")
        }
    }
    
    override init() {
        super.init()
        self.restoreUserPreferences()
        locationManager.delegate = self
        locationManager.desiredAccuracy = self.desiredAccuracy
        locationManager.distanceFilter = self.distanceFilter
        locationManager.pausesLocationUpdatesAutomatically = false
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

        //Restauro el intervalo minimo para loguear
        let storedMinIntervalToLog:NSNumber? = NSUserDefaults.retrieve("MinIntervalToLog") as? NSNumber
        if let storedMinIntervalToLog = storedMinIntervalToLog {
            self.minIntervalToLog = storedMinIntervalToLog.doubleValue
        }
        
        //Restauro la precisión minima que debe tener una geo para loguear
        let storedMinPrecisionToLog:NSNumber? = NSUserDefaults.retrieve("MinPrecisionToLog") as? NSNumber
        if let storedMinPrecisionToLog = storedMinPrecisionToLog {
            self.minPrecisionToLog = storedMinPrecisionToLog.integerValue
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
            print(location.horizontalAccuracy)
            
            let satisfyMinInterval = abs(howRecent) < self.minIntervalToLog
            let satisfyMinPrecision = location.horizontalAccuracy < Double(self.minPrecisionToLog)
            
            print("se trata de guardar how recent: \(abs(howRecent)), precision: \(location.horizontalAccuracy)")
            if satisfyMinInterval && satisfyMinPrecision
            {
                print("se guardó how recent: \(abs(howRecent)), precision: \(location.horizontalAccuracy)")
                SQLiteManager.addCoordinate(location, deciredAccuracy: self.desiredAccuracyString(), distanceFilter: self.distanceFilter)
            }
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











