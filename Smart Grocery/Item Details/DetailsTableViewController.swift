//
//  DetailsTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 19/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class DetailsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //MARK: Properties
    
    var items = [Item]()
    
    var name: String?
    var image: UIImage?
    var category: String?
    var prices: [Double]?
    var locations: [Location]?
    var barcode: String?
    var placesClient: GMSPlacesClient!
    
    var locationManager: CLLocationManager?
    var location: Location?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = name
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Disable separator inset
        tableView.separatorColor = UIColor.clear
        
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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + prices!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cellIdentifier = "DetailsPhotoTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsPhotoTableViewCell else {
                fatalError("The dequeued cell is not an instance of DetailsPhotoTableViewCell.")
            }
            
            cell.photoImageView.image = image
            
            // Disable graying when tapping
            cell.selectionStyle = .none
            
            return cell
        } else if (indexPath.row == 1) {
            let cellIdentifier = "DetailsCategoryLabelTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsCategoryLabelTableViewCell else {
                fatalError("The dequeued cell is not an instance of DetailsCategoryLabelTableViewCell.")
            }
            
            cell.categoryLabel.text = category
            
            // Disable graying when tapping
            cell.selectionStyle = .none
            
            return cell
        } else if indexPath.row == 2 {
            let cellIdentifier = "DetailsStoresTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsStoresTableViewCell else {
                fatalError("The dequeued cell is not an instance of DetailsStoresTableViewCell.")
            }
            
            // Disable graying when tapping
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cellIdentifier = "DetailsPriceTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsPriceTableViewCell else {
                fatalError("The dequeued cell is not an instance of DetailsPriceTableViewCell.")
            }
            
            let geocoder = GMSGeocoder()
            let coordinate = CLLocationCoordinate2DMake(locations![indexPath.row - 3].latitude, locations![indexPath.row - 3].longitude)
            
            var currentAddress = String()
            
            geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
                //
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    if let places = response?.results() {
                        if let place = places.first {
                            
                            if let lines = place.lines {
                                print("GEOCODE: Formatted Address: \(lines)")
                            }
                            
                            if let sublocality = place.subLocality {
                                print("GEOCODE: Formatted Sublocality: \(sublocality)")
                            }
                            
                            if let thoroughfare = place.thoroughfare {
                                print("GEOCODE: Formatted Thoroughfare: \(thoroughfare)")
                            }
                            
                            currentAddress = (place.lines?.joined(separator: "\n"))!
                            print("Current address: \(currentAddress)")
                            cell.locationLabel.text = currentAddress.components(separatedBy: ",")[0]
                        } else {
                            print("GEOCODE: nil first in places")
                        }
                    } else {
                        print("GEOCODE: nil in places")
                    }
                }
            }
            
            cell.priceLabel.text = String(format: "%.2f", prices![indexPath.row - 3]) + " RON"
            
            print("Current address split: \(currentAddress.components(separatedBy: ",")[0])")
            
            cell.priceLabel.sizeToFit()
            cell.locationLabel.sizeToFit()
            //print(String(locations![indexPath.row - 2].longitude))
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 414.0
        } else if (indexPath.row == 1 || indexPath.row == 2) {
            return 44.0
        } else {
            return 88.0
        }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case _ where indexPath.row > 2:
            showGoogleMaps(index: indexPath.row)
        default:
            return
        }
    }

    //MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
//        if segue.identifier == "ShowDetailsMap" {
//            guard let detailsMapViewController = segue.destination as? DetailsMapViewController else {
//                fatalError("Unexpected destination: \(segue.destination).")
//            }
//
//            guard let selectedItemCell = sender as? DetailsPriceTableViewCell else {
//                fatalError("Unexpected sender: \(sender).")
//            }
//
//            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
//                fatalError("The selected cell is not being displayed by the table.")
//            }
//
//            detailsMapViewController.latitude = locations![indexPath.row - 2].latitude
//            detailsMapViewController.longitude = locations![indexPath.row - 2].longitude
//        }
    }
    
    //MARK: Actions
    
    // Add list to table after user input
    @IBAction func unwindToDetailsTable(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddPriceTableViewController, let price = sourceViewController.price {
            if let index = items.firstIndex(where: {$0.name == name}) {
                items[index].prices.append(price)
                items[index].locations.append(location!)
                
                prices?.append(price)
                locations?.append(location!)
                
                saveItems()
                tableView.reloadData()
            }
        }
    }
    
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
    
    //MARK: Private methods
    
    func showGoogleMaps(index: Int) {
        UIApplication.shared.openURL(URL(string:"comgooglemaps://?saddr=&daddr=\(locations![index - 3].latitude),\(locations![index - 3].longitude)")!)
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("Items successfully saved.")
        } else {
            fatalError("Failed to save items.")
        }
    }
    
}
