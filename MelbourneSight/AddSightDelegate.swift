//
//  AddSightDelegate.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import Foundation

protocol AddSightDelegate: AnyObject {
    func addSight(newSight: Sight) -> Bool
}
