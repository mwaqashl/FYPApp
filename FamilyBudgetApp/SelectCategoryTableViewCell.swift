//
//  SelectCategoryTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/25/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class SelectCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var CategoryIcon: UILabel!
    @IBOutlet weak var CategoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
