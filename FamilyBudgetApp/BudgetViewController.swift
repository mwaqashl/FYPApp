//
//  BudgetViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/6/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, WalletDelegate, WalletMemberDelegate, BudgetDelegate, BudgetMemberDelegate, BudgetCategoryDelegate, TransactionDelegate {

    @IBOutlet weak var segmentBtn: UISegmentedControl!
    @IBOutlet weak var tableview: UITableView!
    var add = UIBarButtonItem()
    var allWalletsBtn = UIBarButtonItem()
    
    var budgets = [Budget]()
    var filterBudget = [Budget]()
    var currentWalletTransactions = [Transaction]()
    var budgetAndRelatedTransactions = [String : [Transaction]]()
    
    var selectedrow = Int()
    var isDataAvailable = false
    var dateformat = DateFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        add = self.navigationItem.rightBarButtonItem!
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        tableview.dataSource = self
        tableview.delegate = self
        
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        Delegate.sharedInstance().addBudgetDelegate(self)
        Delegate.sharedInstance().addBudgetMemberDelegates(self)
        Delegate.sharedInstance().addBudgetCategoryDelegate(self)
        Delegate.sharedInstance().addTransactionDelegate(self)
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = bluethemecolor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.isDataAvailable = true
                self.ExtractBudget()
                self.ExtractTransactions()
                self.tableview.reloadData()
            }
        }
        
    }
    
    func allWalletsBtnTapped() {
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.present(cont, animated: true, completion: nil)
    }
    
    func ExtractBudget() {
        budgets = []
        filterBudget = []
        BudgetObserver.sharedInstance().startObserving(BudgetsOf: Resource.sharedInstance().currentWallet!)
        for key in Resource.sharedInstance().budgets.keys {
            let budget = Resource.sharedInstance().budgets[key]
            if budget!.walletID == Resource.sharedInstance().currentWalletID! {
                budgets.append(budget!)
                if budget!.isOpen && segmentBtn.selectedSegmentIndex == 0 {
                    filterBudget.append(budget!)
                }
                else if !budget!.isOpen && segmentBtn.selectedSegmentIndex == 1 {
                    filterBudget.append(budget!)
                }
            }
        }
    }
    
    func ExtractTransactions() {
        currentWalletTransactions = []
        for key in Resource.sharedInstance().transactions.keys {
            let transaction = Resource.sharedInstance().transactions[key]
            if transaction!.walletID == Resource.sharedInstance().currentWalletID {
                currentWalletTransactions.append(transaction!)
            }
        }
    }
    
    func abc(_ budget: Budget) -> Double {
        budgetAndRelatedTransactions[budget.id] = []
        var total = 0.0
        let members = budget.getMemberIDs()
        let categories = budget.getCategoryIDs()
        
        //End date validation not done
        
        for i in 0..<currentWalletTransactions.count {
                if categories.contains(currentWalletTransactions[i].categoryId) && currentWalletTransactions[i].date >= budget.startDate && members.contains(currentWalletTransactions[i].transactionById) {
                    print("\(i)")
                    total += currentWalletTransactions[i].amount
                    budgetAndRelatedTransactions[budget.id]!.append(currentWalletTransactions[i])
                }
            }
        return total
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            ExtractBudget()
            ExtractTransactions()
            tableview.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SegmentBtnAction(_ sender: Any) {
        filterBudget = []
        if segmentBtn.selectedSegmentIndex == 0 {
            for i in 0..<budgets.count {
                if budgets[i].isOpen {
                    filterBudget.append(budgets[i])
                }
            }
        }
        else {
            for i in 0..<budgets.count {
                if !budgets[i].isOpen {
                    filterBudget.append(budgets[i])
                }
            }
        }
        self.tableview.reloadData()
    }
    
    @IBAction func AddBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewBudget", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewBudget" {
            let destination = segue.destination as! AddBudgetViewController
            destination.isNew = true
        }
        else if segue.identifier == "BudgetDescription" {
            let destination = segue.destination as! AddBudgetViewController
            destination.budget = filterBudget[selectedrow]
            destination.transactions = budgetAndRelatedTransactions[filterBudget[selectedrow].id]!
            destination.isNew = false
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterBudget.count == 0 {
            let label = UILabel.init()
            label.text = "No Budget Available"
            label.textAlignment = .center
            self.tableview.backgroundView = label
        }
        else {
            self.tableview.backgroundView = nil
        }
        return filterBudget.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "BudgetCell") as! BudgetTableViewCell
        cell.AssignMembersCollectionView.dataSource = self
        cell.AssignMembersCollectionView.delegate = self
        let budget = filterBudget[indexPath.row]
        cell.AssignMembersCollectionView.tag = indexPath.row
        
        cell.BudgetTitle.text = budget.title
        cell.Icon.text = budget.categories[0].icon
        cell.TotalAmount.text = "\(budget.allocAmount)"
        cell.usedAmount.text = "\(abc(filterBudget[indexPath.row]))"
        cell.StartDate.text = dateformat.string(from: budget.startDate)
        cell.EndDate.text = dateformat.string(from: budget.startDate)
        
        cell.Icon.layer.borderWidth = 1
        cell.Icon.layer.borderColor = budget.categories[0].color.cgColor
        cell.Icon.textColor = budget.categories[0].color
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath.row
        performSegue(withIdentifier: "BudgetDescription", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let budget = filterBudget[collectionView.tag]
        return budget.members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
        let member = filterBudget[collectionView.tag].members[indexPath.item]
        cell.image.image = member.image != nil ? member.image : #imageLiteral(resourceName: "dp-male")
        cell.name.text = member.userName
        cell.selectedmember.isHidden = true
        return cell
    }

    //wallet Delegate
    func walletAdded(_ wallet: UserWallet) {
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            if wallet.isOpen {
                self.navigationItem.rightBarButtonItem = self.add
            }
            else if !wallet.isOpen {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.ExtractBudget()
            self.ExtractTransactions()
            self.tableview.reloadData()
        }
    }
    
    //wallet Member delegate
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
    
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            for i in 0..<budgets.count {
                if budgets[i].getMemberIDs().contains(member.getUserID()) {
                    budgets[i].removeMember(member.getUserID())
                }
            }
            for i in 0..<filterBudget.count {
                if filterBudget[i].getMemberIDs().contains(member.getUserID()) {
                    filterBudget[i].removeMember(member.getUserID())
                }
            }
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    
    //Budget Delegate
    func budgetAdded(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                budgets.append(budget)
                if budget.isOpen && segmentBtn.selectedSegmentIndex == 0 {
                    filterBudget.append(budget)
                }
                else if !budget.isOpen && segmentBtn.selectedSegmentIndex == 1 {
                    filterBudget.append(budget)
                }
                tableview.reloadData()
            }
        }
    }
    func budgetDeleted(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                self.ExtractBudget()
                tableview.reloadData()
            }
        }
    }
    func budgetUpdated(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                self.ExtractBudget()
                tableview.reloadData()
            }
        }
    }
    
    //BudgetMemberDelegate
    func memberLeft(_ member: User, budget: Budget) {
        
    }
    func memberAdded(_ member: User, budget: Budget) {
        
    }
    
    //BudgetCategory
    func categoryAdded(_ category: Category, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                
            }
        }
    }
    func categoryRemoved(_ category: Category, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                
            }
        }
    }
    
    //transaction delegates
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                currentWalletTransactions.append(transaction)
                self.tableview.reloadData()
            }
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                self.ExtractTransactions()
                self.tableview.reloadData()
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                self.ExtractTransactions()
                self.tableview.reloadData()
            }
        }
    }

    
    
    
    
}
