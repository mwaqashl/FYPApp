//
//  TransactionByTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 4/1/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TransactionByTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var personimage: UIImageView!
    @IBOutlet weak var name: UILabel!
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
