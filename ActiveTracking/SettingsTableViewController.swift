//
//  SettingsTableViewController.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 20/3/17.
//  Copyright © 2017 NBattelli. All rights reserved.
//

import UIKit

private let defaultDistanceValue : Double = 30

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var accuracyValueLabel : UILabel!
    @IBOutlet weak var distanceValueTextField : UITextField!
    
    @IBOutlet weak var minIntervalToLogTextField : UITextField!
    @IBOutlet weak var minPrecisionToLogTextField : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Configuración"
        
        self.distanceValueTextField.delegate = self
        self.distanceValueTextField.keyboardType = .numberPad
        self.distanceValueTextField.inputAccessoryView = self.toolBar()
        self.distanceValueTextField.delegate = self
        
        self.minIntervalToLogTextField.delegate = self
        self.minIntervalToLogTextField.keyboardType = .numberPad
        self.minIntervalToLogTextField.inputAccessoryView = self.toolBar()
        self.minIntervalToLogTextField.delegate = self
        
        self.minPrecisionToLogTextField.delegate = self
        self.minPrecisionToLogTextField.keyboardType = .numberPad
        self.minPrecisionToLogTextField.inputAccessoryView = self.toolBar()
        self.minPrecisionToLogTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.reloadValues()
    }
    
    func reloadValues() {
        let locationManager = LocationManager.sharedInstance
        self.accuracyValueLabel.text = locationManager.desiredAccuracyString()
        self.distanceValueTextField.text = locationManager.distanceFilterString()
        self.minIntervalToLogTextField.text = locationManager.minIntervalToLogString()
        self.minPrecisionToLogTextField.text = locationManager.minPrecisionToLogString()
    }
    
    
    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let okButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.doneKeyboard))
        
        toolBar.setItems([spaceButton, okButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    func doneKeyboard() {
        self.view.endEditing(true)
    }
    
}

extension SettingsTableViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let locationManager = LocationManager.sharedInstance
        
        if let text = textField.text, text.characters.count > 0, Int(text)! > 0 {
            if textField == self.distanceValueTextField {
                locationManager.distanceFilter = Double(text)!
            } else if textField == self.minIntervalToLogTextField {
                locationManager.minIntervalToLog = Double(text)!
            } else if textField == self.minPrecisionToLogTextField {
                locationManager.minPrecisionToLog = Double(text)!
            }
        } else {
            self.reloadValues()
        }
    }
}
