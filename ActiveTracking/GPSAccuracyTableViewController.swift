//
//  GPSAccuracyTableViewController.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/3/17.
//  Copyright © 2017 NBattelli. All rights reserved.
//

import UIKit
import CoreLocation

class GPSAccuracyTableViewController: UITableViewController {
    
    lazy var arrayKeys = Array(desiredAccuracyMapDictionary.keys)
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayKeys.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccuracyTableViewCellID", for: indexPath)
        let key = self.arrayKeys[indexPath.row]
        cell.textLabel?.text = desiredAccuracyMapDictionary[key]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let locationManager = LocationManager.sharedInstance
        let key = self.arrayKeys[indexPath.row]
        locationManager.desiredAccuracy = key
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
