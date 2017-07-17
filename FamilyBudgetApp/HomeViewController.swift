//
//  HomeViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletDelegate, WalletMemberDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var walletIDs : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        WalletObserver.sharedInstance().autoObserve = true
        WalletObserver.sharedInstance().startObserving()
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                
                self.walletIDs = [Resource.sharedInstance().currentUserId!]
                
                for wallet in  Resource.sharedInstance().userWallets.filter({ (_wallet) -> Bool in
                    return _wallet.value.memberTypes.contains(where: { (_member) -> Bool in
                    return _member.key == Resource.sharedInstance().currentUserId!
                    }) && !_wallet.value.isPersonal
                }) {
                    
                    self.walletIDs.append(wallet.key)
                    
                }
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Resource.sharedInstance().currentWalletID == nil {
            tableView.delegate = nil
            tableView.dataSource = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addWalletBtnAction(sender: UIButton) {
        
        guard let cont = self.storyboard?.instantiateViewController(withIdentifier: "newWallet") as? AddwalletViewController else {
            return
        }
        
        self.present(cont, animated: true, completion: nil)
        
    }
    
    @IBAction func backBtnAction(sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // TableView Delegate and Datasources
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Resource.sharedInstance().currentWalletID = walletIDs[indexPath.row]
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let this = Resource.sharedInstance().userWallets[walletIDs[indexPath.row]]

        let cell = tableView.dequeueReusableCell(withIdentifier: "showWallet") as! WalletTableViewCell
        
        cell.icon.layer.borderWidth = 2
        cell.icon.layer.cornerRadius = cell.icon.frame.width/2
        cell.icon.layer.borderColor = this!.color.cgColor
        cell.icon.clipsToBounds = true
        cell.icon.textColor = this!.color
        cell.selectionStyle = .none
        cell.membersCollectionView.tag = indexPath.row
        if cell.membersCollectionView.delegate == nil {
            cell.membersCollectionView.delegate = self
            cell.membersCollectionView.dataSource = self
        }
        else {
            cell.membersCollectionView.reloadData()
        }
        for view in cell.views {
            view.backgroundColor = this!.color
        }
        cell.ownerName.text = this?.creator.userName
        cell.ownerImage.image = this?.creator.image ?? (this?.creator.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))

        this?.creator.imageCallback = {
            image in
            cell.ownerImage.image = image
            
        }
        
        if this!.isPersonal {
            cell.membersCollectionView.isHidden = true
            cell.membersLabel.isHidden = true
        }
        else {
            cell.membersCollectionView.isHidden = false
            cell.membersLabel.isHidden = false
        }
        
        cell.icon.text = this?.icon
        cell.name.text = this?.name
        cell.balance.text = "\(this!.balance)"
        cell.income.text = "\(this!.totalIncome)"
        cell.expense.text = "\(this!.totalExpense)"
        
        return cell
    }
    
    // Collectionview Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let wallet = Resource.sharedInstance().userWallets[walletIDs[collectionView.tag]]
        return wallet!.memberTypes.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let wallet = Resource.sharedInstance().userWallets[walletIDs[collectionView.tag]]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "member", for: indexPath) as! ImageCollectionViewCell
        
        cell.memberImage.image = wallet?.members[indexPath.item].image ?? #imageLiteral(resourceName: "dp-male")
        cell.layer.cornerRadius = cell.frame.height/2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 15, height: 15)
    }
    
    // Wallet Delegate Methods
    
    func walletAdded(_ wallet: UserWallet) {
        
        if wallet.memberTypes[Resource.sharedInstance().currentUserId!] != nil {
            self.walletIDs.append(wallet.id)
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if walletIDs.contains(wallet.id) {
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        
        if wallet.memberTypes[Resource.sharedInstance().currentUserId!] != nil && !walletIDs.contains(wallet.id) {
            self.walletIDs.append(wallet.id)
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if wallet.memberTypes[Resource.sharedInstance().currentUserId!] == nil && walletIDs.contains(wallet.id) {
            
            walletIDs.remove(at: walletIDs.index(of: wallet.id)!)
            tableView.reloadSections([0], with: .automatic)
        }

    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if walletIDs.contains(wallet.id) {
            tableView.reloadSections([0], with: .automatic)
        }
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
