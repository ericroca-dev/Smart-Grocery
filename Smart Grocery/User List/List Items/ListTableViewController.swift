//
//  ListTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 22/05/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var listName: String?
    var items = [Item]()
    var lists = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Load any saved items
        if let savedItems = loadItems() {
            items += savedItems
        }
        
        self.title = listName
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListTableViewCell.")
        }
        
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.photoImageView.image = item.photo
        
        // Make labels dynamically change width based on text length
        // Must be applied after text change
        cell.nameLabel.sizeToFit()

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
            items.remove(at: indexPath.row)
            saveItems()
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

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowListDetails" {
            guard let detailsTableViewController = segue.destination as? DetailsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let selectedItemCell = sender as? ListTableViewCell else {
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
    
    // Rename list after user input
    @IBAction func unwindToList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RenameListTableViewController, let name = sourceViewController.name {
            lists = loadLists()!
            let index = lists.firstIndex(where: {$0 == listName})
            clearItems(index: index!)
            
            self.title = name
            listName = name
            lists[index!] = name
            saveLists()
            saveItems()
        }
    }
    
    //MARK: Private methods
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ListArchiveURL.appendingPathComponent(self.listName!).path)
        
        if isSuccessfulSave {
            print("Items successfully saved.")
        } else {
            fatalError("Failed to save items.")
        }
    }
    
    private func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.appendingPathComponent(self.listName!).path) as? [Item]
    }
    
    private func saveLists() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(lists, toFile: Item.ListsArchiveURL.path)
        
        if isSuccessfulSave {
            print("Lists successfully saved.")
        } else {
            fatalError("Failed to save lists.")
        }
    }
    
    private func loadLists() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListsArchiveURL.path) as? [String]
    }
    
    private func clearItems(index: Int) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject([], toFile: Item.ListArchiveURL.appendingPathComponent(lists[index]).path)
        
        if isSuccessfulSave {
            print("Items successfully cleared.")
        } else {
            fatalError("Failed to clear items.")
        }
    }

}