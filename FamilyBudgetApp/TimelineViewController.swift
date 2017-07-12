//
//  TimelineViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate , WalletDelegate, WalletMemberDelegate, UserDelegate{

    var selectedrow : IndexPath?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var IncomeAmount: UILabel!
    @IBOutlet weak var BalanceAmount: UILabel!
    @IBOutlet weak var ExpenseAmount: UILabel!
    @IBOutlet weak var Segmentbtn: UISegmentedControl!
    
    var dateformat = DateFormatter()
    
    var allWalletsBtn = UIBarButtonItem()
    var SettingsBtn = UIBarButtonItem()
    
    
    var transDates = [String]()
    var transactions = [String:[Transaction]]() // [Date:Transaction]
    
    var filteredDates = [String]()
    var filteredTransactions = [String:[Transaction]]()
    
    var isDataAvailable = false
    
    @IBOutlet weak var AddTransactionBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Segmentbtn.selectedSegmentIndex = 0
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                UserObserver.sharedInstance().startObserving()
                Delegate.sharedInstance().addTransactionDelegate(self)
                Delegate.sharedInstance().addWalletDelegate(self)
                WalletObserver.sharedInstance().autoObserve = true
                WalletObserver.sharedInstance().startObserving()
                TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWalletID)!)
                Delegate.sharedInstance().addWalletMemberDelegate(self)
                Delegate.sharedInstance().addUserDelegate(self)
                
                self.isDataAvailable = true
                
                self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
                self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
                
                self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
                self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
                self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
                
                self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
                if !(Resource.sharedInstance().currentWallet?.isOpen)! {
                    self.AddTransactionBtn.isHidden = true
                }
                self.TransactionFiltering()
                self.SegmentbtnAction(self.Segmentbtn)
                self.sortDates()
                print(self.tableview.delegate)
                self.tableview.reloadData()
                
