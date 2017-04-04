//
//  AddTransactionViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/22/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit



class AddTransactionViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WalletDelegate, TransactionDelegate {
    
    var newView : UIView?
    
    @IBOutlet weak var DoneBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var segmentbtn: UISegmentedControl!
    
    @IBOutlet var CategoryView: UIView!
    
    var TransactionCategoryID : String? = nil
    var date : Double?
    
    var cells = ["Amount","Category","Date"]
    var transaction : Transaction?
    
    var datepicker = UIDatePicker()
    let toolbar = UIToolbar()
    var isNew : Bool?
    let dateformatter = DateFormatter()
    
    var Income = [String]()
    var Expense = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newView = UIView(frame: self.view.frame)
        newView!.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        newView!.addGestureRecognizer(tap)
        
        
        TransactionCategoryID = nil
        
        if !(isNew!) {
            TransactionCategoryID = transaction!.categoryId
            headertitle.text = "TRANSACTION DETAIL"
            DoneBtn.title = "EDIT"
            DoneBtn.isEnabled = false
            DoneBtn.tintColor = .clear
            cells.insert("Transaction By", at: 0)       // first row for transaction By
            if transaction!.comments != nil {
                cells.append("Comments")                // if Comments are not nil add comments line
            }
            if (transaction!.transactionById == Resource.sharedInstance().currentUserId || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner) && Resource.sharedInstance().currentWallet!.isOpen {
                DoneBtn.isEnabled = true
                DoneBtn.tintColor = .blue
                cells.append("Delete")
            }
            if transaction!.isExpense {
                segmentbtn.selectedSegmentIndex = 0
            }
            else {
                segmentbtn.selectedSegmentIndex = 1
            }
            segmentbtn.isEnabled = false
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        CategoryCollectionView.delegate = self
        CategoryCollectionView.dataSource = self
        
//        tableView.estimatedRowHeight = 80
//        tableView.rowHeight = UITableViewAutomaticDimension

        datepicker.maximumDate = Date()
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        toolbar.sizeToFit()
        dateformatter.dateFormat = "dd-MMM-yyyy"
        
        for key in Resource.sharedInstance().categories.keys {
            let curr = Resource.sharedInstance().categories[key]
            if curr!.isExpense {
                Expense.append(key)
            }
            else {
                Income.append(key)
            }
        }
        
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addTransactionDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                // currency not available right now
                if self.isNew! {
                    self.transaction = Transaction(transactionId: "", amount: 0, categoryId: "", comments: nil, date: Date().timeIntervalSince1970, transactionById: Resource.sharedInstance().currentUserId!, currencyId: "-KUSVorHYEOc4zYoAwgp", isExpense: true, walletID: Resource.sharedInstance().currentWalletID!)
                    self.cells.append("Comments")
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if TransactionCategoryID != nil {
            transaction?.categoryId = TransactionCategoryID!
        }
        tableView.reloadData()
    }
    
    // Do any additional setup after loading the view.
    
    
    func donepressed(){
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! DefaultTableViewCell
        cell.textview.isEditable = true
        cell.textview.text = dateformatter.string(from: datepicker.date)
        date = datepicker.date.timeIntervalSince1970
        transaction!.date = datepicker.date
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! DefaultTableViewCell
        cell.textview.isEditable = true
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func DoneBtnPressed(_ sender: Any) {
        
        var cell : DefaultTableViewCell?
        var categorycell : CategoryTableViewCell?
        
        if DoneBtn.title != "EDIT" {
            cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DefaultTableViewCell
            categorycell = tableView.cellForRow(at: IndexPath(row: isNew! ? 1 : 2, section: 0)) as! CategoryTableViewCell
        }
        
        if DoneBtn.title == "DONE" {
            
            transaction?.amount = Double(cell!.textview.text!) ?? 0
            var error = ""
            var errorDis = ""
            
            if transaction!.amount == 0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if transaction!.categoryId == "" || categorycell!.name.text == "None" {
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
        else if DoneBtn.title == "SAVE" {
            
            transaction?.amount = Double(cell!.textview.text!) ?? 0
            var error = ""
            var errorDis = ""
            
            if transaction!.amount == 0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if transaction!.categoryId == "" || categorycell!.name.text == "None" {
                error = "Error"
                errorDis = "Category cannot be empty"
            }
            if error == "" {
                TransactionManager.sharedInstance().updateTransactionInWallet(transaction!)
            }
            else {
                let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
            
        else if DoneBtn.title == "EDIT" {
            isNew = true                                // to allow editing
            DoneBtn.title = "SAVE"
            cells.remove(at: 0)
            if !(cells.contains("Comments")) {
                cells.remove(at: cells.count-1)
                cells.append("Comments")                        // Remove Delete Cell
            }
            else {
                cells.remove(at: cells.count-1)
            }
            segmentbtn.isEnabled = true
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
        
    }
    
    // TableView Functions Delegate and Datasources
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew! {
            return indexPath.row == 1 || indexPath.row == 3 ? 70 : 50
        }
        else {
            if cells.contains("Comments") {
                return indexPath.row == 2 || indexPath.row == 0 || indexPath.row == 4 ? 70 : 50
            }
            else {
                return indexPath.row == 2 || indexPath.row == 0 ? 70 : 50
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isNew! {
            if indexPath.row == 1 {
                addView()
            }
        }
        else if !(isNew!) && Resource.sharedInstance().currentWallet!.isOpen {
            var error = "Alert" , errorDes = "You don't have rights to Change this Transaction"
            if DoneBtn.isEnabled {
                errorDes = "Press Edit To Make Changes"
            }
            let alert = UIAlertController(title: error, message: errorDes, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
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
            
            cell.textView.delegate = self
            cell.textView.tag = 4
            cell.textView.isEditable = isNew! ? true : false
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            return cell
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
            cell.name.text = TransactionCategoryID == nil ? "None" : ( (transaction?.category.isExpense)! && segmentbtn.selectedSegmentIndex == 1 ? "None" : ( !((transaction?.category.isExpense)!) && segmentbtn.selectedSegmentIndex == 0 ? "None" : transaction!.category.name ))
            
            print("Category name : \(cell.name.text)")
            
            cell.icon.text = cell.name.text != "None" ? transaction?.category.icon : ""
            cell.icon.backgroundColor = transaction?.category != nil ? transaction!.category.color : UIColor.lightGray
            cell.icon.textColor = transaction!.category.color
            cell.icon.backgroundColor = .white
            cell.icon.layer.borderColor = transaction?.category.color.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            return cell
            
        case "Delete":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell") as! DeleteTableViewCell
            cell.DeleteBtn.addTarget(nil, action: #selector(self.DeleteTransaction), for: .touchUpInside)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        case "Transaction By":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionbyCell") as! TransactionByTableViewCell
            cell.name.text = transaction?.transactionBy.userName
            let type = Resource.sharedInstance().currentWallet!.memberTypes[(transaction!.transactionById)]
            
            cell.personimage.image = #imageLiteral(resourceName: "dp-male")
            
            if type == .admin {
                print("admin")
                cell.type.text = "Admin"
            }
            else if type == .owner {
                print("Owner")
                cell.type.text = "Owner"
            }
            else if type == .member {
                print("member")
                cell.type.text = "Member"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textview.text = transaction?.amount != 0.0 ? "\(transaction!.amount)" : "0"
                if isNew! {
                    cell.textview.isUserInteractionEnabled = true
                }
                if !(isNew!) {
                    cell.textview.isUserInteractionEnabled = false
                }
                cell.textview.tag = 0
                cell.textview.delegate = self
            }
                
            else if cell.title.text == "Date" {
                
                cell.textview.inputView = datepicker
                print(dateformatter.string(from: transaction!.date))
                cell.textview.text = dateformatter.string(from: transaction!.date)
                let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
                let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
                let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                self.toolbar.setItems([cancel,spaceButton,done], animated: false)
                cell.textview.inputAccessoryView = self.toolbar
                cell.textview.isUserInteractionEnabled = true
                cell.textview.tag = 3
            }
            cell.textview.isEditable = isNew! ? true : false
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    // Delete Transaction Method
    func DeleteTransaction() {
        
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this tansaction", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
        print("Kar de Delete")
        TransactionManager.sharedInstance().removeTransactionInWallet(transaction!, wallet: Resource.sharedInstance().currentWallet!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
        print("Nhn Kr Delete")
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
        if textView.tag == 0 {
            textView.text = textView.text == "0" ? "" : "\(transaction!.amount)"
            if transaction!.amount == floor(transaction!.amount) && transaction!.amount != 0 {
                textView.text = "\(Int(transaction!.amount))"
            }
        }
    }
    
    // Amount tag 0
    // Date Tag 3
    // Comment tag 4
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 0 {
            transaction?.amount = Double(textView.text!) ?? 0
            if textView.text == "" || textView.text == "0.0" || textView.text == "0" {
                textView.text = "0"
            }
            else {
                textView.text = "\(transaction!.amount)"
            }
        }
        else if textView.tag == 4 {
            textView.text = textView.text == "" ? "Write here" : textView.text
            transaction?.comments = textView.text
        }
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
    
    // Category CollectionVIew
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentbtn.selectedSegmentIndex == 0 {
            return Expense.count
        }
        else {
            return Income.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
        var category : Category?
        if segmentbtn.selectedSegmentIndex == 0 {
            category = Resource.sharedInstance().categories[Expense[indexPath.item]]
        }
        else {
            category = Resource.sharedInstance().categories[Income[indexPath.item]]
        }
        cell.name.text = category!.name
        cell.icon.text = category!.icon
        
        cell.icon.textColor = category!.color
        cell.icon.backgroundColor = .white
        cell.icon.layer.borderColor = category!.color.cgColor
        cell.icon.layer.borderWidth = 1
        cell.icon.layer.cornerRadius = cell.icon.frame.width/2
        
        if transaction?.categoryId == category?.id {
            cell.selectedCategory.isHidden = false
            cell.selectedCategory.layer.cornerRadius = cell.selectedCategory.layer.frame.width/2
            cell.selectedCategory.layer.borderWidth = 1
            cell.selectedCategory.layer.borderColor = cell.selectedCategory.textColor.cgColor
            cell.selectedCategory.backgroundColor = .white
        }
        else {
            cell.selectedCategory.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentbtn.selectedSegmentIndex == 0 {
            transaction!.categoryId = Expense[indexPath.item]
            TransactionCategoryID = Expense[indexPath.item]
        }
        else if segmentbtn.selectedSegmentIndex == 1 {
            transaction!.categoryId = Income[indexPath.item]
            TransactionCategoryID = Income[indexPath.item]
        }
        tableView.reloadData()
        removeView()
    }
    
    // Adding Category View
    
    func ViewTap() {
        removeView()
    }
    
    func addView() {
        newView = UIView(frame: self.view.frame)
        newView!.backgroundColor = .lightGray
        newView!.alpha = 0.5
        newView!.isUserInteractionEnabled = true
        CategoryCollectionView.reloadData()
        CategoryView.layer.shadowColor = UIColor.black.cgColor
        CategoryView.layer.shadowOpacity = 0.7
        CategoryView.layer.shadowOffset = CGSize(width: 0, height: 0)
        CategoryView.layer.shadowRadius = 22.0
        view.addSubview(newView!)
        view.addSubview(CategoryView)
        CategoryView.center = self.view.center
        CategoryView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        CategoryView.alpha = 0
//        self.navigationController!.isNavigationBarHidden = true
        UIView.animate(withDuration: 0.4, animations: {
            self.CategoryView.alpha = 1.0
            self.CategoryView.transform = CGAffineTransform.identity
        })
    }
    
    func removeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.CategoryView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.CategoryView.alpha = 0
            
        }) { (Success) in
            self.CategoryView.removeFromSuperview()
            self.newView!.removeFromSuperview()
//            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    // Wallet Delegates
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            let alert = UIAlertController(title: "Alert", message: "This Wallet Has been Deleted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: { (flag) in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            if !(wallet.isOpen) {
                let alert = UIAlertController(title: "Alert", message: "This Wallet Has been closed", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { flag in
                    if self.isNew! {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        if self.cells[self.cells.count-1] == "Delete" {
                            self.cells.remove(at: self.cells.count-1)
                        }
                        self.DoneBtn.tintColor = .clear
                        self.tableView.reloadData()
                    }
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            if wallet.isOpen {
                if (transaction!.transactionById == Resource.sharedInstance().currentUserId || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner) && Resource.sharedInstance().currentWallet!.isOpen {
                    DoneBtn.isEnabled = true
                    DoneBtn.tintColor = self.navigationItem.leftBarButtonItem?.tintColor
                    cells.append("Delete")
                }
//                let range = NSMakeRange(0, self.tableView.numberOfSections)
//                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections([0], with: .automatic)
            }
        }
    }
    
    //Transaction Delegate
    func transactionAdded(_ transaction: Transaction) {
        print("Aya kuch")
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
            self.tableView.reloadSections([0], with: .automatic)
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
