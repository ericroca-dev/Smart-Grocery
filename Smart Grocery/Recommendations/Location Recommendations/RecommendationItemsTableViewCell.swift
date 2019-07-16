//
//  RecommendationItemsTableViewCell.swift
//  Smart Grocery
//
//  Created by Eric Roca on 04/07/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class RecommendationsItemsTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
