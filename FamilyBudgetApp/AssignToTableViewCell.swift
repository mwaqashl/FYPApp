//
//  AssignToTableViewCell.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AssignToTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var membersCollection: UICollectionView!
    @IBOutlet weak var addmemberBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
