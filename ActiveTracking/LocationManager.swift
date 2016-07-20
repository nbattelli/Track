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
    
    private var distanceFilter : Double = 20.0 {
        didSet {
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    private var desiredAccuracy : CLLocationAccuracy = kCLLocationAccuracyBest {
        didSet {
            locationManager.desiredAccuracy = desiredAccuracy
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = self.desiredAccuracy
        locationManager.distanceFilter = self.distanceFilter
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
    
    func distanceFilterString() -> String {
        return "\(Int(self.distanceFilter))"
    }
    
    func updateDistanceFilter(distanceFilter : String) {
        self.distanceFilter = Double(distanceFilter)!
    }

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

extension LocationManager : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let eventDate = location.timestamp
            let howRecent = eventDate.timeIntervalSinceNow
            
            // Detecto cuanto tiempo paso desde el ultimo trackeo
            if abs(howRecent) < 5.0 {
                let trackInformation = "latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude), timeStamp: \(eventDate)"
                print(trackInformation)
            }
        }
    }
    
}











