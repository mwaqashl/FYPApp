//
//  AddMembersViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/28/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddMembersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, WalletMemberDelegate {

    var names = ["Huzaifa","Waqas","Zeeshan","Sumair","Azmul"]
    var type = ["Owner","member","Admin","member","member"]
    var walletMembers = [User]()
    var task : Task?
    
    var selectedRow : Int?
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        walletMembers = Resource.sharedInstance().currentWallet!.members
//        Delegate.sharedInstance().addWalletMemberDelegate(self)
        
        
        tableview.dataSource = self
        tableview.delegate = self

        // Oye observer agr pecha start ho chuka hai to yahan to nhn chalana na ?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "membersCell") as! WalletMembersTableViewCell
        cell.memberName.text = names[indexPath.row]
        cell.imageView!.image = #imageLiteral(resourceName: "persontemp")
        cell.type.text = type[indexPath.row]
        
//        if task!.memberIDs.contains(walletMembers[indexPath.row].getUserID()) {
//            cell.accessoryType = .checkmark
//        }
        
//        cell.memberType.text = Resource.sharedInstance().currentWallet!.memberTypes[walletMembers[indexPath.row].getUserID()] == .admin ? "Admin" 
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        task!.addMember(walletMembers[selectedRow!].getUserID())
        let cell = tableview.cellForRow(at: IndexPath(row: selectedRow!, section: 0)) as! WalletMembersTableViewCell
        cell.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        task!.removeMember(walletMembers[selectedRow!].getUserID())
        let cell = tableview.cellForRow(at: IndexPath(row: selectedRow!, section: 0)) as! WalletMembersTableViewCell
        cell.accessoryType = .none
    }
    
    //Wallet Members Delegates
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        
        if wallet.id == Resource.sharedInstance().currentWalletID {
            walletMembers.append(member)
        }
        tableview.reloadData()
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        
        for i in 0..<walletMembers.count {
            if walletMembers[i].getUserID() == member.getUserID() {
                walletMembers.remove(at: i)
                break
            }
        }
        tableview.reloadData()
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
