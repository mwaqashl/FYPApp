//
//  TaskTableViewCell.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var icon: UILabel!
    @IBOutlet weak var status: UIView!
    @IBOutlet weak var taskMembers: UICollectionView!
    @IBOutlet weak var assignTotag: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
