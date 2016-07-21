//
//  SQLiteManager.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import Foundation
import SQLite
import CoreLocation

class SQLiteManager {
   
    static let locations = Table("locations")
    static let idRow = Expression<Int64>("id")
    static let latitudeRow = Expression<Double>("latitude")
    static let longitudeRow = Expression<Double>("longitude")
    static let speedRow = Expression<Double>("speed")
    static let deciredAccuracyRow = Expression<String>("decired_accuracy")
    static let distanceFilterRow = Expression<Double>("distance_filter")
    static let timeStampRow = Expression<NSDate>("time_stamp")
    
    class func createDB() {
        do {
            let db = try Connection(dbPath())
            do {
                try db.run(locations.create(ifNotExists: true) { t in
                    t.column(idRow, primaryKey: true)
                    t.column(latitudeRow)
                    t.column(longitudeRow)
                    t.column(speedRow)
                    t.column(deciredAccuracyRow)
                    t.column(distanceFilterRow)
                    t.column(timeStampRow)
                    })
            } catch {
                print("error creando tabla coordinates")
            }
        } catch {
            print("Connection error")
        }
    }
    
    class func addCoordinate(location:CLLocation, deciredAccuracy:String, distanceFilter:Double) {
        
        do {
            let db = try Connection(dbPath())
            try db.run(locations.insert(
                latitudeRow <- location.coordinate.latitude,
                longitudeRow <- location.coordinate.longitude,
                speedRow <- location.speed,
                deciredAccuracyRow <- deciredAccuracy,
                distanceFilterRow <- distanceFilter,
                timeStampRow <- NSDate()))
        } catch {
            print("error insertando locations")
        }
    }
    
    class func retrieveAllRowsAsDictionary() -> [NSObject : NSObject]? {
        do {
            let db = try Connection(dbPath())
    
            var locationsArray : [AnyObject] = []
            for location in try db.prepare(locations) {
                let locationDirectory = ["latitude":"\(location[latitudeRow])",
                                         "longitude":"\(location[longitudeRow])",
                                         "speed":"\(location[speedRow])",
                                         "deciredAccuracy":"\(location[deciredAccuracyRow])",
                                         "distanceFilter":"\(location[distanceFilterRow])",
                                         "timeStamp":"\(location[timeStampRow])"]
                locationsArray.append(locationDirectory)
            }
            
            return ["locations":locationsArray]
            
        } catch {
            print("error obteniendo locations")
        }
        return nil
    }
    
    class func clearAllRows() {
        do {
            let db = try Connection(dbPath())
            try db.run(locations.delete())
        } catch {
           print("no se pudo vaciar la tabla")
        }
    }
    
    class func retrieveAllRowsAsJSONString() -> String? {
        if let json = SQLiteManager.retrieveAllRowsAsDictionary() {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(json, options:[])
                let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)!
                return dataString as String
            } catch {
                print("JSON serialization failed:  \(error)")
                return nil
            }
        }
        return nil
    }

}


