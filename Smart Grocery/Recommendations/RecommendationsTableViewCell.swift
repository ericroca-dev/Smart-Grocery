//
//  RecommendationsTableViewCell.swift
//  Smart Grocery
//
//  Created by Eric Roca on 04/07/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class RecommendationsTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
