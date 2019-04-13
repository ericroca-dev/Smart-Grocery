//
//  Item.swift
//  Smart Grocery
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class Item {
    
    //MARK: Properties
    
    var name: String
    var price: Double
    var photo: UIImage
    var barcode: String
    
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
}
