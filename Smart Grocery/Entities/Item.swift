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
    var photo: UIImage
    var barcode: String
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let price = "price"
        static let photo = "photo"
        static let barcode = "barcode"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Initialization
    
    init?(name: String, price: Double, photo: UIImage, barcode: String) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The price must be positive
        guard price >= 0 else {
            return nil
        }
        
        guard !barcode.isEmpty else {
            return nil
        }
        
        self.name = name
        self.price = price
        self.photo = photo
        self.barcode = barcode
    }
    
    //MARK:NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(price, forKey: PropertyKey.price)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(barcode, forKey: PropertyKey.barcode)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            fatalError("Unable to decode the name for an Item object.")
        }
        let price = aDecoder.decodeDouble(forKey: PropertyKey.price)
        guard let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage else {
            fatalError("Unable to decode the photo for an Item object.")
        }
        guard let barcode = aDecoder.decodeObject(forKey: PropertyKey.barcode) as? String else {
            fatalError("Unable to decode the barcode for an Item object.")
        }
        
        self.init(name: name, price: price, photo: photo, barcode: barcode)
    }
}
