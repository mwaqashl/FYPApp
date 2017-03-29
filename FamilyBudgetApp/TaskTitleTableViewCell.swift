//
//  TaskTitleTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/28/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TaskTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitle: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
