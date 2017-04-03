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
    
    
    var incometransactions = [Transaction]()
    var expensetransactions = [Transaction]()
    
    var allWalletsBtn = UIBarButtonItem()
    var orderWiseExpense = [String:[Transaction]]()
    
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
        
        
        let CurrIcon = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
        
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
                
                self.TransactionFiltering()

                
            }
        }
        
        
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        // Do any additional setup after loading the view.
    }
    
    var dateformat = DateFormatter()
    var key = [String]()
    
    func orderExpense() {
        for i in 0..<expensetransactions.count {
            print(dateformat.string(from: expensetransactions[i].date))
            if orderWiseExpense[dateformat.string(from: expensetransactions[i].date)] == nil {
                    orderWiseExpense[dateformat.string(from: expensetransactions[i].date)] = [expensetransactions[i]]
                    key.append(dateformat.string(from: expensetransactions[i].date))
            }
            else {
                    orderWiseExpense[dateformat.string(from: expensetransactions[i].date)]!.append(expensetransactions[i])
            }
        }
        tableview.reloadData()
    }

    
    func allWalletsBtnTapped() {
        
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.navigationController?.pushViewController(cont, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
        if Segmentbtn.selectedSegmentIndex == 0 {
            print(key.count)
            return key.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Segmentbtn.selectedSegmentIndex == 0 {
            let c = orderWiseExpense[key[section]]
            print(c?.count)
            return c!.count
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
        var trans : [Transaction]?
        if Segmentbtn.selectedSegmentIndex == 1 {
            category = incometransactions[indexPath.row].category
            cell.amount.text = "\(incometransactions[indexPath.row].amount)"
        }
        else {
            trans = orderWiseExpense[key[indexPath.section]]
            print(trans!.count)
            category = trans![indexPath.row].category
            cell.amount.text = "\(trans![indexPath.row].amount)"
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return key[section]
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
            if Segmentbtn.selectedSegmentIndex == 0 {
                let trans = orderWiseExpense[key[selectedrow!.section]]
                destination.transaction = trans![selectedrow!.row]
                print(trans![selectedrow!.row].date)
            }
            else {
                destination.transaction = incometransactions[selectedrow!.row]
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
    
    
    //breaking transaction in expense and income
    func TransactionFiltering() {
//        incometransactions = (Resource.sharedInstance().currentWallet?.transactions.filter({ (trans) -> Bool in
//            return !trans.isExpense
//        }))!
//        
//        expensetransactions = (Resource.sharedInstance().currentWallet?.transactions.filter({ (trans) -> Bool in
//            return trans.isExpense
//        }))!
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
