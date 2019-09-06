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
        let _ = addSight(name: "Flinders Street Station", desc: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade.", latitude: -37.8183, longitude: 144.9671, mapIcon: "mapIcon_3", photo: "default_FlindersStreetStation")

        let _ = addSight(name: "Her Majesty's Theatre", desc: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886.", latitude: -37.8110, longitude: 144.9696, mapIcon: "mapIcon_0", photo: "default_HerMajestysTheatre")
        
        let _ = addSight(name: "Immigration Museum", desc: "Explore Melbourne's history through stories of people from across the world who have migrated to Victoria at the Immigration Museum. ", latitude: -37.8192, longitude: 144.9605, mapIcon: "mapIcon_1", photo: "default_ImmigrationMuseum")
        
        let _ = addSight(name: "Koorie Heritage Trust", desc: "The Koorie Heritage Trust is a bold and adventurous 21st century Aboriginal arts and cultural organisation. ", latitude: -37.8183, longitude: 144.9691, mapIcon: "mapIcon_3", photo: "default_KoorieHeritageTrust")
        
        let _ = addSight(name: "Manchester Unity Building", desc: "The Manchester Unity Building is one of Melbourne's most iconic Art Deco landmarks. It was built in 1932 for the Manchester Unity Independent Order of Odd Fellows (IOOF), a friendly society providing sickness and funeral insurance. Melbourne architect Marcus Barlow took inspiration from the 1927 Chicago Tribune Building. His design incorporated a striking New Gothic style façade of faience tiles with ground-floor arcade and mezzanine shops, café and rooftop garden. Step into the arcade for a glimpse of the marble interior, beautiful friezes and restored lift – or book a tour for a peek upstairs.", latitude: -37.8154, longitude: 144.9663, mapIcon: "mapIcon_5", photo: "default_ManchesterUnityBuilding")

        let _ = addSight(name: "Melbourne Museum", desc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.", latitude: -37.8033, longitude: 144.9717, mapIcon: "mapIcon_1", photo: "default_MelbourneMuseum")
        
        let _ = addSight(name: "Nicholas Building", desc: "Explore floor after floor of studios, galleries and curiosities in this heritage-listed creative hub. Shop for stunning textiles at Kimono House, found objects at Harold and Maude and vintage haberdashery at l'uccello. Trawl racks of vintage fashion at Retrostar or make an appointment for high-end millinery at Louise McDonald. Get behind the scenes and schedule your visit with one of the regular Open Studio days to see craftspeople at work in the historic studios. On the ground floor, browse the latest designs at Kuwaii and Obus in art deco Cathedral Arcade. Outside, stand back and admire the grandeur of the Renaissance palazzo-style architecture.", latitude: -37.8168, longitude: 144.9668, mapIcon: "mapIcon_4", photo: "default_NicholasBuilding")

        let _ = addSight(name: "Old Melbourne Gaol", desc: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.", latitude: -37.8078, longitude: 144.9653, mapIcon: "mapIcon_3", photo: "default_OldMelbourneGaol")
       
        let _ = addSight(name: "Old Treasury Building", desc: "The Old Treasury is regarded as one of the finest public buildings in Australia. Completed in 1862, it was the major government office in Melbourne throughout the 19th century, and second only to Parliament House as the centre of state affairs.", latitude: -37.8132, longitude: 144.9744, mapIcon: "mapIcon_3", photo: "default_OldTreasuryBuilding")

        let _ = addSight(name: "Parliament of Victoria", desc: "Victoria's Parliament House - one of Australia's oldest and most architecturally distinguished public buildings.", latitude: -37.8110, longitude: 144.9738, mapIcon: "mapIcon_3", photo: "default_ParliamentOfVictoria")

        let _ = addSight(name: "Polly Woodside", desc: "Climb aboard and roam the decks of the historic Polly Woodside, one of Australia’s last surviving 19th century tall ships. ", latitude: -37.8245, longitude: 144.9536, mapIcon: "mapIcon_5", photo: "default_PollyWoodside")

        let _ = addSight(name: "Royal Exhibition Building", desc: "The building is one of the world's oldest remaining exhibition pavilions and was originally built for the Great Exhibition of 1880. Later it housed the first Commonwealth Parliament from 1901, and was the first building in Australia to achieve a World Heritage listing in 2004.", latitude: -37.8047, longitude: 144.9717, mapIcon: "mapIcon_5", photo: "default_RoyalExhibitionBuilding")
        
        let _ = addSight(name: "St Paul's Cathedral", desc: "Leave the bustling Flinders Street Station intersection behind and enter the peaceful place of worship that's been at the heart of city life since the mid 1800s. Join a tour and admire the magnificent organ, the Persian Tile and the Five Pointed Star of the historic St Paul's Cathedral.", latitude: -37.8170, longitude: 144.9677, mapIcon: "mapIcon_4", photo: "default_StPaulsCathedral")

        let _ = addSight(name: "The Scots' Church", desc: "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline. Nestled between modern buildings on Russell and Collins streets, the decorated Gothic architecture and stonework is an impressive sight, as is the interior's timber panelling and stained glass. Trivia buffs, take note: the church was built by David Mitchell, father of Dame Nellie Melba (once a church chorister).", latitude: -37.8146, longitude: 144.9685, mapIcon: "mapIcon_4", photo: "default_TheScotsChurch")

        let _ = addSight(name: "Victoria Police Museum", desc: "Exhibitions at the Victoria Police Museum include the iconic armour worn by members of the Kelly Gang; the remains of the car used in the Russell Street headquarters bombing and police files on some of Melbourne's most infamous criminals, including 'Squizzy' Taylor.", latitude: -37.8223, longitude: 144.9542, mapIcon: "mapIcon_1", photo: "default_VictoriaPoliceMuseum")
    }
}
