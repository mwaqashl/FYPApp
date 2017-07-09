//
//  TimelineTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {

    
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var categoryIcon: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
