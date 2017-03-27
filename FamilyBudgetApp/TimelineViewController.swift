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
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactions = (Resource.sharedInstance().currentWallet?.transactions.filter({ (tran) -> Bool in
            return tran.isExpense
        }))!
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWallet?.id)!)
        
        IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
        ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
        BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
        
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
//        ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
//        BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TimelineTableViewCell
        let category = transactions[indexPath.row].category
        cell.category.text = category.name
        cell.amount.text = "\(transactions[indexPath.row].amount)"
        cell.categoryIcon.text = category.icon
    
        cell.categoryIcon.backgroundColor = category.color
        cell.categoryIcon.textColor = category.color
        cell.categoryIcon.backgroundColor = .white
        cell.categoryIcon.layer.borderColor = category.color.cgColor
        cell.categoryIcon.layer.borderWidth = 1
        cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
        
        
        return cell
    }
    
    @IBAction func addTransaction(_ sender: Any) {
        
        if (Resource.sharedInstance().currentWallet!.isOpen) {
            self.performSegue(withIdentifier: "addTrans", sender: nil)
        }
        else if !(Resource.sharedInstance().currentWallet!.isOpen) { // Ya button hide karun
            let alert = UIAlertController(title: "Error", message: "This Wallet is close no transaction can be performed", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
            destination.transaction = transactions[selectedrow!]
            print(destination.transaction!.id)
        }
        else if segue.identifier == "addTrans" {
            destination.isNew = true
//            print(destination.isNew)
        }
    }
    
    //Transaction Delegates
    
    func transactionAdded(_ transaction: Transaction) {
        transactions.append(transaction)
        print("Added Chal gaya")
        transactions = (Resource.sharedInstance().currentWallet?.transactions)!
        tableview.reloadData()
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        transactions = (Resource.sharedInstance().currentWallet?.transactions)!
        tableview.reloadData()
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        transactions = (Resource.sharedInstance().currentWallet?.transactions)!
        tableview.reloadData()
    }
    
    
    //Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        IncomeAmount.text = "\(Resource.sharedInstance().currentWallet!.totalIncome)"
        ExpenseAmount.text = "\(Resource.sharedInstance().currentWallet!.totalExpense)"
        BalanceAmount.text = "\(Resource.sharedInstance().currentWallet!.balance)"
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if (Resource.sharedInstance().currentWalletID == wallet.id) {
            let alert = UIAlertController(title: "Error", message: "This Wallet has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
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
