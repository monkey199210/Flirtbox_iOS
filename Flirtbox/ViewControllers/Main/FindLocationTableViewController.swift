//
//  FindLocationTableViewController.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 05.12.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import UIKit
protocol FindLocationDelegate: class {
    func selectedPlace(place: FBPlace)
}
class FindLocationTableViewController: UITableViewController, UISearchResultsUpdating {

    // MARK: - Lifecycle
    weak var delegate: FindLocationDelegate?
    private let searchController = UISearchController(searchResultsController: nil)
    private var result: [FBPlace] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchController.active = true
        FBoxHelper.delay(0.5) { () -> () in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    // MARK: - Actions
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count + 1
    }
    
    private var lastCell: LastTableViewCell?
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.row == result.count {
            cell = tableView.dequeueReusableCellWithIdentifier("LastTableViewCell", forIndexPath: indexPath)
            if let lastCell = cell as? LastTableViewCell{
                self.lastCell = lastCell
            }
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("LocationTableViewCell", forIndexPath: indexPath)
            if let locationCell = cell as? LocationTableViewCell{
                let place = result[indexPath.row]
                locationCell.locationText.text = place.geoname
            }
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < result.count {
            let place = result[indexPath.row]
            delegate?.selectedPlace(place)
            if searchController.active {
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text where searchController.active else {
            return
        }
        lastCell?.activity.startAnimating()
        Net.getLocations(searchText).onSuccess { (places) -> Void in
            self.result = places
            self.lastCell?.activity.stopAnimating()
        }
    }
}
