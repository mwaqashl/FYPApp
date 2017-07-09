//
//  WalletMembersTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/28/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class WalletMembersTableViewCell: UITableViewCell {

    
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var type: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
