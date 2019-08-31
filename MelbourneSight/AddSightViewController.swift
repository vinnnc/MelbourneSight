//
//  AddSightViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit

class AddSightViewController: UIViewController, UITextFieldDelegate {
    
    weak var sightDelegate: AddSightDelegate?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var mapIconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        descTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func takePhoto(_ sender: Any) {
    }
    
    @IBAction func save(_ sender: Any) {
        if nameTextField.text != "" && descTextField.text != "" && latitudeTextField.text != "" && longitudeTextField.text != "" {
            let name = nameTextField.text!
            let desc = descTextField.text!
            guard let latitude = Double(latitudeTextField.text!) else { return }
            guard let longitude = Double(longitudeTextField.text!) else { return }
            let mapIcon = String( mapIconSegmentedControl.selectedSegmentIndex)
            let photo = ""
            let newSight = Sight(name: name, desc: desc, latitude: latitude, longitude: longitude, mapIcon: mapIcon, photo: photo)
            let _ = sightDelegate!.addSight(newSight: newSight)
            navigationController?.popViewController(animated: true)
            return
        } else {
            displayMessage(title: "Not all fields filled", message: "Please fill all information.")
        }
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
