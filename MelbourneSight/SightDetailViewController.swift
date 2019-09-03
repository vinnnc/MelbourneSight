//
//  SightDetailViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import MapKit

class SightDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapIconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationMapView: MKMapView!
    var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationMapView.delegate = self
        viewLoadSetup()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewLoadSetup()
    }
    
    func viewLoadSetup() {
        mapIconImageView.image = UIImage(named: sight!.mapIcon!)
        nameLabel.text = sight?.name
        descLabel.text = sight?.desc
        photoImageView.image = loadImageData(fileName: sight!.photo!)
        let annotation = SightAnnotation(newTitle: sight!.name!, newSubtitle: sight!.desc!, latitude: sight!.latitude, longitude: sight!.longitude)
        locationMapView.addAnnotation(annotation)
        focusOn(annotation: annotation)
    }
    
    func focusOn(annotation: MKAnnotation) {
        locationMapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        locationMapView.setRegion(locationMapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation.title == sight?.name {
            annotationView?.image = UIImage(named: sight!.mapIcon!)
        }
        
        return annotationView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSightSegue" {
            let destination = segue.destination as! EditSightViewController
            destination.sight = sight
        }
    }
    
}
