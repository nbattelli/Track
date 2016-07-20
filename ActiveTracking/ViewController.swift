//
//  ViewController.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 19/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet var gpsStatusLabel : UILabel!
    @IBOutlet var gpsDistancesFilterTextField : UITextField!
    @IBOutlet var gpsDesiredAccuracyTextField : UITextField!

    var locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.askAuthorization()
        self.locationManager.startGPS()
    }
    
    func setupView () {
        // Label estado de gps
        self.gpsStatusLabel.text = self.locationManager.authorizationStatusString()
        
        // TextField Filtro de distancia
        self.gpsDistancesFilterTextField.delegate = self
        self.gpsDistancesFilterTextField.keyboardType = .NumberPad
        self.gpsDistancesFilterTextField.inputAccessoryView = self.toolBar()
        self.gpsDistancesFilterTextField.text = self.locationManager.distanceFilterString()
        
        
        // TextField Precisión deseada
        self.gpsDesiredAccuracyTextField.delegate = self
        self.gpsDesiredAccuracyTextField.text = self.locationManager.desiredAccuracyString()
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        picker.backgroundColor = .whiteColor()
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        self.gpsDesiredAccuracyTextField.inputView = picker
        self.gpsDesiredAccuracyTextField.inputAccessoryView = self.toolBar()
        
    }
    
    func toolBar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let okButton = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.doneKeyboard))
        
        toolBar.setItems([spaceButton, okButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        return toolBar
    }
    
    func doneKeyboard() {
        self.view.endEditing(true)
    }
    
    func askAuthorization() {
        
        var authorizationAlertMessage = ""
        
        switch self.locationManager.authorizationStatus() {
        case .NotDetermined:
            self.locationManager.askAuthorization()
        case .AuthorizedWhenInUse:
            break
        case .AuthorizedAlways:
            authorizationAlertMessage = "La app solo tiene permisos para acceder al gps cuando esta en uso (AuthorizedAlways)"
            break
        case .Denied:
            authorizationAlertMessage = "No tenes activado el servicio de gps"
        case .Restricted:
            authorizationAlertMessage = "La app no tiene permisos para acceder al gps"
        }
        
        if authorizationAlertMessage.characters.count > 0 {
            let alertController = UIAlertController(title: "Error en la autorización del uso del gps", message: authorizationAlertMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler:nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.gpsDistancesFilterTextField {
            var text = "5"
            if textField.text?.characters.count > 0 {
                text = textField.text!
            } else {
                textField.text = text
            }
            
            self.locationManager.updateDistanceFilter(text)
        }
    }
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.locationManager.desiredAccuracyStringArray().count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.locationManager.desiredAccuracyStringArray()[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDesiredAccuracy = self.locationManager.desiredAccuracyStringArray()[row]
        self.gpsDesiredAccuracyTextField.text = selectedDesiredAccuracy
        self.locationManager.updateDesiredAccuracy(selectedDesiredAccuracy)
    }
    
}

