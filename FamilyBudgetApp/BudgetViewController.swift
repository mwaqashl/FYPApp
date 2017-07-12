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
    var SettingsBtn = UIBarButtonItem()

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
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn

        SettingsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.SettingsBtnTapped))
        SettingsBtn.tintColor = darkGreenThemeColor
        
        self.navigationItem.rightBarButtonItem = SettingsBtn
        
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.tabBarController!.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController!.tabBar.selectedImageTintColor = darkThemeColor
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                
                if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && Resource.sharedInstance().currentWallet!.isOpen {
                    self.AddBudgetBtn.isHidden = false
                }
                else if Resource.sharedInstance().currentWallet!.isPersonal {
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
    
    func SettingsBtnTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
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
        let endDate = budget.startDate.addingTimeInterval(Double(budget.daysInbudget()*24*60*60))
        //End date validation not done
//         && currentWalletTransactions[i].date <= budget.startDate.addTimeInterval(Double(budget.period*24*60*60))
        for i in 0..<currentWalletTransactions.count {
                if categories.contains(currentWalletTransactions[i].categoryId) && currentWalletTransactions[i].date >= budget.startDate && currentWalletTransactions[i].date < endDate && members.contains(currentWalletTransactions[i].transactionById) {
                    total += currentWalletTransactions[i].amount
                    budgetAndRelatedTransactions[budget.id]!.append(currentWalletTransactions[i])
                }
            }
        return total
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isDataAvailable {
            
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            
            if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && Resource.sharedInstance().currentWallet!.isOpen {
                self.AddBudgetBtn.isHidden = false
            }
            else if Resource.sharedInstance().currentWallet!.isPersonal {
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
        
        cell.AssignMembersCollectionView.reloadData()
        
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
        
        cell.Status.backgroundColor = BudgetRelatedTransaction(budget)/budget.allocAmount >= 0.75 ? .red : darkThemeColor
        
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
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func updateBudgetsArray(budget : Budget){
        for i in 0..<budgets.count {
            if budgets[i].id == budget.id {
                budgets[i] = budget
                break
            }
        }
        
        if budget.isOpen && segmentBtn.selectedSegmentIndex == 0 {
            for i in 0..<filterBudget.count {
                if filterBudget[i].id == budget.id {
                    filterBudget[i] = budget
                    break
                }
            }
            self.tableview.reloadSections([0], with: .automatic)
        }
            
        else if !budget.isOpen && segmentBtn.selectedSegmentIndex == 1 {
            for i in 0..<filterBudget.count {
                if filterBudget[i].id == budget.id {
                    filterBudget[i] = budget
                    break
                }
            }
            self.tableview.reloadSections([0], with: .automatic)
        }
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
        if isDataAvailable {
            if wallet.id == Resource.sharedInstance().currentWalletID {
                for i in 0..<budgets.count {
                    if budgets[i].getMemberIDs().contains(member.getUserID()) {
                        budgets[i].removeMember(member.getUserID())
                        BudgetManager.sharedInstance().addMembersToBudget(budgets[i].id, members: budgets[i].getMemberIDs())
                    }
                }
            }
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if isDataAvailable {
            if Resource.sharedInstance().currentWallet!.members.contains(where: { (_user) -> Bool in
                return _user.getUserID() == member.getUserID()
            }){
                if ofType == .admin || ofType == .owner {
                    self.AddBudgetBtn.isHidden = false
                }
                else{
                    self.AddBudgetBtn.isHidden = true
                }
            }
        }
    }
    
    //Budget Delegate
    func budgetAdded(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                if !budgets.contains(where: { (_budget) -> Bool in
                    return _budget.id == budget.id
                }){
                    budgets.append(budget)
                }
                if budget.isOpen && segmentBtn.selectedSegmentIndex == 0 {
                    if !filterBudget.contains(where: { (_budget) -> Bool in
                        return _budget.id == budget.id
                    }){
                        filterBudget.append(budget)
                        tableview.reloadData()
                    }
                }
                else if !budget.isOpen && segmentBtn.selectedSegmentIndex == 1 {
                    if !filterBudget.contains(where: { (_budget) -> Bool in
                        return _budget.id == budget.id
                    }){
                        filterBudget.append(budget)
                        tableview.reloadData()
                    }
                }
            }
        }
    }
    
    func budgetDeleted(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                for i in 0..<budgets.count {
                    if budgets[i].id == budget.id {
                        budgets.remove(at: i)
                        break
                    }
                }
                if budget.isOpen && segmentBtn.selectedSegmentIndex == 0 {
                    for i in 0..<filterBudget.count {
                        if filterBudget[i].id == budget.id {
                            filterBudget.remove(at: i)
                            break
                        }
                    }
                    tableview.reloadData()
                }
                else if !budget.isOpen && segmentBtn.selectedSegmentIndex == 1 {
                    for i in 0..<filterBudget.count {
                        if filterBudget[i].id == budget.id {
                            filterBudget.remove(at: i)
                            break
                        }
                    }
                    tableview.reloadData()
                }
            }
        }
    }
    
    func budgetUpdated(_ budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                updateBudgetsArray(budget: budget)
            }
        }
    }
    
    //BudgetMemberDelegate
    func memberLeft(_ member: User, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                updateBudgetsArray(budget: budget)
            }
        }
    }
    
    func memberAdded(_ member: User, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                updateBudgetsArray(budget: budget)
            }
        }
    }
    
    //BudgetCategory
    func categoryAdded(_ category: Category, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                updateBudgetsArray(budget: budget)
            }
        }
    }
    func categoryRemoved(_ category: Category, budget: Budget) {
        if isDataAvailable {
            if budget.walletID == Resource.sharedInstance().currentWalletID {
                updateBudgetsArray(budget: budget)
            }
        }
    }
    
    //transaction delegates
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                
                if !currentWalletTransactions.contains(where: { (_transaction) -> Bool in
                    return _transaction.id == transaction.id
                }){
                    currentWalletTransactions.append(transaction)
                }
                
                for i in 0..<budgets.count {
                    if budgets[i].categories.contains(where: { (_category) -> Bool in
                        return _category.id == transaction.categoryId
                    }){
                        if budgets[i].getMemberIDs().contains(where: { (memberID) -> Bool in
                            return memberID == transaction.transactionById
                        }){
                            if budgets[i].isOpen && segmentBtn.selectedSegmentIndex == 0 {
                                self.tableview.reloadData()
                            }
                        }

                    }
                }
            }
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                if currentWalletTransactions.contains(where: { (_trans) -> Bool in
                    return _trans.id == transaction.id
                }) {
                    for i in 0..<currentWalletTransactions.count {
                        if currentWalletTransactions[i].id == transaction.id {
                            currentWalletTransactions.remove(at: i)
                            break
                        }
                    }
                }
                for i in 0..<budgets.count {
                    if budgets[i].categories.contains(where: { (_category) -> Bool in
                        return _category.id == transaction.categoryId
                    }){
                        if budgets[i].getMemberIDs().contains(where: { (memberID) -> Bool in
                            return memberID == transaction.transactionById
                        }){
                                self.tableview.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID {
                
                for i in 0..<currentWalletTransactions.count {
                    if currentWalletTransactions[i].id == transaction.id {
                        currentWalletTransactions[i] = transaction
                    }
                }
                
                for i in 0..<budgets.count {
                    if budgets[i].categories.contains(where: { (_category) -> Bool in
                        return _category.id == transaction.categoryId
                    }){
                        if budgets[i].getMemberIDs().contains(where: { (memberID) -> Bool in
                            return memberID == transaction.transactionById
                        }){
                            self.tableview.reloadData()
                        }
                    }
                }
            }
        }
    }

    
    
    
    
}
