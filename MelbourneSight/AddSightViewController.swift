//
//  AddSightViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AddSightViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var currentLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager = CLLocationManager()
    
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
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        }
        else {
            let alertController = UIAlertController(title: "Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        if nameTextField.text != "" && descTextField.text != "" && latitudeTextField.text != "" && longitudeTextField.text != "" {
            let name = nameTextField.text!
            let desc = descTextField.text!
            guard let latitude = Double(latitudeTextField.text!) else { return }
            guard let longitude = Double(longitudeTextField.text!) else { return }
            
            guard let image = photoImageView.image else {
                displayMessage(title: "Cannot save until a photo has been taken!", message: "Error")
                return
            }
            let date = UInt(Date().timeIntervalSince1970)
            var data = Data()
            data = image.jpegData(compressionQuality:0.8)!
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("\(date)") {
                let filePath = pathComponent.path as String
                let fileManager = FileManager.default
                fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            }
            let photo = "\(date)"
            let mapIcon = "mapIcon_\(mapIconSegmentedControl.selectedSegmentIndex)"
            let _ = databaseController!.addSight(name: name, desc: desc, latitude: latitude, longitude: longitude, mapIcon: mapIcon, photo: photo)
            navigationController?.popViewController(animated: true)
            return
        } else {
            displayMessage(title: "Not all fields filled", message: "Please fill all information.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            photoImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage(title: "There was an error in getting the image", message: "Error")
    }
        
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
