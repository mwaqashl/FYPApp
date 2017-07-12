//
//  BalanceAmountTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 7/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class BalanceAmountTableViewCell: UITableViewCell {

    
    @IBOutlet weak var BalanceHeader: UILabel!
    @IBOutlet weak var BalanceAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
