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
        
        if fetchAllSights().count == 0 {
            createDefaultEntries()
        }
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
    
    func createDefaultEntries() {
        let _ = addSight(name: "Her Majesty's Theatre", desc: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886.", latitude: -37.8110, longitude: 144.9696, mapIcon: "mapIcon_0", photo: "default_HerMajestysTheatre")
        
        let _ = addSight(name: "Victoria Police Museum", desc: "Exhibitions at the Victoria Police Museum include the iconic armour worn by members of the Kelly Gang; the remains of the car used in the Russell Street headquarters bombing and police files on some of Melbourne's most infamous criminals, including 'Squizzy' Taylor.", latitude: -37.8223, longitude: 144.9542, mapIcon: "mapIcon_1", photo: "default_VictoriaPoliceMuseum")
        
        let _ = addSight(name: "Melbourne Museum", desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", latitude: -37.8033, longitude: 144.9717, mapIcon: "mapIcon_1", photo: "default_MelbourneMuseum")
        
        let _ = addSight(name: "Brighton Bathing Boxes", desc: "Dive into Port Phillip Bay under the watch of 82 distinctive bathing boxes, a row of uniformly proportioned wooden structures lining the foreshore at Brighton Beach.", latitude: -37.9177, longitude: 144.9866, mapIcon: "mapIcon_4", photo: "default_BrightonBathingBoxes")
        
        let _ = addSight(name: "Old Treasury Building", desc: "The Old Treasury is regarded as one of the finest public buildings in Australia. Completed in 1862, it was the major government office in Melbourne throughout the 19th century, and second only to Parliament House as the centre of state affairs.", latitude: -37.8132, longitude: 144.9744, mapIcon: "mapIcon_3", photo: "default_OldTreasuryBuilding")
        
        let _ = addSight(name: "Shrine of Remembrance", desc: "The Shrine of Remembrance is a building with a soul. Opened in 1934, the Shrine is the Victorian state memorial to Australians who served in global conflicts throughout our nation’s history. Inspired by Classical architecture, the Shrine was designed and built by veterans of the First World War.", latitude: -37.8305, longitude: 144.9734, mapIcon: "mapIcon_3", photo: "default_ShrineOfRemembrance")
        
        let _ = addSight(name: "St Kilda Pier", desc: "Providing panoramic views of the Melbourne skyline and Port Phillip Bay, the pier is a popular destination for strolling, cycling, rollerblading and fishing. Catch a ferry to Williamstown, enjoy a snack at the kiosk or try to spot the penguins and native water rats from the breakwater. Whatever your preference, St Kilda Pier provides an unforgettable experience right in the heart of Melbourne.", latitude: -37.8679, longitude: 144.9740, mapIcon: "mapIcon_5", photo: "default_StKildaPier")
        
        let _ = addSight(name: "Cooks' Cottage", desc: "Built in 1755, Cooks' Cottage is the oldest building in Australia and a popular Melbourne tourist attraction.", latitude: -37.8852, longitude: 144.9846, mapIcon: "mapIcon_5", photo: "default_CooksCottage")
        
        let _ = addSight(name: "Parliament of Victoria", desc: "Victoria's Parliament House - one of Australia's oldest and most architecturally distinguished public buildings.", latitude: -37.8127, longitude: 144.9801, mapIcon: "mapIcon_3", photo: "default_ParliamentOfVictoria")
        
        let _ = addSight(name: "Werribee Park and Mansion", desc: "Enjoy a perfect day out at Werribee Park. Experience the grandeur of Werribee Mansion, discover Victoria's unique pastoral history down at the farm and homestead, relax with family and friends on the Great lawn surrounded by stunning formal gardens, and so much more.", latitude: -37.9301, longitude: 144.6724, mapIcon: "mapIcon_4", photo: "default_WerribeeParkAndMansion")
        
        let _ = addSight(name: "Steamrail Victoria", desc: "Steamrail Victoria is a non-profit organisation dedicated to the restoration and operation of vintage steam, diesel and electric locomotives and carriages.", latitude: -37.8504, longitude: 144.8804, mapIcon: "mapIcon_4", photo: "default_SteamrailVictoria")
        
        let _ = addSight(name: "Koorie Heritage Trust", desc: "The Koorie Heritage Trust is a bold and adventurous 21st century Aboriginal arts and cultural organisation. ", latitude: -37.8183, longitude: 144.9691, mapIcon: "mapIcon_3", photo: "default_KoorieHeritageTrust")
        
        let _ = addSight(name: "Como House and Garden", desc: "Built in 1847, Como House and Garden is one of Melbourne most glamorous stately homes. A unique blend of Australian Regency and classic Italianate architecture, Como House offers a rare glimpse into the opulent lifestyles of former owners, the Armytage family, who lived there for over a century.", latitude: -37.8379, longitude: 145.0037, mapIcon: "mapIcon_4", photo: "default_ComoHouseAndGarden")
        
        let _ = addSight(name: "Polly Woodside", desc: "Climb aboard and roam the decks of the historic Polly Woodside, one of Australia’s last surviving 19th century tall ships. ", latitude: -37.8245, longitude: 144.9536, mapIcon: "mapIcon_5", photo: "default_PollyWoodside")
        
        let _ = addSight(name: "Old Melbourne Gaol", desc: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.", latitude: -37.8078, longitude: 144.9653, mapIcon: "mapIcon_3", photo: "default_OldMelbourneGaol")
    }
}
