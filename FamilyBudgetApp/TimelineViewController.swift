//
//  TimelineViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate{

    var selectedrow : Int?
    @IBOutlet weak var tableview: UITableView!
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactions = (Resource.sharedInstance().currentWallet?.transactions)!
        Delegate.sharedInstance().addTransactionDelegate(self)
        TransactionObserver.sharedInstance().startObservingTransaction(ofWallet: (Resource.sharedInstance().currentWallet?.id)!)
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
        return transactions.count
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
        
        self.performSegue(withIdentifier: "addTrans", sender: nil)
        
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
        
        if segue.identifier == "addTrans" {
            destination.isNew = true
            print(destination.isNew)
        }
    }
    
    //Transaction Delegates
    
    func transactionAdded(_ transaction: Transaction) {
        transactions.append(transaction)
        print("Added Chal gaya")
        tableview.reloadData()
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        tableview.reloadData()
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        tableview.reloadData()
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
