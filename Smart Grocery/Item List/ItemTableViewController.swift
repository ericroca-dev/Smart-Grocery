//
//  ItemTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import Vision
import FirebaseUI
import Firebase

class ItemTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, FUIAuthDelegate {
    
    //MARK: Properties
    
    var items = [Item]()
    var image: UIImage?
    var barcodeValue: String?
    
    var barcodePhotoTaken: Bool?
    var scanTaken: Bool?
    
    var scanItem: Bool?
    var scanPhotoTaken: Bool?
    var scanCompleted: Bool?
    
    var filteredItems = [Item]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var barcodeRequest: VNDetectBarcodesRequest = {
        return VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
    }()
    
    var storage: Storage?
    var storageRef: StorageReference?
    var db: Firestore?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentFirebaseUI()
        
        scanTaken = false
        scanItem = false
        scanPhotoTaken = false
        scanCompleted = false
        
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
        
        // Get a reference to the storage service using the default Firebase App
        storage = Storage.storage()
        
        // Create a storage reference from our storage service
        storageRef = storage!.reference()
        
        // Firebase Cloud Firestore initialization
        db = Firestore.firestore()
        
        /*
        for item in items {
            // Add a new document with a generated ID
            var ref: DocumentReference? = nil
            
            // Convert prices to String
            var stringPrices: [String] = [String]()
            for price in item.prices {
                stringPrices.append(String(price))
            }
            
            // Convert locations to String
            var stringLocations: [[String]] = [[String]]()
            for location in item.locations {
                stringLocations.append([String(location.latitude), String(location.longitude)])
            }
            
            // Create a reference to the file you want to upload
            let photoRef = storageRef!.child("images/\(item.name).jpg")
            
            var imageURL = String()
            
//            // Upload the file to the path "images/rivers.jpg"
//            let uploadTask = photoRef.putData(item.photo.pngData()!, metadata: nil) { (metadata, error) in
//                guard let metadata = metadata else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//                // Metadata contains file metadata such as size, content-type.
//                let size = metadata.size
//                // You can also access to download URL after upload.
//                photoRef.downloadURL { (url, error) in
//                    guard let downloadURL = url else {
//                        // Uh-oh, an error occurred!
//                        return
//                    }
//                    imageURL = downloadURL.absoluteString
//
//                    // Build document data
//                    let documentData: [String: Any] = [
//                        "name": item.name,
//                        "prices": stringPrices,
//                        "category": item.category,
//                        "image": imageURL,
//                        "barcode": item.barcode,
//                        "locations": [String(item.locations[0].latitude), String(item.locations[0].longitude)]
//                    ]
//
//                    ref = db.collection("products").addDocument(data: documentData) { err in
//                        if let err = err {
//                            print("Error adding document: \(err)")
//                        } else {
//                            print("Document added with ID: \(ref!.documentID)")
//                        }
//                    }
//                }
//            }
        }
        */
    
        // loadSampleItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load FCS items
        loadItemsFromFirestore()
        
        // 1
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.items, toFile: Item.ArchiveURL.path)
            
            if isSuccessfulSave {
                print("Items successfully saved.")
            } else {
                fatalError("Failed to save items.")
            }
        }
        
        tableView.reloadData()
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
            items.remove(at: indexPath.row)
            saveItems()
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
    
    // MARK: - FirebaseUI
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // Handle user returning from authenticating
    }
    
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
            self.barcodeValue = nil
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
            saveToFirestore(item: item)
            barcodePhotoTaken = nil
            scanPhotoTaken = false
            barcodeValue = nil
        }
        
        saveItems()
    }
    
    //MARK: Photo Taking
    
    func takeScan() {
        scanItem = true;
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
        
        let alertController: UIAlertController
        
        if (!scanPhotoTaken!) {
            alertController = UIAlertController(title: "Scan Barcode", message: "Take a close-up photo of the item's barcode.", preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: "No Barcode Found", message: "Try taking a closer or further photo of the barcode.", preferredStyle: .alert)
        }
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            self.dismiss(animated: true)
            self.scanPhotoTaken = false
            self.scanItem = false
            self.barcodeValue = nil
            self.scanCompleted = false
        }
        alertController.addAction(cancelAction)
        
        imagePicker.present(alertController, animated: true, completion: nil)
    }
    
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
            self.barcodeValue = nil
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
        
        if scanItem == true {
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
                if self.barcodeValue == nil {
                    self.scanPhotoTaken = true
                    self.self.takeScan()
                } else {
                    self.scanCompleted = true
                    self.performSegue(withIdentifier: "ShowScanDetails", sender: self)
                }
            })
        } else {
            
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
        }
        
        
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
                    barcodeValue = nil
                    barcodePhotoTaken = nil
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
            detailsTableViewController.category = selectedItem.category
            detailsTableViewController.prices = selectedItem.prices
            detailsTableViewController.locations = selectedItem.locations
            detailsTableViewController.barcode = selectedItem.barcode
            detailsTableViewController.items = self.items
            detailsTableViewController.item = selectedItem
        } else if segue.identifier == "ShowScanDetails" {
            if !scanCompleted! {
                scanPhotoTaken = false
                takeScan()
            } else {
                scanPhotoTaken = false
                scanCompleted = false
            }
            
            let selectedItem: Item?
            selectedItem = items.first(where: {$0.barcode == barcodeValue})
            barcodeValue = nil
            
            if selectedItem == nil {
                let alertController: UIAlertController
                
                alertController = UIAlertController(title: "No Product Found", message: "No such product exists in the database.", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                }
                alertController.addAction(OKAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                guard let detailsTableViewController = segue.destination as? DetailsTableViewController else {
                    fatalError("Unexpected destination: \(segue.destination).")
                }
                
                detailsTableViewController.name = selectedItem?.name
                detailsTableViewController.image = selectedItem?.photo
                detailsTableViewController.category = selectedItem?.category
                detailsTableViewController.prices = selectedItem?.prices
                detailsTableViewController.locations = selectedItem?.locations
                detailsTableViewController.barcode = selectedItem?.barcode
                detailsTableViewController.items = self.items
                detailsTableViewController.item = selectedItem
            }
        }
    }

    //MARK: Private methods
    
