//
//  SenderTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by PLEASE on 27/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class SenderTableViewCell: UITableViewCell {

    @IBOutlet weak var SendTime: UILabel!
    @IBOutlet weak var SenderMessage: UILabel!
    @IBOutlet weak var SenderName: UILabel!
    @IBOutlet weak var SenderDP: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
