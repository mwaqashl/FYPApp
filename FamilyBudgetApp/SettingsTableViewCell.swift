//
//  SettingsTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 6/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class WalletInfoCell: UITableViewCell {

    @IBOutlet weak var icon: UILabel!
    @IBOutlet weak var settingName: UILabel!
    @IBOutlet var borderLine: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SettingsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var settingName: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

