//
//  NSUserDefaults+Save.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    class func save(object:AnyObject, forKey key:String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(object, forKey:key)
        userDefaults.synchronize()
    }
    
    class func retrieve(key:String) -> AnyObject? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(key)
    }
}
