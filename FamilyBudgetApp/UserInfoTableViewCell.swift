//
//  UserInfoTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by Waqas on 11/07/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userdp: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
