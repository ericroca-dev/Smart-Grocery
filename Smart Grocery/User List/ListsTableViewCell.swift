//
//  ListsTableViewCell.swift
//  Smart Grocery
//
//  Created by Eric Roca on 01/06/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit

class ListsTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var listLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
