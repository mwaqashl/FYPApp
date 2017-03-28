//
//  HomeViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    var walletIDs : [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                
                self.walletIDs = Array(Resource.sharedInstance().userWallets.keys)
                print(self.walletIDs)
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                
            }
            
        }
        
        self.navigationItem.title = "All Wallets"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView Delegate and Datasources
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let this = Resource.sharedInstance().userWallets[walletIDs[indexPath.row]]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "showWallet") as! WalletTableViewCell
        
        cell.icon.layer.borderWidth = 2
        cell.icon.layer.cornerRadius = cell.icon.frame.width/2
        cell.icon.layer.borderColor = this!.color.cgColor
        cell.icon.clipsToBounds = true
        cell.icon.textColor = this!.color
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.clipsToBounds = true
        
        for view in cell.views {
            view.backgroundColor = this!.color
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
