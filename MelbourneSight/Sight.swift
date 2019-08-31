//
//  Sight.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit

class Sight: NSObject {
    var name: String
    var desc: String
    var latitude: Double
    var longitude: Double
    var mapIcon: String
    var photo: String
    
    init(name: String, desc: String, latitude: Double, longitude: Double, mapIcon: String, photo: String) {
        self.name = name
        self.desc = desc
        self.latitude = latitude
        self.longitude = longitude
        self.mapIcon = mapIcon
        self.photo = photo
    }
}
