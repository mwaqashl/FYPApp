//
//  ReceiverTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by PLEASE on 27/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ReceiverTableViewCell: UITableViewCell {

    @IBOutlet weak var ReceivedTime: UILabel!
    @IBOutlet weak var ReceivedMessage: UILabel!
    @IBOutlet weak var ReceivedName: UILabel!
    @IBOutlet weak var ReceivedDP: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
