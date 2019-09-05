//
//  SightListTableViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit

class SightListTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    var listenType = ListenerType.sight
    let SECTION_SIGHTS = 0
    let CELL_SIGHT = "sightCell"
    var allSights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var delegate: SightDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Heroes"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
    }
    
    @IBAction func sort(_ sender: Any) {
        filteredSights.reverse()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredSights = allSights.filter({(sight: Sight) -> Bool in
                return (sight.name?.contains(searchText))!
            })
        } else {
            filteredSights = allSights
        }
        
        tableView.reloadData();
    }
    
    // MARK: - Database Listener
    
    func onSightsChange(change: DatabaseChange, sights: [Sight]) {
        allSights = sights
        updateSearchResults(for: navigationItem.searchController!)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredSights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SIGHT, for: indexPath) as! SightTableViewCell
        let sight = filteredSights[indexPath.row]
        cell.nameLabel.text = sight.name
        cell.descLabel.text = sight.desc
        cell.mapIconImageView.image = UIImage(named: sight.mapIcon!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sight = filteredSights[indexPath.row]
        delegate?.focusOn(name: sight.name!)
        navigationController?.popViewController(animated: true)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let sight = filteredSights[indexPath.row]
            delegate?.removeAnnotation(name: sight.name!)
            databaseController!.deleteSight(sight: sight)
        }
    }
}
