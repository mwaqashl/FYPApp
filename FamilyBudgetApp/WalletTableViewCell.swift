//
//  WalletTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 28/03/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var income: UILabel!
    @IBOutlet weak var expense: UILabel!
    
    @IBOutlet weak var ownerImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet var views: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
