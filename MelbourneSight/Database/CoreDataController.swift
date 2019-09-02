//
//  CoreDataController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/31.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
  
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "MelbourneSight")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)") }
        }
        
        super.init()
        
//        if fetchAllHeroes().count == 0 {
//            createDefaultEntries()
//        }
    }
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)") }
        }
    }
    
    func addSight(name: String, desc: String, latitude: Double, longitude: Double, mapIcon: String, photo: String) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into:
            persistentContainer.viewContext) as! Sight
        sight.name = name
        sight.desc = desc
        sight.latitude = latitude
        sight.longitude = longitude
        sight.mapIcon = mapIcon
        sight.photo = photo
        saveContext()
        return sight
    }
    
    func deleteSight(sight: Sight) {
        persistentContainer.viewContext.delete(sight)
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onSightsChange(change: .update, sights: fetchAllSights())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSights() -> [Sight] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            
            do {
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [Sight]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke {(listener) in
            listener.onSightsChange(change: .update, sights: fetchAllSights())
        }
    }
}
