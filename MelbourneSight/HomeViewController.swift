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

class HomeViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    weak var databaseController: DatabaseProtocol?
    var allSights: [Sight] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        mapView.delegate = self
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
    }
    
    func addAnnotations() {
        allSights = (databaseController?.fetchAllSights())!
        for sight in allSights {
            let annotation = SightAnnotation(newTitle: sight.name!, newSubtitle:  sight.desc!, latitude: sight.latitude, longitude: sight.longitude)
            mapView.addAnnotation(annotation)
            mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(SightAnnotation.self))
        }
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
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Annotation has been selected")
    }
}
