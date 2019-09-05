//
//  SightDelegate.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/9/3.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import Foundation
import MapKit

protocol SightDelegate: AnyObject {
    func focusOn(name: String)
    func removeAnnotation(name: String)
}
