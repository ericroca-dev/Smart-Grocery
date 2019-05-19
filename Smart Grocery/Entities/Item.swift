//
//  Item.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class Item: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var price: Double
    var category: String
    var photo: UIImage
    var barcode: String
    var location: [Double] = [Double]()
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let price = "price"
        static let category = "category"
        static let photo = "photo"
        static let barcode = "barcode"
        static let location = "location"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Initialization
    
    init?(name: String, price: Double, category: String, photo: UIImage, barcode: String, location: [Double]) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The price must be positive
        guard price >= 0 else {
            return nil
        }
        
        // The category must not be empty
        guard !category.isEmpty else {
            return nil
        }
        
        // The barcode must not be empty
        guard !barcode.isEmpty else {
            return nil
        }
        
        // The location must not be empty
        guard !location.isEmpty else {
            return nil
        }
        
        self.name = name
        self.price = price
        self.category = category
        self.photo = photo
        self.barcode = barcode
        self.location = location
    }
    
    //MARK:NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(price, forKey: PropertyKey.price)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(barcode, forKey: PropertyKey.barcode)
        aCoder.encode(location, forKey: PropertyKey.location)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            fatalError("Unable to decode the name for an Item object.")
        }
        let price = aDecoder.decodeDouble(forKey: PropertyKey.price)
        guard let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage else {
            fatalError("Unable to decode the photo for an Item object.")
        }
        guard let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String else {
            fatalError("Unable to decode the category for an Item object.")
        }
        guard let barcode = aDecoder.decodeObject(forKey: PropertyKey.barcode) as? String else {
            fatalError("Unable to decode the barcode for an Item object.")
        }
        guard let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? [Double] else {
            fatalError("Unable to decode the location for an Item object.")
        }
        
        self.init(name: name, price: price, category: category, photo: photo, barcode: barcode, location: location)
    }
}
