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

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    weak var databaseController: DatabaseProtocol?
    var locationManager: CLLocationManager?
    var allSights: [Sight] = []
    var selectedAnnotation: SightAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        viewLoadSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewLoadSetup()
    }
    
    func viewLoadSetup() {
        let defaultRegion = MKCoordinateRegion(center: .init(latitude: -37.8136, longitude: 144.9631), latitudinalMeters: 4000, longitudinalMeters: 4000)
        mapView.setRegion(mapView.regionThatFits(defaultRegion), animated: true)
        addAnnotations()
        mapView.delegate = self
        if selectedAnnotation != nil {
            focusOn(annotation: selectedAnnotation!)
        }
    }
    
    func addAnnotations() {
        allSights = (databaseController?.fetchAllSights())!
        for sight in allSights {
            let annotation = SightAnnotation(newTitle: sight.name!, newSubtitle:  sight.desc!, latitude: sight.latitude, longitude: sight.longitude)
            mapView.addAnnotation(annotation)
            
            // Add geofence for each annotation
            let geoLocation = CLCircularRegion(center: annotation.coordinate, radius: 500, identifier: annotation.title!)
            geoLocation.notifyOnExit = true
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startMonitoring(for: geoLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left \(region.identifier)", preferredStyle:
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
        
        for sight in allSights {
            if annotation.title == sight.name {
                annotationView?.image = UIImage(named: sight.mapIcon!)
            }
        }
        
        annotationView?.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = rightButton
        
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
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightListSegue" {
            let destination = segue.destination as! SightListTableViewController
            destination.selectedAnnotation = selectedAnnotation
        }
        if segue.identifier == "sightDetailSegue" {
            let destination = segue.destination as! SightDetailViewController
            destination.sight = sender as? Sight
        }
    }
}
