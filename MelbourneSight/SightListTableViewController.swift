//
//  SightListTableViewController.swift
//  MelbourneSight
//
//  Created by Wenchu Du on 2019/8/30.
//  Copyright © 2019 Wenchu Du. All rights reserved.
//

import UIKit

class SightListTableViewController: UITableViewController, UISearchResultsUpdating, AddSightDelegate {
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    let SECTION_SIGHTS = 0
    let CELL_SIGHT = "sightCell"
    var allSights: [Sight] = []
    var filteredSights: [Sight] = []
    weak var sightDelegate: AddSightDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredSights = allSights
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Heroes"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented.
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredSights = allSights.filter({(sight: Sight) -> Bool in
                return sight.name.contains(searchText)
            })
        } else {
            filteredSights = allSights
        }
        
        tableView.reloadData();
    }
    
    func addSight(newSight: Sight) -> Bool {
        allSights.append(newSight)
        filteredSights.append(newSight)
        tableView.beginUpdates()
        tableView.insertRows(at:[IndexPath(row: filteredSights.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
        return true
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.filteredSights.remove(at:indexPath.row)
            self.allSights.remove(at: indexPath.row)
            tableView.deleteRows(at:[indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addSightSegue" {
            let destination = segue.destination as! AddSightViewController
            destination.sightDelegate = self
        }
    }
}
