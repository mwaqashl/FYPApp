//
//  BudgetStatsTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/7/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class BudgetStatsTableViewCell: UITableViewCell {


    
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var PieChartView: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
