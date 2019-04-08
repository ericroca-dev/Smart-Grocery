//
//  ItemTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    
    var items = [Item]()
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadSampleItems()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }

        // Fetches the appropriate item for the data source layout
        let item = items[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.priceLabel.text = String(format: "%.2f", item.price) + " RON"
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
    
    //MARK: Actions
    
    @IBAction func takeItemPhoto(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Take Photo", message: "Take a photo of the item you want to add.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion:nil)
    }
    
    // Add item to table after user input
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddItemTableViewController, let item = sourceViewController.item {
            
            let newIndexPath = IndexPath(row: items.count, section: 0)
            items.append(item)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    //MARK: Photo Taking
    
    // Use image after taking photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let pickerImage = info[.editedImage] as? UIImage else {
            fatalError("No image found.")
        }
        
        image = pickerImage
        
//        guard let item = Item(name: "Demo", price: 0.0, photo: image) else {
//            fatalError("Unable to instantiate item.")
//        }
        
//        let newIndexPath = IndexPath(row: items.count, section: 0)
//        items.append(item)
//        tableView.insertRows(at: [newIndexPath], with: .automatic)
        
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "AddItem", sender: self)
        })
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AddItem" {
            
            // Get through Navigation Controller before accessing view
            if let navigationController = segue.destination as? UINavigationController {
                if let addItemTableViewController = navigationController.topViewController as? AddItemTableViewController {
                    addItemTableViewController.image = image
                }
            }
        }
    }

    //MARK: Private methods
    
    private func loadSampleItems() {
        let photo1 = UIImage(named: "testImage")!
        
        guard let item1 = Item(name: "Coca-Cola", price: 3.50, photo: photo1) else {
            fatalError("Unable to instantiate item1.")
        }
        
        items += [item1]
    }
}
