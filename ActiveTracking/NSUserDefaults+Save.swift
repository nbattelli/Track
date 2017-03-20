//
//  NSUserDefaults+Save.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import Foundation

extension UserDefaults {
    class func save(_ object:AnyObject, forKey key:String) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(object, forKey:key)
        userDefaults.synchronize()
    }
    
    class func retrieve(_ key:String) -> AnyObject? {
        let userDefaults = UserDefaults.standard
        return userDefaults.value(forKey: key) as AnyObject?
    }
}
