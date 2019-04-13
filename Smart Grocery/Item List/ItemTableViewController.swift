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
    
    lazy var barcodeRequest: VNDetectBarcodesRequest = {
        return VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
    }()

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
}
