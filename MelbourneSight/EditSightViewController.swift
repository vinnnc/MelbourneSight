//
//  EditSightViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import MapKit

class EditSightViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var mapIconSegmentedControl: UISegmentedControl!
    @IBOutlet weak var photoImageView: UIImageView!
    var sight: Sight?
    weak var databaseController: DatabaseProtocol?
    var viewController: UIViewController?
    var currentLocation: CLLocationCoordinate2D?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        descTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        
        nameTextField.text = sight?.name
        descTextField.text = sight?.desc
        latitudeTextField.text = "\(sight?.latitude ?? 0)"
        longitudeTextField.text = "\(sight?.longitude ?? 0)"
        mapIconSegmentedControl.selectedSegmentIndex = Int(String(sight!.mapIcon!.last!))!
        photoImageView.image = loadImageData(fileName: sight!.photo!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        } else {
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
            databaseController!.deleteSight(sight: sight!)
            let _ = databaseController!.addSight(name: name, desc: desc, latitude: latitude, longitude: longitude, mapIcon: mapIcon, photo: photo)
            
            sight?.name = name
            sight?.desc = desc
            sight?.latitude = latitude
            sight?.longitude = longitude
            sight?.mapIcon = mapIcon
            sight?.photo = photo
            
            navigationController?.popViewController(animated: true)
            return
        } else {
            displayMessage(title: "Not all fields filled", message: "Please fill all information.")
        }
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        if fileName.hasPrefix("default_") {
            return UIImage(named: fileName)
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
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
