//
//  GeoJSON.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 22/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

/*
 {
 "type": "Feature",
 "geometry": {
 "type": "LineString",
 "coordinates": [
 [
 -58.38025599718094,
 -34.61385519888081
 ],
 [
 -58.38540583848953,
 -34.62501534313687
 ],
 [
 -58.36669474840164,
 -34.635467787833186
 ]
 ]
 },
 "properties": {}
 }
 
 */

struct GeoJSON {
    let type = "Feature"
}

struct GeoJSONGeometry {
    let type = "LineString"
    var coordinates:[String]
}


