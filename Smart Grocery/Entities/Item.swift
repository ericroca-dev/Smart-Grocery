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
    
    private var name: String
    private var price: Double
    private var photo: UIImage
    
    //MARK: Initialization
    
    init?(name: String, price: Double, photo: UIImage) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The price must be positive
        guard price >= 0 else {
            return nil
        }
        
        self.name = name
        self.price = price
        self.photo = photo
    }
}
