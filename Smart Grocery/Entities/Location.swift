//
//  File.swift
//  Smart Grocery
//
//  Created by Eric Roca on 19/05/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class Location: NSObject, NSCoding {
    
    //MARK: Properties
    
    var latitude: Double
    var longitude: Double
    
    //MARK: Types
    
    struct PropertyKey {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("locations")
    
    init?(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(latitude, forKey: PropertyKey.latitude)
        aCoder.encode(longitude, forKey: PropertyKey.longitude)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude)
        
        self.init(latitude: latitude, longitude: longitude)
    }
}
