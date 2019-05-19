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
    var prices: [Double]
    var category: String
    var photo: UIImage
    var barcode: String
    var locations: [Location] = [Location]()
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let prices = "prices"
        static let category = "category"
        static let photo = "photo"
        static let barcode = "barcode"
        static let locations = "locations"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Initialization
    
    init?(name: String, prices: [Double], category: String, photo: UIImage, barcode: String, locations: [Location]) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The prices must not be empty
        guard !prices.isEmpty else {
            return nil
        }
        
        // The prices must be positive
        for price in prices {
            guard price >= 0 else {
                return nil
            }
        }
        
        // The category must not be empty
        guard !category.isEmpty else {
            return nil
        }
        
        // The barcode must not be empty
        guard !barcode.isEmpty else {
            return nil
        }
        
        // The locations must not be empty
        guard !locations.isEmpty else {
            return nil
        }
        
        self.name = name
        self.prices = prices
        self.category = category
        self.photo = photo
        self.barcode = barcode
        self.locations = locations
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(prices, forKey: PropertyKey.prices)
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(barcode, forKey: PropertyKey.barcode)
        aCoder.encode(locations, forKey: PropertyKey.locations)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            fatalError("Unable to decode the name for an Item object.")
        }
        guard let prices = aDecoder.decodeObject(forKey: PropertyKey.prices) as? [Double] else {
            fatalError("Unable to decode the prices for an Item object.")
        }
        guard let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage else {
            fatalError("Unable to decode the photo for an Item object.")
        }
        guard let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String else {
            fatalError("Unable to decode the category for an Item object.")
        }
        guard let barcode = aDecoder.decodeObject(forKey: PropertyKey.barcode) as? String else {
            fatalError("Unable to decode the barcode for an Item object.")
        }
        guard let locations = aDecoder.decodeObject(forKey: PropertyKey.locations) as? [Location] else {
            fatalError("Unable to decode the locations for an Item object.")
        }
        
        self.init(name: name, prices: prices, category: category, photo: photo, barcode: barcode, locations: locations)
    }
}
