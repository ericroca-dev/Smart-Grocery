//
//  ListsTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 01/06/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class ListsTableViewController: UITableViewController {

    //MARK: Properties
    
    var lists = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Initialize Edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        lists.append("Lunch")
        lists.append("Workout")
        lists.append("Snack")
        lists.append("Weekly")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ListsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListsTableViewCell.")
        }
        
        let list: String
        
        // Fetches the appropriate list for the data source layout
        list = lists[indexPath.row]
        
        cell.listLabel.text = list
        
        // Make labels dynamically change width based on text length
        // Must be applied after text change
        cell.listLabel.sizeToFit()
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            lists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Actions
    
    // Add list to table after user input
    @IBAction func unwindToListTable(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddListTableViewController, let name = sourceViewController.name {
            
            let newIndexPath = IndexPath(row: lists.count, section: 0)
            lists.append(name)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
}
