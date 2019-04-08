//
//  AddItemTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class AddItemTableViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    var placeholders = [String]()
    
    // This value is used to construct a new item
    var item: Item?
    var image: UIImage?

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaceholders()
        
        // Initial disabling of Done button
        doneButton.isEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AddItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of AddItemTableViewCell.")
        }

        // Fetches the appropriate placeholder for the data source layout
        let placeholder = placeholders[indexPath.row]
        
        // Handle the text field's user input
        cell.textField.delegate = self
        
        // Disable graying when tapping
        cell.selectionStyle = .none
        
        cell.textField.placeholder = placeholder

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

    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Disable the Done button while editing
        doneButton.isEnabled = false
    }
    
    // Update Done button state after editing a text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the Done button is pressed
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            fatalError("The Done button was not pressed, cancelling.")
        }
        
        // Get text field positions
        let nameIndexPath = IndexPath(row: 0, section: 0)
        let priceIndexPath = IndexPath(row: 1, section: 0)
        
        // Get text field cells
        let nameCell = tableView.cellForRow(at: nameIndexPath) as! AddItemTableViewCell
        let priceCell = tableView.cellForRow(at: priceIndexPath) as! AddItemTableViewCell
        
        let name = nameCell.textField.text ?? ""
        let priceString = priceCell.textField.text ?? ""
        
        let price = Double(priceString)
        
        item = Item(name: name, price: price!, photo: image!)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func loadPlaceholders() {
        let namePlaceholder = "Name"
        let pricePlaceholder = "Price"
        
        placeholders += [namePlaceholder, pricePlaceholder]
    }
    
    private func updateDoneButtonState() {
        
        // Disable the Done button if any of the text fields are empty
        
        // Get text field positions
        let nameIndexPath = IndexPath(row: 0, section: 0)
        let priceIndexPath = IndexPath(row: 1, section: 0)
        
        // Get text field cells
        let nameCell = tableView.cellForRow(at: nameIndexPath) as! AddItemTableViewCell
        let priceCell = tableView.cellForRow(at: priceIndexPath) as! AddItemTableViewCell
        
        let name = nameCell.textField.text ?? ""
        let priceString = priceCell.textField.text ?? ""
        
        doneButton.isEnabled = !name.isEmpty && !priceString.isEmpty
    }
}