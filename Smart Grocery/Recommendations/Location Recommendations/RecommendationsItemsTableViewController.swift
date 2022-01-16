//
//  RecommendationsItemsTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 04/07/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import CoreLocation

class RecommendationsItemsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //MARK: Properties
    var categoryName: String?
    var items = [Item]()
    var allItems = [Item]()
    var lists = [String]()
    
    var locationManager: CLLocationManager?
    var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        locationManager = CLLocationManager()
        locationManager!.requestAlwaysAuthorization()
        
        // Location
        let status = CLLocationManager.authorizationStatus()
        
        switch (status) {
        case .notDetermined:
            locationManager!.requestWhenInUseAuthorization()
            return
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
        
        locationManager!.delegate = self
        locationManager!.startUpdatingLocation()
        
        // Load any saved items
        if let savedLists = loadLists() {
            lists += savedLists
        }
        
        self.title = categoryName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadAllItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.getItems()
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecommendationsItemsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecommendationsItemsTableViewCell else {
            fatalError("The dequeued cell is not an instance of RecommendationsItemsTableViewCell.")
        }
        
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.priceLabel.text = String(format: "%.2f", item.prices[0]) + " RON"
        cell.photoImageView.image = item.photo
        
        // Make labels dynamically change width based on text length
        // Must be applied after text change
        cell.nameLabel.sizeToFit()
        cell.priceLabel.sizeToFit()
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            print("Current location: \(currentLocation)")
            location = Location(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowRecommendation" {
            guard let detailsTableViewController = segue.destination as? DetailsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let selectedItemCell = sender as? RecommendationsItemsTableViewCell else {
                fatalError("Unexpected sender: \(sender).")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedItem = items[indexPath.row]
            
            detailsTableViewController.name = selectedItem.name
            detailsTableViewController.image = selectedItem.photo
            detailsTableViewController.category = selectedItem.category
            detailsTableViewController.prices = selectedItem.prices
            detailsTableViewController.locations = selectedItem.locations
            detailsTableViewController.barcode = selectedItem.barcode
            detailsTableViewController.items = self.items
            detailsTableViewController.item = selectedItem
        }
    }
    
    //MARK: Private methods
    
    private func loadAllItems() {
        
        let returnedList = (NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]) ?? []
        allItems = returnedList
        print("test")
    }
    
    private func loadLists() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListsArchiveURL.path) as? [String]
    }
    
    private func getItems() {
        items.removeAll()
        if categoryName == "Near You" {
            for item in allItems {
                print("test")
                for shopLocation in item.locations {
                    let itemLocation = CLLocation(latitude: shopLocation.latitude, longitude: shopLocation.longitude)
                    let currentLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
                    let distance = currentLocation.distance(from: itemLocation)
                    if distance <= 1000 {
                        items.append(item)
                    }
                }
            }
        } else if categoryName == "Priced Lower" {
            var userItems = [Item]()
            for list in lists {
                let returnedList = (NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.appendingPathComponent(list).path) as? [Item]) ?? []
                userItems += returnedList
            }
            for item in allItems {
                print("test")
                userItems.sorted(by: { $0.prices.min()! < $1.prices.min()! })
                print(userItems)
                let lowestPriced = userItems.first(where: {$0.category == item.category})
                if lowestPriced == nil {
                    items.append(item)
                } else if lowestPriced!.prices.min()! > item.prices.min()! {
                    items.append(item)
                }
            }
        }
        tableView.reloadData()
    }

}
