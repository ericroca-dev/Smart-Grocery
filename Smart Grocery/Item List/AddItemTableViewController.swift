//
//  AddItemTableViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import CoreLocation

class AddItemTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    //MARK: Properties
    
    var firstPlaceholders = [String]()
    var secondPlaceholders = [String]()
    
    var categoryPicker: UIPickerView?
    var pickerData: [String] = [String]()
    var categoryTextField: UITextField?
    
    var locationManager: CLLocationManager?
    
    // This value is used to construct a new item
    var item: Item?
    var image: UIImage?
    var barcode: String?
    var location: [Double]?

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaceholders()
        loadPickerData()
        
        categoryPicker = UIPickerView()
        
        // Connect data
        self.categoryPicker?.delegate = self
        self.categoryPicker?.dataSource = self
        
        // Initial disabling of Done button
        doneButton.isEnabled = false
        
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return firstPlaceholders.count
        case 1:
            return secondPlaceholders.count
        default:
            return firstPlaceholders.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AddItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of AddItemTableViewCell.")
        }

        // Fetches the appropriate placeholder for the data source layout
        let placeholder: String
        
        switch (indexPath.section) {
        case 0:
            placeholder = firstPlaceholders[indexPath.row]
        case 1:
            placeholder = secondPlaceholders[indexPath.row]
        default:
            placeholder = firstPlaceholders[indexPath.row]
        }
        
        // Handle the text field's user input
        cell.textField.delegate = self
        
        // Disable graying when tapping
        cell.selectionStyle = .none
        
        cell.textField.placeholder = placeholder
        
        if (indexPath.section == 1) {
            cell.textField.inputView = categoryPicker
            categoryTextField = cell.textField
        }

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
        let categoryIndexPath = IndexPath(row: 0, section: 1)
        
        // Get text field cells
        let nameCell = tableView.cellForRow(at: nameIndexPath) as! AddItemTableViewCell
        let priceCell = tableView.cellForRow(at: priceIndexPath) as! AddItemTableViewCell
        let categoryCell = tableView.cellForRow(at: categoryIndexPath) as! AddItemTableViewCell
        
        let name = nameCell.textField.text ?? ""
        let priceString = priceCell.textField.text ?? ""
        let category = categoryCell.textField.text ?? ""
        
        // String to Double conversion does not work with comma
        let correctedPriceString = priceString.replacingOccurrences(of: ",", with: ".")
        
        let price = Double(correctedPriceString)
        
        item = Item(name: name, price: price!, category: category, photo: image!, barcode: barcode!, location: location!)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIPicker
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and column that is being passed
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField!.text = pickerData[row]
    }
    
    //MARK: Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            print("Current location: \(currentLocation)")
            location = [currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //MARK: Private Methods
    
    private func loadPlaceholders() {
        let namePlaceholder = "Name"
        let pricePlaceholder = "Price"
        let categoryPlaceholder = "Category"
        
        firstPlaceholders += [namePlaceholder, pricePlaceholder]
        secondPlaceholders += [categoryPlaceholder]
    }
    
    private func loadPickerData() {
        pickerData += ["Baby", "Beer, Wine & Spirits", "Beverages", "Bread & Bakery", "Breakfast & Cereal", "Canned Goods & Soups", "Condiments/Spices & Bake", "Cookies, Snacks & Candy", "Dairy, Eggs & Cheese", "Deli & Signature Cafe", "Flowers", "Frozen Foods", "Fruits & Vegetables", "Grains, Pasta & Sides", "International Cuisine", "Meat & Seafood", "Miscellaneous", "Paper Products", "Cleaning Supplies", "Health & Beauty, Personal Care & Pharmacy", "Pet Care", "Pharmacy", "Tobacco"]
    }
    
    private func updateDoneButtonState() {
        
        // Disable the Done button if any of the text fields are empty
        
        // Get text field positions
        let nameIndexPath = IndexPath(row: 0, section: 0)
        let priceIndexPath = IndexPath(row: 1, section: 0)
        let categoryIndexPath = IndexPath(row: 0, section: 1)
        
        // Get text field cells
        let nameCell = tableView.cellForRow(at: nameIndexPath) as! AddItemTableViewCell
        let priceCell = tableView.cellForRow(at: priceIndexPath) as! AddItemTableViewCell
        let categoryCell = tableView.cellForRow(at: categoryIndexPath) as! AddItemTableViewCell
        
        let name = nameCell.textField.text ?? ""
        let priceString = priceCell.textField.text ?? ""
        let category = categoryCell.textField.text ?? ""
        
        doneButton.isEnabled = !name.isEmpty && !category.isEmpty && !priceString.isEmpty
    }
}
