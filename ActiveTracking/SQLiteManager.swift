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
    static let timeStampRow = Expression<Date>("time_stamp")
    
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
    
    class func addCoordinate(_ location:CLLocation, deciredAccuracy:String, distanceFilter:Double) {
        
        do {
            let db = try Connection(dbPath())
            try db.run(locations.insert(
                latitudeRow <- location.coordinate.latitude,
                longitudeRow <- location.coordinate.longitude,
                speedRow <- location.speed,
                deciredAccuracyRow <- deciredAccuracy,
                distanceFilterRow <- distanceFilter,
                timeStampRow <- Date()))
        } catch {
            print("error insertando locations")
        }
    }
    
    class func clearAllRows() {
        do {
            let db = try Connection(dbPath())
            try db.run(locations.delete())
        } catch {
            print("no se pudo vaciar la tabla")
        }
    }
}

extension SQLiteManager {
    
    class func timeStampArgentina(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "GMT-3")
        return dateFormatter.string(from: date)
    }

    class func retrieveAllRowsAsDictionary() -> [String : [Any]]? {
        do {
            let db = try Connection(dbPath())
    
            var locationsArray : [Any] = []
            for location in try db.prepare(locations) {
                let locationDirectory = ["latitude":"\(location[latitudeRow])",
                                         "longitude":"\(location[longitudeRow])",
                                         "speed":"\(location[speedRow])",
                                         "deciredAccuracy":"\(location[deciredAccuracyRow])",
                                         "distanceFilter":"\(location[distanceFilterRow])",
                                         "timeStamp":timeStampArgentina(location[timeStampRow])]
                locationsArray.append(locationDirectory)
            }
            
            return ["locations":locationsArray]
            
        } catch {
            print("error obteniendo locations")
        }
        return nil
    }
    
    class func retrieveAllRowsForGoogleMaps() -> [[String : Double]]? {
        do {
            let db = try Connection(dbPath())
            
            var locationsArray : [[String : Double]] = []
            for location in try db.prepare(locations) {
                let locationDirectory = ["lat":location[latitudeRow],
                                         "lng":location[longitudeRow]]
                locationsArray.append(locationDirectory)
            }
            
            return locationsArray
            
        } catch {
            print("error obteniendo locations")
        }
        return nil
    }
    
    class func retrieveAllRowsForGeoJSON() -> [String : Any]? {
        do {
            let db = try Connection(dbPath())
            
            var locationsArray : [Any] = []
            for location in try db.prepare(locations) {
                let locationDirectory = [location[longitudeRow],location[latitudeRow]]
                locationsArray.append(locationDirectory)
            }
            
            
            
            return ["type":"Feature",
                    "geometry":["type":"LineString",
                                "coordinates":locationsArray]]
            
        } catch {
            print("error obteniendo locations")
        }
        return nil
    }
    
    class func retrieveAllRowsAsJSONString() -> String? {
        if let json = SQLiteManager.retrieveAllRowsAsDictionary() {
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options:[])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                return dataString as String
            } catch {
                print("JSON serialization failed:  \(error)")
                return nil
            }
        }
        return nil
    }
    
    class func retrieveAllRowsForGoogleMapsString() -> String? {
        if let json = SQLiteManager.retrieveAllRowsForGoogleMaps() {
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options:[])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                return dataString as String
            } catch {
                print("JSON serialization failed:  \(error)")
                return nil
            }
        }
        return nil
    }
    
    class func retrieveAllRowsForGeoJSONString() -> String? {
        if let json = SQLiteManager.retrieveAllRowsForGeoJSON() {
            do {
                let data = try JSONSerialization.data(withJSONObject: json, options:[])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                return dataString as String
            } catch {
                print("JSON serialization failed:  \(error)")
                return nil
            }
        }
        return nil
    }

}


