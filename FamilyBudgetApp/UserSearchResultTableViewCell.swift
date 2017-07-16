//
//  UserSearchResultTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 03/04/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class UserSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var memberType: UILabel!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var adminBtn: UIButton!
    @IBOutlet weak var removeMemberBtn: UIButton!
    
    var removeMemberAction = {
        
    }
    
    var adminBtnAction = {
        
    }
    
    @IBAction func removeMemberBtnAction(_ sender: Any) {
        
        removeMemberAction()
        
    }
    @IBAction func adminBtnAction(_ sender: UIButton) {
        
        adminBtnAction()
        
        if memberType.text == "Admin" {
            sender.setImage(#imageLiteral(resourceName: "removeAdmin"), for: .normal)
        }
        else {
            sender.setImage(#imageLiteral(resourceName: "makeAdmin"), for: .normal)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        memberType.layer.cornerRadius = memberType.frame.height/2
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
