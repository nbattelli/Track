//
//  MainViewController.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 22/3/17.
//  Copyright © 2017 NBattelli. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var actionButton : UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SQLiteManager.createDB()
        
        self.askAuthorization()
    }
    
    func askAuthorization() {
        
        let locationManager = LocationManager.sharedInstance
        var authorizationAlertMessage = ""
        
        switch locationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.askAuthorization()
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            authorizationAlertMessage = "La app solo tiene permisos para acceder al gps cuando esta en uso (AuthorizedAlways)"
            break
        case .denied:
            authorizationAlertMessage = "No tenes activado el servicio de gps"
        case .restricted:
            authorizationAlertMessage = "La app no tiene permisos para acceder al gps"
        }
        
        if authorizationAlertMessage.characters.count > 0 {
            self.showAlertMessage("Error en la autorización del uso del gps", message: authorizationAlertMessage)
        }
    }
    
    func showAlertMessage(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func actionButtonWasTapped() {
        let locationManager = LocationManager.sharedInstance
        if locationManager.isRunning == true {
            locationManager.stopGPS()
            self.actionButton.setTitle("Empezar", for: .normal)
        } else {
            locationManager.startGPS()
            self.actionButton.setTitle("Pausar", for: .normal)
        }
    }
}
