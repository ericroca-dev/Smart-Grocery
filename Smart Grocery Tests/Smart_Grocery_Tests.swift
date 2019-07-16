//
//  Smart_Grocery_Tests.swift
//  Smart Grocery Tests
//
//  Created by Eric Roca on 07/04/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import XCTest
@testable import Smart_Grocery

class Smart_Grocery_Tests: XCTestCase {

    //MARK: Item Class Tests
    
    // Confirm that the Item initializer returns an Item object when passed valid parameters
    func testItemInitializationSucceeds() {
        let testPhoto = UIImage(named: "testImage")
        
        // Zero price
        let zeroPriceItem = Item.init(name: "Zero", prices: [0.0], category: "Zero", photo: testPhoto!, barcode: "0", locations: [Location.init(0.0, 0.0)])
        XCTAssertNotNil(zeroPriceItem)
        
        // Positive price
        let positivePriceItem = Item.init(name: "Positive", prices: [10.0], category: "Positive", photo: testPhoto!, barcode: "0", locations: [Location.init(0.0, 0.0)])
        XCTAssertNotNil(positivePriceItem)
    }
    
    // Confirm that the Item initializer returns nil when passed invalid parameters
    func testItemInitializationFails() {
        
        let testPhoto = UIImage(named: "testImage")
        
        // Empty name
        let emptyNameItem = Item.init(name: "", prices: [0.0], category: "Empty", photo: testPhoto!, barcode: "0", locations: [Location.init(0.0, 0.0)])
        XCTAssertNil(emptyNameItem)
        
        // Negative price
        let negativePriceItem = Item.init(name: "Negative", prices: [-1.0], category: "Negative", photo: testPhoto!, barcode: "0", locations: [Location.init(0.0, 0.0)])
        XCTAssertNil(negativePriceItem)
        
        // Empty category
        let emptyCategoryItem = Item.init(name: "Empty", prices: [0.0], category: "", photo: testPhoto!, barcode: "0", locations: [Location.init(0.0, 0.0)])
        XCTAssertNil(emptyCategoryItem)
        
        // Empty barcode
        let emptyBarcodeItem = Item.init(name: "Empty", prices: [0.0], category: "Empty", photo: testPhoto!, barcode: "", locations: [Location.init(0.0, 0.0)])
        XCTAssertNil(emptyBarcodeItem)
    }
}
