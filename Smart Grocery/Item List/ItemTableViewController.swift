//
//  ItemTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import Vision

class ItemTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    
    var items = [Item]()
    var image: UIImage?
    var barcodeValue: String?
    
    var barcodePhotoTaken: Bool?
    
    var filteredItems = [Item]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var barcodeRequest: VNDetectBarcodesRequest = {
        return VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Search Controller setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        // Eliminate empty rows
        tableView.tableFooterView = UIView(frame: .zero)

        // Load any saved items
        if let savedItems = loadItems() {
            items += savedItems
        }
        
        // loadSampleItems()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItems.count
        } else {
            return items.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }

        let item: Item
        
        // Fetches the appropriate item for the data source layout
        
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        
        cell.nameLabel.text = item.name
        cell.priceLabel.text = String(format: "%.2f", item.price) + " RON"
        cell.photoImageView.image = item.photo
        
        // Make labels dynamically change width based on text length
        // Must be applied after text change
        cell.nameLabel.sizeToFit()
        cell.priceLabel.sizeToFit()

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
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
        
        let alertController = UIAlertController(title: "Take Photo", message: "Take a photo of the item you want to add.", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            self.dismiss(animated: true)
        }
        alertController.addAction(cancelAction)

        imagePicker.present(alertController, animated: true, completion: nil)
    }
    
    // Add item to table after user input
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddItemTableViewController, let item = sourceViewController.item {
            
            let newIndexPath = IndexPath(row: items.count, section: 0)
            items.append(item)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        
        saveItems()
    }
    
    //MARK: Photo Taking
    
    func takeBarcodePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
        
        let alertController: UIAlertController
        
        if (!barcodePhotoTaken!) {
            alertController = UIAlertController(title: "Scan Barcode", message: "Take a close-up photo of the item's barcode.", preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: "No Barcode Found", message: "Try taking a closer or further photo of the barcode.", preferredStyle: .alert)
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            self.dismiss(animated: true)
            self.barcodePhotoTaken = nil
        }
        alertController.addAction(cancelAction)
        
        imagePicker.present(alertController, animated: true, completion: nil)
    }
    
    // Use image after taking photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let pickerImage = info[.editedImage] as? UIImage else {
            fatalError("No image found.")
        }
        guard let ciImage = CIImage(image: pickerImage) else {
            fatalError("Can't create CIImage from UIImage.")
        }
        
        // Only save item image
        if (self.barcodePhotoTaken == nil) {
            image = pickerImage
        }
        
        // Run the rectangle detector, which upon completion runs the ML classifier
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [.properties: ""])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.barcodeRequest])
            } catch {
                print(error)
            }
        }
        
        picker.dismiss(animated: true, completion: {
            
            // On first pass, result will be false
            // On second pass, result will be true
            // Next passes will not change the result
            if (self.barcodePhotoTaken == nil) {
                self.barcodePhotoTaken = false
            } else if (self.barcodePhotoTaken == false) {
                self.barcodePhotoTaken = true
            }
            
            // Barcode photo will only be taken once; if it was not taken
            // Or until a barcode is found
            if (!self.barcodePhotoTaken! || self.barcodeValue == nil) {
                self.self.takeBarcodePhoto()
            } else {
                self.performSegue(withIdentifier: "AddItem", sender: self)
            }
        })
        
        
//        picker.dismiss(animated: true, completion: {
////            let alertController = UIAlertController(title: "Barcode", message: self.barcodeValue!, preferredStyle: .alert)
////            self.present(alertController, animated: true, completion:nil)
////
////            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
////                self.performSegue(withIdentifier: "AddItem", sender: self)
////            }
////            alertController.addAction(OKAction)
//
//            // self.takeBarcodePhoto()
//
//            // self.performSegue(withIdentifier: "AddItem", sender: self)
//        })
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "AddItem" {
            
            // Get through Navigation Controller before accessing view
            if let navigationController = segue.destination as? UINavigationController {
                if let addItemTableViewController = navigationController.topViewController as? AddItemTableViewController {
                    addItemTableViewController.image = image
                    addItemTableViewController.barcode = barcodeValue
                }
            }
        } else if segue.identifier == "ShowDetails" {
            
            guard let detailsTableViewController = segue.destination as? DetailsTableViewController else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let selectedItemCell = sender as? ItemTableViewCell else {
                fatalError("Unexpected sender: \(sender).")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedItem: Item
            
            if isFiltering() {
                selectedItem = filteredItems[indexPath.row]
            } else {
                selectedItem = items[indexPath.row]
            }
            
            detailsTableViewController.name = selectedItem.name
            detailsTableViewController.image = selectedItem.photo
        }
    }

    //MARK: Private methods
    
    private func loadSampleItems() {
        let photo1 = UIImage(named: "testImage")!
        
        guard let item1 = Item(name: "Coca-Cola", price: 3.50, photo: photo1, barcode: "00000000") else {
            fatalError("Unable to instantiate item1.")
        }
        
        items += [item1]
    }
    
    private func handleBarcodes(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNBarcodeObservation] else {
            fatalError("Unexpected result type from VNBarcodeRequest.")
        }
        guard observations.first != nil else {
            DispatchQueue.main.async {
                print("No barcode detected.")
            }
            return
        }
        
        for result in request.results! {
            if let barcode = result as? VNBarcodeObservation {
                barcodeValue = barcode.payloadStringValue!
                print("Barcode: \(barcodeValue!)")
            }
        }
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            print("Items successfully saved.")
        } else {
            fatalError("Failed to save items.")
        }
    }
    
    private func loadItems() -> [Item]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item]
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredItems = items.filter({(item: Item) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

//MARK: UISearchController

extension ItemTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
