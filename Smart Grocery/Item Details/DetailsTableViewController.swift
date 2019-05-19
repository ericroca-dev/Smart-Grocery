//
//  DetailsTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 19/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var name: String?
    var image: UIImage?
    var category: String?
    var prices: [Double]?
    var locations: [Location]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.title = name
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Disable separator inset
        tableView.separatorColor = UIColor.clear
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + prices!.count
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
        } else {
            let cellIdentifier = "DetailsPriceTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsPriceTableViewCell else {
                fatalError("The dequeued cell is not an instance of DetailsPriceTableViewCell.")
            }
            
            cell.priceLabel.text = String(format: "%.2f", prices![indexPath.row - 2]) + " RON"
            cell.locationLabel.text = String(locations![indexPath.row - 2].longitude)
            print(String(locations![indexPath.row - 2].longitude))
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 414.0
        } else if (indexPath.row == 1) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
