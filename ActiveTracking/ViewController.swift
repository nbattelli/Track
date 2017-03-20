//
//  ViewController.swift
//  ActiveTracking
//
//  Created by Nicolas Battelli on 19/7/16.
//  Copyright © 2016 NBattelli. All rights reserved.
//

import UIKit
import MessageUI
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UIViewController{
    
    var picker : UIPickerView!
    
    @IBOutlet var gpsStatusLabel : UILabel!
    @IBOutlet var gpsDistancesFilterTextField : UITextField!
    @IBOutlet var gpsDesiredAccuracyTextField : UITextField!
    
    @IBOutlet var gpsMinIntervalToLogTextField : UITextField!
    @IBOutlet var gpsMinPrecisionToLogTextField : UITextField!

    var locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SQLiteManager.createDB()
        
        self.setupView()
        
        self.askAuthorization()
        self.locationManager.startGPS()
    }
    
    func setupView () {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        print(path)
        
        // Label estado de gps
        self.gpsStatusLabel.text = self.locationManager.authorizationStatusString()
        
        // TextField Filtro de distancia
        self.gpsDistancesFilterTextField.delegate = self
        self.gpsDistancesFilterTextField.keyboardType = .numberPad
        self.gpsDistancesFilterTextField.inputAccessoryView = self.toolBar()
        self.gpsDistancesFilterTextField.text = self.locationManager.distanceFilterString()
        
        
        // TextField Precisión deseada
        self.gpsDesiredAccuracyTextField.delegate = self
        self.gpsDesiredAccuracyTextField.text = self.locationManager.desiredAccuracyString()
        self.gpsDesiredAccuracyTextField.inputView = self.desiredAccuracyPicker()
        self.gpsDesiredAccuracyTextField.inputAccessoryView = self.toolBar()
        
        // TextField intervalo de tiempo
        self.gpsMinIntervalToLogTextField.delegate = self
        self.gpsMinIntervalToLogTextField.keyboardType = .numbersAndPunctuation
        self.gpsMinIntervalToLogTextField.text = "\(self.locationManager.minIntervalToLog)"
        self.gpsMinIntervalToLogTextField.inputAccessoryView = self.toolBar()
        
        // TextField Precisión de la geopoint obtenida
        self.gpsMinPrecisionToLogTextField.delegate = self
        self.gpsMinPrecisionToLogTextField.keyboardType = .numberPad
        self.gpsMinPrecisionToLogTextField.text = "\(self.locationManager.minPrecisionToLog)"
        self.gpsMinPrecisionToLogTextField.inputAccessoryView = self.toolBar()
    }
    
    func desiredAccuracyPicker() -> UIPickerView {
        self.picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 300))
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        return self.picker
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
    
    func askAuthorization() {
        
        var authorizationAlertMessage = ""
        
        switch self.locationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.askAuthorization()
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
    
    @IBAction func sendFullJSON() {
        if let jsonString = SQLiteManager.retrieveAllRowsAsJSONString() {
            self.saveToDiskAndSendEmail(jsonString, fileName:"locations.json")
        } else {
            self.showAlertMessage("Error", message: "No se obtuvieron localizaciones")
        }
    }
    
    @IBAction func sendJSONForGeoJSON() {
        if let jsonString = SQLiteManager.retrieveAllRowsForGeoJSONString() {
            self.saveToDiskAndSendEmail(jsonString, fileName:"locationsForGeoJSON.json")
        } else {
            self.showAlertMessage("Error", message: "No se obtuvieron localizaciones")
        }
    }
    
    @IBAction fileprivate func cleanDataBase() {
        SQLiteManager.clearAllRows()
    }
    
    fileprivate func saveToDiskAndSendEmail(_ text:String, fileName:String) {
        
        let filePath = "\(basePath())/\(fileName)"
        do {
            do {
            //Remove old file
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: filePath)
            } catch {}
            
            try text.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            self.emailFile(fileName)
        } catch {
            self.showAlertMessage("Error", message: "No se pudo generar el archivo para mandar el mail")
        }
    }
    
    fileprivate func emailFile(_ fileName:String) {
        let filePath = "\(basePath())/\(fileName)"
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            mailComposer.setSubject("Subject")
            mailComposer.setMessageBody("body text", isHTML: false)
            
            if let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                mailComposer.addAttachmentData(fileData, mimeType: "text/txt", fileName: fileName)
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func showAlertMessage(_ title:String, message:String) {
        let alertController = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: .default, handler:nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.gpsDesiredAccuracyTextField {
            let index = self.locationManager.desiredAccuracyStringArray().index(of: self.locationManager.desiredAccuracyString())
            picker.selectRow(index!, inComponent: 0, animated: false)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0 {
            return
        }
        if textField == self.gpsDistancesFilterTextField {
            var text = "5"
            if textField.text?.characters.count > 0 {
                text = textField.text!
            } else {
                textField.text = text
            }
            
            self.locationManager.updateDistanceFilter(text)
        } else if textField == self.gpsMinIntervalToLogTextField {
            self.locationManager.minIntervalToLog = Double(textField.text!)!
        } else if textField == self.gpsMinPrecisionToLogTextField {
            self.locationManager.minPrecisionToLog = Int(textField.text!)!
        }
    }
}

extension ViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.locationManager.desiredAccuracyStringArray().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.locationManager.desiredAccuracyStringArray()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDesiredAccuracy = self.locationManager.desiredAccuracyStringArray()[row]
        self.gpsDesiredAccuracyTextField.text = selectedDesiredAccuracy
        self.locationManager.updateDesiredAccuracy(selectedDesiredAccuracy)
    }
    
}

extension ViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