//                let CurrIcon = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])

            }
        }
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        SettingsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.SettingsBtnTapped))
        SettingsBtn.tintColor = darkThemeColor
        
        self.navigationItem.rightBarButtonItem = SettingsBtn
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Resource.sharedInstance().currentWalletID == nil {
            isDataAvailable = false
        }
        
        if isDataAvailable {
            self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
            self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
            self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
            
            self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
            if !(Resource.sharedInstance().currentWallet?.isOpen)! {
                self.AddTransactionBtn.isHidden = true
            }
            self.TransactionFiltering()
            self.SegmentbtnAction(self.Segmentbtn)
            self.sortDates()
            self.tableview.reloadData()
        }
    }
    
    func SettingsBtnTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(cont, animated: true, completion: nil)
    }
    
    func TransactionFiltering() {
        
        transDates = []
        transactions = [:]
        
        for i in 0..<Resource.sharedInstance().currentWallet!.transactions.count {
            let date = dateformat.string(from: Resource.sharedInstance().currentWallet!.transactions[i].date)
            if transactions.keys.contains(date) {
                transactions[date]!.append(Resource.sharedInstance().currentWallet!.transactions[i])
            }
            else {
                transactions[date] = [Resource.sharedInstance().currentWallet!.transactions[i]]
            }
        }
        transDates = Array(transactions.keys)
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
    
    
    func sortDates() {
        
        var Dates = [Date]()
        var ArrangeDates = [String]()
        
        for i in 0..<filteredDates.count {
            Dates.append(dateformat.date(from: filteredDates[i])!)
        }
        
        Dates.sort { (a, b) -> Bool in
            a.compare(b) == .orderedDescending
        }
        
        for i in 0..<Dates.count {
            ArrangeDates.append(dateformat.string(from: Dates[i]))
            print(" Date : \(ArrangeDates)")
        }
        
        filteredDates = ArrangeDates
    }
    
    func allWalletsBtnTapped() {
        
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.present(cont, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddTransactionBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addTrans", sender: nil)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var label = UILabel()
        
        
        if filteredDates.count == 0 {
            label.text = "no transactions yet."
            label.textAlignment = .center
            label.sizeToFit()
            
            tableView.backgroundView = label
        }
        else {
            tableView.backgroundView = nil
        }
        return filteredDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions[filteredDates[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimelineTableViewCell
        var trans = filteredTransactions[filteredDates[indexPath.section]]
        let category = trans![indexPath.row].category
        
        cell.amount.attributedText = getAmountwithCurrency(Amount: trans![indexPath.row].amount, of: cell.amount.font.pointSize)
//        cell.amount.textColor = trans![indexPath.row].isExpense ? .red : .green
        
        cell.category.text = category.name
        cell.categoryIcon.text = category.icon
    
        cell.categoryIcon.textColor = category.color
        cell.categoryIcon.backgroundColor = .white
        cell.categoryIcon.layer.borderColor = category.color.cgColor
        cell.categoryIcon.layer.borderWidth = 1
        cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if filteredTransactions.count == 0 {
            return "No transactions to show. Add a new one."
        }
        return ""
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return filteredDates[section] == dateformat.string(from: Date()) ? "Today" : filteredDates[section] == dateformat.string(from: Date(timeIntervalSinceNow : Double(-24*3600))) ? "Yesterday" : filteredDates[section]
    }
    
    
    @IBAction func addTransaction(_ sender: Any) {
        if (Resource.sharedInstance().currentWallet!.isOpen) {
            self.performSegue(withIdentifier: "addTrans", sender: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath
        performSegue(withIdentifier: "TransactionDetail", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! AddTransactionViewController
        
        if segue.identifier == "TransactionDetail" {
            destination.isNew = false
            let trans = filteredTransactions[filteredDates[selectedrow!.section]]
            destination.transaction = trans![selectedrow!.row]
            print("transaction Date\(trans![selectedrow!.row].date)")
            
        }
        else if segue.identifier == "addTrans" {
            destination.isNew = true
        }
    }
    
//    Segment btn
    @IBAction func SegmentbtnAction(_ sender: Any) {
        
        filteredDates = []
        filteredTransactions = [:]
        
        if Segmentbtn.selectedSegmentIndex == 0 {
            self.filteredTransactions = self.transactions
            self.filteredDates = self.transDates
        }
        else if Segmentbtn.selectedSegmentIndex == 1 {
            for date in transactions.keys {
                for trans in transactions[date]! {
                    if trans.isExpense {
                        if filteredTransactions.keys.contains(date) {
                            filteredTransactions[date]?.append(trans)
                        }
                        else {
                            filteredDates.append(date)
                            filteredTransactions[date] = [trans]
                        }
                    }
                }
            }
        }
        else if Segmentbtn.selectedSegmentIndex == 2 {
            
            for date in transactions.keys {
                for trans in transactions[date]! {
                    if !trans.isExpense {
                        if filteredTransactions.keys.contains(date) {
                            filteredTransactions[date]?.append(trans)
                        }
                        else {
                            filteredDates.append(date)
                            filteredTransactions[date] = [trans]
                        }
                    }
                }
            }
        }
        sortDates()
        tableview.reloadData()
    }
    
    
    
//    Transaction Delegates
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)

            if transDates.contains(date){
                if !transactions[date]!.contains(where: { (_trans) -> Bool in
                    return _trans.id == transaction.id
                }) {
                    transactions[date]!.append(transaction)
                }
                
            }
            else {
                transDates.append(date)
                transactions[date] = [transaction]
            }
            self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
            self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
            self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
            
            if (transaction.isExpense && Segmentbtn.selectedSegmentIndex == 1) || (!transaction.isExpense && Segmentbtn.selectedSegmentIndex == 2) || Segmentbtn.selectedSegmentIndex == 0 {
                SegmentbtnAction(Segmentbtn)
                tableview.reloadData()
            }
        }
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if isDataAvailable {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)
            
            if transDates.contains(date){
                var trans = transactions[date]
                for i in 0..<trans!.count {
                    if transaction.id == trans![i].id {
                        trans!.remove(at: i)
                        break
                    }
                }
                if trans!.count != 0 {
                    transactions[date] = trans!
                }
                else {
                    transDates.remove(at: transDates.index(of: date)!)
                    transactions.removeValue(forKey: date)
                }
            }
            if filteredDates.contains(date) {
                var trans = filteredTransactions[date]
                for i in 0..<trans!.count {
                    if transaction.id == trans![i].id {
                        trans!.remove(at: i)
                        break
                    }
                }
                if trans!.count != 0 {
                    filteredTransactions[date] = trans!
                }
                else {
                    filteredDates.remove(at: filteredDates.index(of: date)!)
                    filteredTransactions.removeValue(forKey: date)
                }
            }
            if (transaction.isExpense && Segmentbtn.selectedSegmentIndex == 1) || (!transaction.isExpense && Segmentbtn.selectedSegmentIndex == 2) || Segmentbtn.selectedSegmentIndex == 0 {
                sortDates()
                tableview.reloadData()
            }
            
            self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
            self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
            self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
        }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)
            self.TransactionFiltering()
            self.SegmentbtnAction(self.Segmentbtn)
            
            if (transaction.isExpense && Segmentbtn.selectedSegmentIndex == 1) || (!transaction.isExpense && Segmentbtn.selectedSegmentIndex == 2) || Segmentbtn.selectedSegmentIndex == 0 {
                sortDates()
                tableview.reloadData()
            }
            
            self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
            self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
            self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
        }
    }
    
    
    //Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
    
        if isDataAvailable {
        if Resource.sharedInstance().currentWalletID == wallet.id { //hide add transaction btn if wallet is closed
            self.IncomeAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalIncome, of: self.IncomeAmount.font.pointSize)
            self.ExpenseAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.totalExpense, of: self.IncomeAmount.font.pointSize)
            self.BalanceAmount.attributedText = self.getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: self.IncomeAmount.font.pointSize)
            if !wallet.isOpen {
                self.AddTransactionBtn.isHidden = true
            }
            else if wallet.isOpen {
                self.AddTransactionBtn.isHidden = false
            }
        }
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if isDataAvailable {
        if (Resource.sharedInstance().currentWalletID == wallet.id) {
            let alert = UIAlertController(title: "Error", message: "This Wallet has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: {
                
                action in
                
                Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                self.TransactionFiltering()
                self.SegmentbtnAction(self.Segmentbtn)
                self.sortDates()
                self.tableview.reloadData()
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        }
    }
    
    
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if isDataAvailable {
            if wallet.id == Resource.sharedInstance().currentWalletID {
                if ofType == .admin || ofType == .owner {
                    self.AddTransactionBtn.isHidden = false
                }
                else {
                    self.AddTransactionBtn.isHidden = true
                }
            }
        }
        
    }
    
    
    func userAdded(_ user: User) {
        
    }
    func userUpdated(_ user: User) {
        if isDataAvailable {
            if Resource.sharedInstance().currentWallet!.members.contains(where: { (_user) -> Bool in
                return _user.getUserID() == user.getUserID()
            }){
                tableview.reloadData()
            }
        }
    }
    func userDetailsAdded(_ user: CurrentUser) {
        if isDataAvailable {
            tableview.reloadData()
        }
    }
    func userDetailsUpdated(_ user: CurrentUser) {
        if isDataAvailable {
            tableview.reloadData()
        }
    }
    
}
