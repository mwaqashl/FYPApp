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
    @IBOutlet weak var AddBtn: UIBarButtonItem!
    
    var dateformat = DateFormatter()
    
    var allWalletsBtn = UIBarButtonItem()
    
    var transDates = [String]()
    var transactions = [String:[Transaction]]()
    
    var filteredDates = [String]()
    var filteredTransactions = [String:[Transaction]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        barBtnColor = AddBtn.tintColor!
        
        Segmentbtn.selectedSegmentIndex = 0
        UserObserver.sharedInstance().startObserving()
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        WalletObserver.sharedInstance().autoObserve = true
        WalletObserver.sharedInstance().startObserving()
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWalletID)!)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        Delegate.sharedInstance().addUserDelegate(self)
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                self.IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
                self.ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
                self.BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
                
                self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
                if !(Resource.sharedInstance().currentWallet?.isOpen)! {
                    self.AddBtn.isEnabled = false
                    self.AddBtn.tintColor = .clear
                }
                
                
                let CurrIcon = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])

            }
        }
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        // Do any additional setup after loading the view.
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(filteredDates.count)
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
        
        cell.amount.text = "\(trans![indexPath.row].amount)"
        
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return filteredDates[section] == dateformat.string(from: Date()) ? "Today" : filteredDates[section] == dateformat.string(from: Date(timeIntervalSinceNow : Double(-24*3600))) ? "Yesterday" : filteredDates[section]
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -200, 0, 0)
        view.layer.transform = transform
        
        UIView.animate(withDuration: 0.5) {
            view.alpha = 1.0
            view.layer.transform = CATransform3DIdentity
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -200, 0, 0)
        cell.layer.transform = transform

        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
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
        
        if Segmentbtn.selectedSegmentIndex == 0 {
            filteredDates = transDates
            filteredTransactions = transactions
        }
        else if Segmentbtn.selectedSegmentIndex == 1 {
            filteredDates = []
            filteredTransactions = [:]
            for date in transactions.keys {
                for trans in transactions[date]! {
                    if trans.isExpense {
                        if filteredTransactions[date] == nil {
                            filteredTransactions[date] = [trans]
                            filteredDates.append(date)
                        }
                        else {
                            filteredTransactions[date]!.append(trans)
                        }
                    }
                }
            }
        }
        else if Segmentbtn.selectedSegmentIndex == 2 {
            filteredDates = []
            filteredTransactions = [:]
            for date in transactions.keys {
                for trans in transactions[date]! {
                    if !trans.isExpense {
                        if filteredTransactions[date] == nil {
                            filteredTransactions[date] = [trans]
                            filteredDates.append(date)
                        }
                        else {
                            filteredTransactions[date]!.append(trans)
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
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)

            if transDates.contains(date){
                transactions[date]!.append(transaction)
            }
            else {
                transDates.append(date)
                transactions[date] = [transaction]
            }
            if Segmentbtn.selectedSegmentIndex == 0 {
                filteredDates = transDates
                filteredTransactions = transactions
            }                                                           // below code can be removed if i set segmentbtn to 0
            else if Segmentbtn.selectedSegmentIndex == 1 {
                if transaction.isExpense {
                    if filteredDates.contains(date) {
                        filteredTransactions[date]!.append(transaction)
                    }
                    else {
                        filteredDates.append(date)
                        filteredTransactions[date] = [transaction]
                    }
                }
            }
            else if Segmentbtn.selectedSegmentIndex == 2 {
                if !transaction.isExpense {
                    if filteredDates.contains(date) {
                        filteredTransactions[date]!.append(transaction)
                    }
                    else {
                        filteredDates.append(date)
                        filteredTransactions[date] = [transaction]
                    }
                }
            }
            sortDates()
            tableview.reloadData()
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)
            
            if transDates.contains(date){
                var trans = transactions[date]
                print(trans!.count)
                for i in 0..<trans!.count {
                    if transaction.id == trans![i].id {
                        trans!.remove(at: i)
                        break
                    }
                }
                print(trans!.count)
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
            sortDates()
            tableview.reloadData()
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            
            let date = dateformat.string(from: transaction.date)
            
            if transDates.contains(date){
                var trans = transactions[date]
                print(trans!.count)
                for i in 0..<trans!.count {
                    if transaction.id == trans![i].id {
                        trans![i] = transaction
                        break
                    }
                }
            }
            if filteredDates.contains(date) {
                var trans = filteredTransactions[date]
                for i in 0..<trans!.count {
                    if transaction.id == trans![i].id {
                        trans![i] = transaction
                        break
                    }
                }
                sortDates()
                tableview.reloadData()
            }
        }
    }
    
    
    //Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
    
        if Resource.sharedInstance().currentWalletID == wallet.id { //hide add transaction btn if wallet is closed
            IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
            ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
            BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
            if !wallet.isOpen {
                AddBtn.isEnabled = false
                AddBtn.tintColor = .clear
            }
            else if wallet.isOpen {
                AddBtn.isEnabled = true
                AddBtn.tintColor = self.navigationItem.leftBarButtonItem?.tintColor
            }
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if (Resource.sharedInstance().currentWalletID == wallet.id) {
            let alert = UIAlertController(title: "Error", message: "This Wallet has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: {
                
                action in
                
                Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                
//                self.navigationController?.popViewController(animated: true)
                
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
//    func TransactionFiltering() {
//        
//        for i in 0..<Resource.sharedInstance().currentWallet!.transactions.count {
//            let date = dateformat.string(from: Resource.sharedInstance().currentWallet!.transactions[i].date)
//            if transactions[date] == nil {
//                transactions[date] = [(Resource.sharedInstance().currentWallet?.transactions[i])!]
//                transDates.append(date)
//            }
//            else {
//                transactions[date]?.append(Resource.sharedInstance().currentWallet!.transactions[i])
//            }
//        }
//        filteredTransactions = transactions
//        filteredDates = transDates
//        tableview.reloadData()
//    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    
    
    func userAdded(_ user: User) {
        
    }
    func userUpdated(_ user: User) {
        
    }
    func userDetailsAdded(_ user: CurrentUser) {
        
    }
    func userDetailsUpdated(_ user: CurrentUser) {
        
    }
    
}
