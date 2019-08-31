//
//  DatabaseProtocol.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/31.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case sight
}

protocol DatabaseListener: AnyObject {
    var listenType: ListenerType {get set}
    func onSightsChange(change: DatabaseChange, sights: [Sight])
}

protocol DatabaseProtocol: AnyObject {
    func addSight(name: String, desc: String, latitude: Double, longitude: Double, mapIcon: String, photo: String) -> Sight
    func deleteSight(sight: Sight)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
