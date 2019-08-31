//
//  SightAnnotation.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/31.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import MapKit

class SightAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(newTitle: String, newSubtitle: String, latitude: Double, longitude: Double) {
        self.title = newTitle
        self.subtitle = newSubtitle
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
