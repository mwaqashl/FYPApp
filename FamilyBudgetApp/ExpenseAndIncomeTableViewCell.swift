//
//  ExpenseAndIncomeTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 7/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ExpenseAndIncomeTableViewCell: UITableViewCell {

    @IBOutlet weak var IncomeHeader: UILabel!
    @IBOutlet weak var IncomeAmunt: UILabel!
    @IBOutlet weak var IncomeExpandBtn: UIButton!
    
    @IBOutlet weak var ExpenseHeader: UILabel!
    @IBOutlet weak var ExpenseAmount: UILabel!
    @IBOutlet weak var ExpenseBtn: UIButton!
    
    @IBOutlet var detailIndicators: [UILabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
