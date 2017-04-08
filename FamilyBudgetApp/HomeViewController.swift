//
//  HomeViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WalletDelegate {

    var walletIDs : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Delegate.sharedInstance().addWalletDelegate(self)
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
                
                print(self.walletIDs)
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if defaultSettings.value(forKey: "homeTutorials") == nil {
            
            let cont = UIStoryboard(name: "Tutorials", bundle: nil).instantiateInitialViewController() as! TutorialViewController
            
            cont.tutorialType = TutorialType.wallets
            defaultSettings.setValue(true, forKey: "homeTutorials")

            self.present(cont, animated: true, completion: nil)
            
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
        for view in cell.views {
            view.backgroundColor = this!.color
        }
        cell.ownerName.text = this?.creator.userName
        this?.creator.getImage({ (data) in
            cell.ownerImage.image = UIImage(data: data) ?? #imageLiteral(resourceName: "persontemp")
        })
        
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
        cell.membersCollectionView.tag = indexPath.row
//        cell.membersCollectionView.delegate = self
        //        cell.membersCollectionView.dataSource = self
        cell.balance.text = "\(this!.balance)"
        cell.income.text = "\(this!.totalIncome)"
        cell.expense.text = "\(this!.totalExpense)"
        
        return cell
    }
    
    
    // Wallet Delegate Methods
    
    func walletAdded(_ wallet: UserWallet) {
        
        if !walletIDs.contains(wallet.id) {
            self.walletIDs.append(wallet.id)
            tableView.reloadData()
        }
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if walletIDs.contains(wallet.id) {
            tableView.reloadData()
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        
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
