//
//  TimelineViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate , WalletDelegate{

    var selectedrow : Int?
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var IncomeAmount: UILabel!
    @IBOutlet weak var BalanceAmount: UILabel!
    @IBOutlet weak var ExpenseAmount: UILabel!
    @IBOutlet weak var Segmentbtn: UISegmentedControl!
    @IBOutlet weak var AddBtn: UIBarButtonItem!
    
    var incometransactions = [Transaction]()
    var expensetransactions = [Transaction]()
    
    var allWalletsBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Segmentbtn.selectedSegmentIndex = 0
        UserObserver.sharedInstance().startObserving()
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        WalletObserver.sharedInstance().autoObserve = true
        WalletObserver.sharedInstance().startObserving()
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWalletID)!)
        
        
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

    
    func allWalletsBtnTapped() {
        
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.navigationController?.pushViewController(cont, animated: true)
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
        TransactionFiltering()
        tableview.reloadData()
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        TransactionFiltering()
        tableview.reloadData()
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        TransactionFiltering()
        tableview.reloadData()
    }
    
    
    //Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
        ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
        BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
        
        if Resource.sharedInstance().currentWalletID == wallet.id { //hide add transaction btn if wallet is closed
            if !wallet.isOpen {
                AddBtn.isEnabled = false
                AddBtn.tintColor = .clear
            }
            else if wallet.isOpen {
                AddBtn.isEnabled = true
                AddBtn.tintColor = .blue
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
    
}
