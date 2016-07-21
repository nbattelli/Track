//
//  Constants.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import Foundation
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


func dbPath() -> String {
    let userPath = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true
        ).first!
    let dbName = "activeTracking.db"
    
    return "\(userPath)/\(dbName)"
}

func locationJSONFilePath() -> String {
    let userPath = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true
        ).first!
    let jsonFile = "locations.json"
    
    return "\(userPath)/\(jsonFile)"
}