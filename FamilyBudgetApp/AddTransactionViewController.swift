//
//  AddTransactionViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/22/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WalletDelegate, TransactionDelegate {
    
    
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var segmentbtn: UISegmentedControl!
    
    
    var date : Double?
    
    var cells = ["Amount","Category","Date"]
    var transaction : Transaction?
    
    var datepicker = UIDatePicker()
    let toolbar = UIToolbar()
    var isNew : Bool?
    let dateformatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print(addBtn.currentTitle)
        
        if !(isNew!) {
            headertitle.text = "TRANSACTION DETAIL"
            addBtn.setTitle("EDIT", for: .normal)
            addBtn.isEnabled = false
            addBtn.isHidden = true
            cells.insert("Transaction By", at: 0)       // first row for transaction By
            if transaction!.comments != nil {
                cells.append("Comments")                // if Comments are not nil add comments line
            }
            if transaction!.transactionById == Resource.sharedInstance().currentUserId && Resource.sharedInstance().currentWallet!.isOpen{
                addBtn.isHidden = false
                addBtn.isEnabled = true
                cells.append("Delete")                  // if transaction is done by same user give delete button
            }
            if transaction!.isExpense {
                segmentbtn.selectedSegmentIndex = 0
            }
            else {
                segmentbtn.selectedSegmentIndex = 1
            }
            segmentbtn.isEnabled = false
            print(transaction?.comments)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor(red: 43/255, green: 190/255, blue: 230/255, alpha: 1.0).cgColor
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        //        detailsTableView.delegate = self
        //        detailsTableView.dataSource = self
        
        segmentbtn.selectedSegmentIndex = 0
        datepicker.maximumDate = Date()
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        toolbar.sizeToFit()
        dateformatter.dateFormat = "dd-MMM-yyyy"
        
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addTransactionDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                if self.isNew! {
                    self.transaction = Transaction(transactionId: "", amount: 0, categoryId: "", comments: nil, date: Date().timeIntervalSince1970, transactionById: Resource.sharedInstance().currentUserId!, currencyId: "-KUSVorHYEOc4zYoAwgp", isExpense: true, walletID: Resource.sharedInstance().currentWalletID!)
                    self.cells.append("Comments")
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // Do any additional setup after loading the view.
    
    
    func donepressed(){
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! DefaultTableViewCell
        cell.textView.text = dateformatter.string(from: datepicker.date)
        date = datepicker.date.timeIntervalSince1970
        transaction!.date = datepicker.date
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addBtnAction(_ sender: UIButton) { // row changing every time for amount
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DefaultTableViewCell
        
        if addBtn.currentTitle == "DONE" {
            
            transaction?.amount = Double(cell.textView.text!) ?? 0
            var error = ""
            var errorDis = ""
            
            if transaction!.amount == 0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if transaction!.categoryId == "" {
                error = "Error"
                errorDis = "Category cannot be empty"
            }
            else if transaction?.date == nil {
                error = "Error"
                errorDis = "Date cannot be empty"
            }
            
            if error == "" {
                TransactionManager.sharedInstance().AddTransactionInWallet(transaction!)
                self.navigationController!.popViewController(animated: true)
            }
            else {
                let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
        else if addBtn.currentTitle == "SAVE" {
            
            transaction?.amount = Double(cell.textView.text!) ?? 0
            var error = ""
            var errorDis = ""
            
            if transaction!.amount == 0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            if error == "" {
                TransactionManager.sharedInstance().updateTransactionInWallet(transaction!)
                self.navigationController!.popViewController(animated: true)
            }
            else {
                let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
            
        else if addBtn.currentTitle == "EDIT" {
            isNew = true                                // to allow editing
            addBtn.setTitle("SAVE", for: .normal)
            cells.remove(at: 0)
            if transaction!.comments == nil {
                cells.remove(at: cells.count-1)
                cells.append("Comments")
            }
            else {
                cells.remove(at: cells.count-1)
            }
            tableView.reloadData()
        }
    }
    
    
    // TableView Functions Delegate and Datasources
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew! {
            return indexPath.row == 1 ? 70 : 50
        }
        else {
            return indexPath.row == 2 ? 70 : 50
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNew! {
            if indexPath.row == 1 {
                performSegue(withIdentifier: "Category", sender: nil)
            }
        }
        else if !(isNew!) && Resource.sharedInstance().currentWallet!.isOpen {
            var error = "Alert" , errorDes = "You don't have rights to Change this Transaction"
            if addBtn.isEnabled {
                errorDes = "Press Edit To Make Changes"
            }
            let alert = UIAlertController(title: error, message: errorDes, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    //    prepareing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Category" {
            let destination = segue.destination as! CategoriesViewController
            destination.transaction = self.transaction!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.row] {
            
        case "Comments":
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
            
            cell.textView.text = transaction!.comments != nil ? (transaction?.comments == "" ? "Write here" : transaction!.comments) : "Write here"
            
            cell.textView.autoresizingMask = UIViewAutoresizing.flexibleHeight

            if cell.textView.contentSize.height > cell.frame.height {
                cell.frame.size.height += (cell.textView.contentSize.height - cell.frame.height) + 8
            }
            
            cell.textView.isEditable = isNew! ? true : false
            cell.textView.delegate = self
            
            return cell
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
            cell.name.text = isNew! ? ( transaction?.categoryId == nil ? "None" : (transaction!.isExpense && segmentbtn.selectedSegmentIndex == 1 ? "None" : ( !transaction!.isExpense && segmentbtn.selectedSegmentIndex == 0 ? "None" : transaction!.category.name))) : transaction!.category.name
            
//            if isNew! {
//                if transaction?.categoryId == "" {
//                    cell.name.text = "None"
//                    cell.icon.text = ""
//                }
//                else if (transaction?.category.isExpense)! && segmentbtn.selectedSegmentIndex == 1 {
//                    cell.name.text = "None"
//                    cell.icon.text = ""
//                }
//                else if !((transaction?.category.isExpense)!) && segmentbtn.selectedSegmentIndex == 0 {
//                    cell.name.text = "None"
//                    cell.icon.text = ""
//                }
//                else {
//                    cell.name.text = transaction?.category.name
//                    cell.icon.text = transaction?.category.icon
//                }
//            }
//            else {
//                cell.name.text = transaction!.category.name
//                cell.icon.text = transaction!.category.icon
//            }
            
            cell.icon.backgroundColor = transaction?.category != nil ? transaction!.category.color : UIColor.lightGray
            cell.icon.textColor = transaction!.category.color
            cell.icon.backgroundColor = .white
            cell.icon.layer.borderColor = transaction?.category.color.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
            return cell
            
        case "Delete":
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell") as! DeleteTableViewCell
            if isNew! {
                cell.isHidden = true
            }
                
            else if !(Resource.sharedInstance().currentWallet!.isOpen) {
                cell.isHidden = true
            }
            else {
                cell.isHidden = false
            }
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textView.text = transaction?.amount != 0.0 ? "\(transaction!.amount)" : "0"
                cell.textView.isUserInteractionEnabled = true
                
                cell.textView.text = transaction?.amount != 0.0 ? "\(transaction!.amount)" : ""
                if isNew! {
                    cell.textView.isUserInteractionEnabled = true
                }
                if !(isNew!) {
                    cell.textView.isUserInteractionEnabled = false
                }
            }
                
            else if cell.title.text == "Date" {
                
                cell.textView.inputView = datepicker
                cell.textView.text = dateformatter.string(from: transaction!.date)
                let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
                let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
                let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                self.toolbar.setItems([cancel,spaceButton,done], animated: false)
                cell.textView.inputAccessoryView = self.toolbar
                if !(isNew!) {
                    cell.textView.isUserInteractionEnabled = false
                }
                if (isNew!) {
                    cell.textView.isUserInteractionEnabled = true
                }
            }
            
            else if cell.title.text == "Transaction By" {
                cell.textView.text = transaction!.transactionBy.userName
                cell.textView.isUserInteractionEnabled = false
            }
            else {
                
                cell.textView.isUserInteractionEnabled = false
            }
            
            return cell
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {

        guard let cell = tableView.cellForRow(at: IndexPath(row: cells.endIndex-1, section: 0)) as? CommentsTableViewCell else {
            return
        }
        let newTextView = textView
        let fixedWidth = newTextView.frame.size.width;
        let newSize = newTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if newSize.height > textView.frame.height + 16 {
            
            cell.frame.size.height = newSize.height+18
            textView.frame.size.height = newSize.height
            tableView.contentSize.height += 20
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write here" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text == "" ? "Write here" : textView.text
        transaction?.comments = textView.text
    }
    
    @IBAction func segmentbtnAction(_ sender: Any) {
        if segmentbtn.selectedSegmentIndex == 0 {
            transaction!.isExpense = true
        }
        else if segmentbtn.selectedSegmentIndex == 1 {
            transaction!.isExpense = false
        }
        tableView.reloadData()
    }
    
    
    @IBAction func DeleteTransactionBtn(_ sender: Any) {
        TransactionManager.sharedInstance().removeTransactionInWallet(transaction!, wallet: Resource.sharedInstance().currentWallet!)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // Wallet Delegates
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            let alert = UIAlertController(title: "Alert", message: "This Wallet Has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            if !(wallet.isOpen) {
                let alert = UIAlertController(title: "", message: "This Wallet Has been closed", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { ac in
                    if self.isNew! {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        if self.cells[self.cells.count-1] == "Delete" {
                            self.cells.remove(at: self.cells.count-1)
                        }
                        self.addBtn.isHidden = true
                        self.tableView.reloadData()
                    }
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            if wallet.isOpen {
                if !(isNew!) {
                    cells.append("Delete")
                    addBtn.isHidden = false
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //Transaction Delegate
    func transactionAdded(_ transaction: Transaction) {
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if self.transaction!.id == transaction.id {
            let alert = UIAlertController(title: "Alert", message: "This transaction Has been deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (huz) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if self.transaction!.id == transaction.id {
            self.transaction = transaction
            let alert = UIAlertController(title: "", message: "This Transaction Has been Updated", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (huz) in
                self.tableView.reloadData()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