//    private func loadSampleItems() {
//        let photo1 = UIImage(named: "testImage")!
//
//        guard let item1 = Item(name: "Coca-Cola", price: 3.50, category: "Beverage", photo: photo1, barcode: "00000000") else {
//            fatalError("Unable to instantiate item1.")
//        }
//
//        items += [item1]
//    }
    
    private func loadItemsFromFirestore() {
        var objFetched = 0
        db!.collection("products").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let checkedItem = self.items.first(where: {$0.name == document.get("name") as! String})
                    
                    // Check prices
                    var checkedPrices = [Double]()
                    let stringCheckedPrices = document.get("prices") as! [String]
                    for checkedPrice in stringCheckedPrices {
                        checkedPrices.append(Double(checkedPrice) as! Double)
                    }
                    
                    // Check locations
                    var checkedLocations = [Location]()
                    let stringCheckedLocations = document.get("locations") as! [String]
                    let sequence = stride(from: 0, to: stringCheckedLocations.count, by: 2)
                    for index in sequence {
                        var location = Location(latitude: Double(stringCheckedLocations[index]) as! Double, longitude: Double(stringCheckedLocations[index + 1]) as! Double)
                        checkedLocations.append(location!)
                    }
                    
                    let checkedLocationItem = self.items.first(where: {$0.locations == checkedLocations})

                    if checkedItem == nil {
                        // Create a reference to the file you want to download
                        let photoRef = self.storageRef!.child("images/\(document.get("name") as! String).jpg")
                        print("PhotoRef: \(photoRef)")
                        photoRef.getData(maxSize: (30 * 1024 * 1024)) { (data, error) in
                            if let _error = error{
                                print(_error)
                            } else {
                                if let _data  = data {
                                    // Download image from Firebase Storage
                                    let image = UIImage(data: _data)
                                    print("Image downloaded")
                                    
                                    // Get locations
                                    var locations = [Location]()
                                    let stringLocations = document.get("locations") as! [String]
                                    let sequence = stride(from: 0, to: stringLocations.count, by: 2)
                                    for index in sequence {
                                        var location = Location(latitude: Double(stringLocations[index]) as! Double, longitude: Double(stringLocations[index + 1]) as! Double)
                                        locations.append(location!)
                                    }
                                    
                                    // Get prices
                                    var prices = [Double]()
                                    let stringPrices = document.get("prices") as! [String]
                                    for price in stringPrices {
                                        prices.append(Double(price) as! Double)
                                    }
                                    
                                    var item = Item(name: document.get("name") as! String, prices: prices, category: document.get("category") as! String, photo: image!, barcode: document.get("barcode") as! String, locations: locations)
                                    
                                    print("Item: \(item!.name)")
                                    self.items.append(item!)
                                    
                                    self.tableView.reloadData()
                                    
                                    objFetched += 1
                                    
                                    if objFetched == self.items.count {
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    } else if checkedItem != checkedLocationItem {
                        let index = self.items.firstIndex(of: checkedItem!)
                        self.items[index!].prices = checkedPrices
                        self.items[index!].locations = checkedLocations
                    }
                }
            }
        }
    }
    
    private func saveToFirestore(item: Item) {
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        
        // Convert prices to String
        var stringPrices: [String] = [String]()
        for price in item.prices {
            stringPrices.append(String(price))
        }
        
        // Convert locations to String
        var stringLocations: [[String]] = [[String]]()
        for location in item.locations {
            stringLocations.append([String(location.latitude), String(location.longitude)])
        }
        
        // Create a reference to the file you want to upload
        let photoRef = self.storageRef!.child("images/\(item.name).jpg")
        
        var imageURL = String()
        
        // Upload the file to the path
        let uploadTask = photoRef.putData(item.photo.pngData()!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            photoRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                imageURL = downloadURL.absoluteString
                
                // Build document data
                let documentData: [String: Any] = [
                    "name": item.name,
                    "prices": stringPrices,
                    "category": item.category,
                    "image": imageURL,
                    "barcode": item.barcode,
                    "locations": [String(item.locations[0].latitude), String(item.locations[0].longitude)]
                ]
                
                ref = self.db!.collection("products").addDocument(data: documentData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }
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
    
    private func presentFirebaseUI() {
        if Auth.auth().currentUser == nil {
            let authUI = FUIAuth.defaultAuthUI()
            authUI?.delegate = self
            let providers: [FUIAuthProvider] = [
                FUIEmailAuth(),
            ]
            
            authUI?.providers = providers
            let authViewController = authUI!.authViewController()
            self.present(authViewController, animated: true, completion: nil)
        }
    }
}

//MARK: UISearchController

extension ItemTableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
