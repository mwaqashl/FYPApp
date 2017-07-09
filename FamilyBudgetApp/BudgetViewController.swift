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
    
    var allWalletsBtn = UIBarButtonItem()
    
    var budgets = [Budget]()
    var filterBudget = [Budget]()
    var currentWalletTransactions = [Transaction]()
    var budgetAndRelatedTransactions = [String : [Transaction]]()
    
    var selectedrow = Int()
    var isDataAvailable = false
    var dateformat = DateFormatter()
    @IBOutlet weak var AddBudgetBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        allWalletsBtn.tintColor = darkGreenThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        self.tabBarController?.tabBar.barTintColor = .white

        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.tabBarController!.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController!.tabBar.selectedImageTintColor = darkGreenThemeColor
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                
                if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && Resource.sharedInstance().currentWallet!.isOpen {
                    self.AddBudgetBtn.isHidden = false
                }
                else {
                    self.AddBudgetBtn.isHidden = true
                }
                self.isDataAvailable = true
                self.ExtractBudget()
                self.ExtractTransactions()
                self.tableview.reloadData()
            }
        }
        
    }
    
    func getAmountwithCurrency(Amount : Double , of size : CGFloat) -> NSMutableAttributedString {
        
        let font = UIFont(name: "untitled-font-25", size: size)!
        
        let wallet = Resource.sharedInstance().currentWallet!.currency.icon
        
        
        let CurrIcon = NSAttributedString(string: wallet, attributes: [NSFontAttributeName : font])
        let amount = NSAttributedString(string: "\(Amount)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: size)])
        
        let str = NSMutableAttributedString()
        str.append(CurrIcon)
        str.append(amount)
        
        return str
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
    
    func BudgetRelatedTransaction(_ budget: Budget) -> Double {
        budgetAndRelatedTransactions[budget.id] = []
        var total = 0.0
        let members = budget.getMemberIDs()
        let categories = budget.getCategoryIDs()
        
        //End date validation not done
        
        for i in 0..<currentWalletTransactions.count {
                if categories.contains(currentWalletTransactions[i].categoryId) && currentWalletTransactions[i].date >= budget.startDate && members.contains(currentWalletTransactions[i].transactionById) {
                    total += currentWalletTransactions[i].amount
                    budgetAndRelatedTransactions[budget.id]!.append(currentWalletTransactions[i])
                }
            }
        return total
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isDataAvailable {
            
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = darkGreenThemeColor
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            
            if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && Resource.sharedInstance().currentWallet!.isOpen {
                self.AddBudgetBtn.isHidden = false
            }
            else {
                self.AddBudgetBtn.isHidden = true
            }
            
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
    
    @IBAction func AddBudgetBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "NewBudget", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewBudget" {
            let destination = segue.destination as! AddBudgetViewController
            destination.isNew = true
        }
        else if segue.identifier == "BudgetDescription" {
            let destination = segue.destination as! BudgetDetailsViewController
            destination.budget = filterBudget[selectedrow]
            destination.transactions = budgetAndRelatedTransactions[filterBudget[selectedrow].id]!
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
        cell.Icon.text = budget.categories.first?.icon ?? ""
        cell.TotalAmount.attributedText = getAmountwithCurrency(Amount: budget.allocAmount, of: cell.TotalAmount.font.pointSize)
        
        cell.usedAmount.attributedText = getAmountwithCurrency(Amount: BudgetRelatedTransaction(budget), of: cell.usedAmount.font.pointSize)
        
        cell.StartDate.text = dateformat.string(from: budget.startDate)
        cell.EndDate.text = dateformat.string(from: budget.startDate.addingTimeInterval(Double(24*60*60*budget.daysInbudget())))
        cell.Icon.layer.cornerRadius = cell.Icon.frame.width / 2
        cell.Icon.layer.borderWidth = 1
        cell.Icon.layer.borderColor = budget.categories.first?.color.cgColor
        cell.Icon.textColor = budget.categories.first?.color
        
        cell.BalanceAmount.attributedText = getAmountwithCurrency(Amount: budget.allocAmount - BudgetRelatedTransaction(budget), of: cell.BalanceAmount.font.pointSize)
        
        cell.Status.frame.size.width = CGFloat(BudgetRelatedTransaction(budget)/budget.allocAmount)*cell.defaultstatusbar.frame.width
        
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
                self.AddBudgetBtn.isHidden = false
                
            }
            else if !wallet.isOpen {
                self.AddBudgetBtn.isHidden = true
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
        if budget.walletID == Resource.sharedInstance().currentWalletID {
            self.ExtractBudget()
            tableview.reloadData()
        }
    }
    func memberAdded(_ member: User, budget: Budget) {
        if budget.walletID == Resource.sharedInstance().currentWalletID {
            self.ExtractBudget()
            tableview.reloadData()
        }
    }
    
    //BudgetCategory
    func categoryAdded(_ category: Category, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                tableview.reloadData()
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
