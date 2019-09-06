//
//  HomeViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SightDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    weak var databaseController: DatabaseProtocol?
    var locationManager: CLLocationManager = CLLocationManager()
    var allSights: [Sight] = []
    var allAnnotations: [SightAnnotation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        
        let defaultRegion = MKCoordinateRegion(center: .init(latitude: -37.8136, longitude: 144.9631), latitudinalMeters: 2500, longitudinalMeters: 2500)
        mapView.setRegion(mapView.regionThatFits(defaultRegion), animated: true)
        
        addAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnnotations()
    }
    
    func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        allSights = (databaseController?.fetchAllSights())!
        for sight in allSights {
            let annotation = SightAnnotation(newTitle: sight.name!, newSubtitle:  sight.desc!, latitude: sight.latitude, longitude: sight.longitude)
            allAnnotations.append(annotation)
            
            // Add geofence for each annotation
            let geoLocation = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: annotation.title!)
            geoLocation.notifyOnExit = true
            geoLocation.notifyOnEntry = true
            locationManager.startMonitoring(for: geoLocation)
        }
        mapView.addAnnotations(allAnnotations)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left \(region.identifier)", preferredStyle:
            .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have entered \(region.identifier)", preferredStyle:
            .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // AnnotaionViewDelegate is learnt from Youtube
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        let leftImageView = UIImageView.init(frame: CGRect(x: 50, y: 50, width: 50, height: 50))

        for sight in allSights {
            if annotation.title == sight.name {
                annotationView?.image = UIImage(named: sight.mapIcon!)
                leftImageView.image = loadImageData(fileName: sight.photo!)
                break
            }
        }
        
        annotationView?.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton
        annotationView?.leftCalloutAccessoryView = leftImageView
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            for sight in allSights {
                if view.annotation?.title == sight.name {
                    performSegue(withIdentifier: "sightDetailSegue", sender: sight)
                    return
                }
            }
        }
    }
    
    func focusOn(name: String) {
        for annotation in allAnnotations {
            if annotation.title == name {
                mapView.selectAnnotation(annotation, animated: true)
                let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
                return
            }
        }
    }
    
    func removeAnnotation(name: String) {
        for index in 0...allAnnotations.count {
            let annotation = allAnnotations[index]
            if annotation.title == name {
                allAnnotations.remove(at: index)
                mapView.removeAnnotation(annotation)
                let geoLocation = CLCircularRegion(center: annotation.coordinate, radius: 500, identifier: annotation.title!)
                locationManager.stopMonitoring(for: geoLocation)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightListSegue" {
            let destination = segue.destination as! SightListTableViewController
            destination.delegate = self
        }
        if segue.identifier == "sightDetailSegue" {
            let destination = segue.destination as! SightDetailViewController
            destination.sight = sender as? Sight
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
}
