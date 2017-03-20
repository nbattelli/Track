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

let authorizationStatusMapDictionary = [CLAuthorizationStatus.notDetermined: "Sin definir",
                                        CLAuthorizationStatus.restricted: "Restringido",
                                        CLAuthorizationStatus.denied: "Denegado",
                                        CLAuthorizationStatus.authorizedWhenInUse: "Mientras se use",
                                        CLAuthorizationStatus.authorizedAlways: "Siempre"]


func basePath() -> String {
    return NSSearchPathForDirectoriesInDomains(
        .documentDirectory, .userDomainMask, true
        ).first!
}

func dbPath() -> String {
    
    let dbName = "activeTracking.db"
    
    return "\(basePath())/\(dbName)"
}
