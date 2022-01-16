//
//  RecommendationsTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 04/07/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class RecommendationsTableViewController: UITableViewController, FUIAuthDelegate {
    
    //MARK: Properties
    
    var categories = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadCategories()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecommendationsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecommendationsTableViewCell else {
            fatalError("The dequeued cell is not an instance of RecommendationsTableViewCell.")
        }
        
        cell.categoryLabel.text = categories[indexPath.row]
        
        // Make labels dynamically change width based on text length
        // Must be applied after text change
        cell.categoryLabel.sizeToFit()
        
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowRecommendations" {
            guard let recommendationsItemsTableViewController = segue.destination as? RecommendationsItemsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let selectedListCell = sender as? RecommendationsTableViewCell else {
                fatalError("Unexpected sender: \(sender).")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedListCell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedCategory = categories[indexPath.row]
            
            recommendationsItemsTableViewController.categoryName = selectedCategory
        }
    }
    
    //MARK: Actions
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()
        
        presentFirebaseUI()
    }
    
    //MARK: Private methods
    private func loadCategories() {
        let nearCategory = "Near You"
        let typeCategory = "Priced Lower"
        
        categories += [nearCategory, typeCategory]
    }
    
    private func presentFirebaseUI() {
        if Auth.auth().currentUser == nil {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers: [FUIAuthProvider] = [
                FUIEmailAuth(),
                FUIAnonymousAuth(),
            ]
            
            authUI?.providers = providers
            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }

}
