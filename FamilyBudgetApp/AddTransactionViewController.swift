//
//  AddTransactionViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/22/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit



class AddTransactionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, WalletDelegate, TransactionDelegate, UICollectionViewDelegateFlowLayout {
    
    var backView : UIView?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var headertitle: UILabel!
    @IBOutlet weak var segmentbtn: UISegmentedControl!
    
    @IBOutlet var CategoryView: UIView!
    @IBOutlet weak var datepicker: UIDatePicker!
    
    @IBOutlet weak var DatePickerView: UIView!
    var date : Double?
    
    var cells = ["Amount","Category","Date"]
    var transaction : Transaction?
    
    var isNew : Bool = true
    var isEdit: Bool = true
    
    var addBtn = UIBarButtonItem()
    var editBtn = UIBarButtonItem()
    
    let dateformatter = DateFormatter()
    
    var selectedCategory = ""
    var pSelectedCategory = ""
    
    var IncomeCategories = [String]()
    var ExpenseCategories = [String]()
    
    var tap = UITapGestureRecognizer()
    var isKeyboardOpen = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        datepicker.maximumDate = Date()
        
        isEdit = isNew
        CategoryView.isHidden = true
        DatePickerView.isHidden = true
        backView = UIView(frame: self.view.frame)
        backView!.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        
        backView = UIView(frame: self.view.frame)
        backView!.backgroundColor = .lightGray
        backView!.alpha = 0.5
        backView!.isUserInteractionEnabled = true
        
        addBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "done"), style: .plain, target: self, action: #selector(self.addBtnPressed))
        addBtn.tintColor = darkThemeColor
        
        
        editBtn = UIBarButtonItem.init(image: #imageLiteral(resourceName: "edit"), style: .plain, target: self, action: #selector(self.editBtnPressed))
        editBtn.tintColor = darkThemeColor    
        self.navigationItem.backBarButtonItem?.tintColor = darkThemeColor
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        
        for key in Resource.sharedInstance().categories.keys {
            let curr = Resource.sharedInstance().categories[key]
            if curr!.isExpense {
                ExpenseCategories.append(key)
            }
            else {
                IncomeCategories.append(key)
            }
        }
        
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addTransactionDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                // currency not available right now
                if self.isNew {
                    self.transaction = Transaction(transactionId: "", amount: 0.0, categoryId: "", comments: nil, date: Date().timeIntervalSince1970, transactionById: Resource.sharedInstance().currentUserId!, currencyId: Resource.sharedInstance().currentWallet!.currencyID, isExpense: true, walletID: Resource.sharedInstance().currentWalletID!)
                    self.cells.append("Comments")
                    self.datepicker.date = Date()
                    self.navigationItem.rightBarButtonItem = self.addBtn
                }
                else {
                    self.datepicker.date = self.transaction!.date
                    self.headertitle.text = "TRANSACTION DETAILS"
                    self.segmentbtn.isEnabled = false
                    self.cells.append("Transaction By")       // first row for transaction By
                    if self.transaction!.comments != nil {
                        self.cells.append("Comments")                // if Comments are not nil add comments line
                    }
                    if (self.transaction!.transactionById == Resource.sharedInstance().currentUserId || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner) && Resource.sharedInstance().currentWallet!.isOpen {
                        self.cells.append("Delete")
                        self.navigationItem.rightBarButtonItem = self.editBtn
                    }
                }
                
                self.selectedCategory = self.transaction!.categoryId
                self.pSelectedCategory = self.selectedCategory
                
                if self.transaction!.isExpense {
                    self.segmentbtn.selectedSegmentIndex = 0
                }
                else {
                    self.segmentbtn.selectedSegmentIndex = 1
                }
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
                
                self.CategoryCollectionView.delegate = self
                self.CategoryCollectionView.dataSource = self
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if transaction?.walletID != Resource.sharedInstance().currentWalletID! {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var SizeOfKeyboard = CGFloat()
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SizeOfKeyboard = keyboardSize.height
                self.view.addGestureRecognizer(tap)
                isKeyboardOpen = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        
        if isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SizeOfKeyboard = keyboardSize.height
                isKeyboardOpen = false
            }
        }
        
    }

    
    func addBtnPressed() {
        
        var error = ""
        var errorDis = ""
        
        if transaction!.amount == 0 {
            error = "Error"
            errorDis = "Amount cannot be empty"
        }
        else if transaction!.categoryId == ""  {
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
    
    func editBtnPressed(sender: UIBarButtonItem) {
        
        if isEdit {
            
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
            if error == "" {
                isEdit = false
                sender.title = "\u{A013}"
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
        else {
            isEdit = true
            segmentbtn.isEnabled = true
            cells.remove(at: cells.index(of: "Transaction By")!)
            cells.remove(at: cells.index(of: "Delete")!)
            if !cells.contains("Comments") {
                cells.append("Comments")
            }
            sender.title = "\u{A009}"
            segmentbtn.isEnabled = true
            self.tableView.reloadSections([0], with: .automatic)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // TableView Functions Delegate and Datasources
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch cells[indexPath.row] {
            
            case "Comments", "Category" :
                return 70
            case "Transaction By" :
                return 60
            default:
                return 50
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEdit {
            if cells[indexPath.row] == "Category" {
                addView(CategoryView)
            }
            else if cells[indexPath.row] == "Date" {
                addView(DatePickerView)
            }
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
            cell.textView.isEditable = isEdit
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            
            return cell
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
            cell.name.text = selectedCategory == "" ? "None" : ( (transaction?.category.isExpense)! && segmentbtn.selectedSegmentIndex == 1 ? "None" : ( !((transaction?.category.isExpense)!) && segmentbtn.selectedSegmentIndex == 0 ? "None" : transaction!.category.name ))
                        
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
                cell.type.text = "Admin"
            }
            else if type == .owner {
                cell.type.text = "Owner"
            }
            else if type == .member {
                cell.type.text = "Member"
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textview.text = transaction?.amount != 0.0 ? "\(transaction!.amount)" : "0"
                cell.textview.tag = 1
                cell.textview.delegate = self
                cell.textview.isEditable = true
                cell.textview.isUserInteractionEnabled = isEdit
            }
                
            else if cell.title.text == "Date" {
                cell.textview.inputView = datepicker
                cell.textview.isEditable = false
                cell.textview.text = dateformatter.string(from: transaction!.date)
                cell.textview.isUserInteractionEnabled = false
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    // Delete Transaction Method
    func DeleteTransaction() {
        
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this tansaction", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
        TransactionManager.sharedInstance().removeTransactionInWallet(transaction!, wallet: Resource.sharedInstance().currentWallet!)
    }
    
    func NoPressed(action : UIAlertAction) {

    }
    
    func textViewDidChange(_ textView: UITextView) {

        if textView.tag == 1 {
            
            transaction?.amount = Double(textView.text!) ?? 0
            
        }
        else if textView.tag == 4 {
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
        
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.tag == 4 {
            textView.text = textView.text == "Write here" ? "" : textView.text
//            self.view.frame.origin.y -= SizeOfKeyboard
            UIView.animate(withDuration: 0.6) {
                self.view.frame.origin.y -= self.SizeOfKeyboard
            }
        }
        if textView.tag == 1 {
            textView.text = textView.text == "0" ? "" : "\(transaction!.amount)"
        }
    }
    
    // Amount tag 0
    // Comment tag 4
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
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
//            self.view.frame.origin.y += SizeOfKeyboard
            UIView.animate(withDuration: 0.6) {
                self.view.frame.origin.y += self.SizeOfKeyboard
            }
        }
    }
    
    @IBAction func segmentbtnAction(_ sender: Any) {
        
        if isEdit {
            if segmentbtn.selectedSegmentIndex == 0 {
                transaction!.isExpense = true
            }
            else if segmentbtn.selectedSegmentIndex == 1 {
                transaction!.isExpense = false
            }
            selectedCategory = ""
            tableView.reloadData()
        }
        
    }
    
    // Category CollectionVIew
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 60)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentbtn.selectedSegmentIndex == 0 {
            return ExpenseCategories.count
        }
        else {
            return IncomeCategories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
        var category : Category?
        if segmentbtn.selectedSegmentIndex == 0 {
            category = Resource.sharedInstance().categories[ExpenseCategories[indexPath.item]]
        }
        else {
            category = Resource.sharedInstance().categories[IncomeCategories[indexPath.item]]
        }
        cell.name.text = category!.name
        cell.icon.text = category!.icon
        
        cell.icon.textColor = category!.color
        cell.icon.layer.borderColor = category?.color.cgColor
        cell.icon.layer.borderWidth = 0
        
        if transaction?.categoryId == category?.id {
            cell.icon.layer.borderWidth = 1
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if segmentbtn.selectedSegmentIndex == 0 {
            
            if selectedCategory != "" {
                guard let pCell = collectionView.cellForItem(at: IndexPath(item: ExpenseCategories.index(of: selectedCategory)!, section: 0)) as? CategorySelectionCollectionViewCell else {
                    return
                }
                
                pCell.icon.layer.borderWidth = 0
            }
            
            selectedCategory = ExpenseCategories[indexPath.item]
            
            
            
        }
        else if segmentbtn.selectedSegmentIndex == 1 {
            
            
            if selectedCategory != "" {
                guard let pCell = collectionView.cellForItem(at: IndexPath(item: IncomeCategories.index(of: selectedCategory)!, section: 0)) as? CategorySelectionCollectionViewCell else {
                    return
                }
                
                pCell.icon.layer.borderWidth = 0
            }
            selectedCategory = IncomeCategories[indexPath.item]
        }
        
        
        let cell = collectionView.cellForItem(at: indexPath) as! CategorySelectionCollectionViewCell
        cell.icon.layer.borderWidth = 1
//        cell.icon.layer.borderColor = Resource.sharedInstance().categories[selectedCategory]!.color.cgColor
        
    }
    
    
    
    @IBAction func doneBtnAction(_ sender: UIButton) {
        if sender.tag == 0 {
            pSelectedCategory = selectedCategory
            transaction?.categoryId = selectedCategory
            tableView.reloadData()
            removeView()
        }
        else if sender.tag == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: cells.index(of: "Date")!, section: 0)) as! DefaultTableViewCell
            cell.textview.text = dateformatter.string(from: datepicker.date)
            transaction!.date = datepicker.date
            removeView()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        if sender.tag == 0 {
            transaction!.categoryId = pSelectedCategory
            selectedCategory = pSelectedCategory
            tableView.reloadData()
            removeView()
        }
        else if sender.tag == 1 {
            let cell = tableView.cellForRow(at: IndexPath(row: cells.index(of: "Date")!, section: 0)) as! DefaultTableViewCell
            cell.textview.text = dateformatter.string(from: transaction!.date)
            removeView()
        }
    }
    
    func ViewTap() {
        removeView()
        self.view.endEditing(true)
    }
    
    // Adding Category View

    func addView(_ showView : UIView) {
        CategoryCollectionView.reloadData()
        backView?.addGestureRecognizer(tap)
        self.view.addSubview(backView!)
        showView.alpha = 0
        showView.isHidden = false
        self.view.bringSubview(toFront: showView)
        UIView.animate(withDuration: 0.3, animations: {
            showView.alpha = 1.0
        })
    }
    
    func removeView() {
        self.view.removeGestureRecognizer(tap)
        backView?.removeGestureRecognizer(tap)
        UIView.animate(withDuration: 0.6, animations: {
            self.CategoryView.alpha = 0
            self.DatePickerView.alpha = 0
        }) { (Success) in
            self.CategoryView.isHidden = true
            self.DatePickerView.isHidden = true
            self.backView!.removeFromSuperview()
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
                    if self.isNew {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        if self.cells.contains("Delete") {
                            self.cells.remove(at: self.cells.index(of: "Delete")!)
                            self.navigationItem.rightBarButtonItem = nil
                        }
                        self.tableView.reloadData()
                    }
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            else {
                if (transaction!.transactionById == Resource.sharedInstance().currentUserId || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner) && Resource.sharedInstance().currentWallet!.isOpen {
                    if !cells.contains("Delete") {
                        cells.append("Delete")
                        self.navigationItem.rightBarButtonItem = self.editBtn
                    }
                }
//                let range = NSMakeRange(0, self.tableView.numberOfSections)
//                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections([0], with: .automatic)
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
