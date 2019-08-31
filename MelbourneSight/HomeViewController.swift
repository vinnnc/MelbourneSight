//
//  HomeViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var sightList = [SightAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func sightAnnotationAdded(annotation: SightAnnotation) {
        sightList.append(annotation)
        mapView.addAnnotation(annotation)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
