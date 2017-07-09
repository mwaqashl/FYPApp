//
//  BudgetTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/6/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Icon: UILabel!
    @IBOutlet weak var BudgetTitle: UILabel!
    @IBOutlet weak var Status: UIView!
    @IBOutlet weak var TotalAmount: UILabel!
    @IBOutlet weak var usedAmount: UILabel!
    @IBOutlet weak var StartDate: UILabel!
    @IBOutlet weak var EndDate: UILabel!
    @IBOutlet weak var AssignMembersCollectionView: UICollectionView!
    
    @IBOutlet weak var defaultstatusbar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
