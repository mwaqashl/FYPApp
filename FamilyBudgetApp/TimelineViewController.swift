//
//  TimelineViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate , WalletDelegate, WalletMemberDelegate, UserDelegate{

    var selectedrow : Int?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var IncomeAmount: UILabel!
    @IBOutlet weak var BalanceAmount: UILabel!
    @IBOutlet weak var ExpenseAmount: UILabel!
    @IBOutlet weak var Segmentbtn: UISegmentedControl!
    @IBOutlet weak var AddBtn: UIBarButtonItem!
    
    
    var incometransactions = [Transaction]()
    var expensetransactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        barBtnColor = AddBtn.tintColor!
        
        Segmentbtn.selectedSegmentIndex = 0
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        Delegate.sharedInstance().addUserDelegate(self)
        
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWallet?.id)!)
        
        let CurrIcon = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
        
        let Income = NSAttributedString(string: "\(Resource.sharedInstance().currentWallet!.balance)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
        
        let str = NSMutableAttributedString()
        str.append(CurrIcon)
        str.append(Income)
        
        IncomeAmount.attributedText = str
        ExpenseAmount.text = "\(CurrIcon) \(Resource.sharedInstance().currentWallet!.totalExpense)"
        BalanceAmount.text = "\(CurrIcon) \(Resource.sharedInstance().currentWallet!.balance)"
        
        if !(Resource.sharedInstance().currentWallet?.isOpen)! {
            AddBtn.isEnabled = false
            AddBtn.tintColor = .clear
        }
        
        TransactionFiltering()
        
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Segmentbtn.selectedSegmentIndex == 0 {
            return expensetransactions.count
        }
        else {
            return incometransactions.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimelineTableViewCell
        var category : Category?
        if Segmentbtn.selectedSegmentIndex == 1 {
            category = incometransactions[indexPath.row].category
            cell.amount.text = "\(incometransactions[indexPath.row].amount)"
        }
        else {
            category = expensetransactions[indexPath.row].category
            cell.amount.text = "\(expensetransactions[indexPath.row].amount)"
        }
        cell.category.text = category!.name
        cell.categoryIcon.text = category!.icon
    
        cell.categoryIcon.textColor = category!.color
        cell.categoryIcon.backgroundColor = .white
        cell.categoryIcon.layer.borderColor = category!.color.cgColor
        cell.categoryIcon.layer.borderWidth = 1
        cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
        
        return cell
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
        selectedrow = indexPath.row
        performSegue(withIdentifier: "TransactionDetail", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! AddTransactionViewController
        
        if segue.identifier == "TransactionDetail" {
            destination.isNew = false
            if Segmentbtn.selectedSegmentIndex == 0 {
                destination.transaction = expensetransactions[selectedrow!]
            }
            else {
                destination.transaction = incometransactions[selectedrow!]
            }
        }
        else if segue.identifier == "addTrans" {
            destination.isNew = true
        }
    }
    
//    Segment btn
    @IBAction func SegmentbtnAction(_ sender: Any) {
        tableview.reloadData()
    }
    
    
    
//    Transaction Delegates
    func transactionAdded(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            TransactionFiltering()
            tableview.reloadData()
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            TransactionFiltering()
            tableview.reloadData()
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if transaction.walletID == Resource.sharedInstance().currentWalletID {
            TransactionFiltering()
            tableview.reloadData()
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
            let alert = UIAlertController(title: "Alert", message: "This Wallet has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: { (success) in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    //breaking transaction in expense and income
    func TransactionFiltering() {
        incometransactions = (Resource.sharedInstance().currentWallet?.transactions.filter({ (trans) -> Bool in
            return !trans.isExpense
        }))!
        
        expensetransactions = (Resource.sharedInstance().currentWallet?.transactions.filter({ (trans) -> Bool in
            return trans.isExpense
        }))!
    }
    
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
