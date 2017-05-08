//
//  AddBudgetViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/7/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate {

    
    @IBOutlet weak var CategoryAndMembercollectionview: UICollectionView!
    @IBOutlet weak var CollectionViewHeader: UILabel!
    @IBOutlet weak var SelectionView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var pageHeader: UILabel!
    
    var budget : Budget?
    var transactions = [Transaction]()
    var walletmembers = [User]()
    var categoriesKeys = [String]()
    
    var Add = UIBarButtonItem()
    var Edit = UIBarButtonItem()
    
    var datepicker = UIDatePicker()
    var dateformat = DateFormatter()
    let toolbar = UIToolbar()
    var date = Double()
    
    var isNew = false
    var isEdit = false
    var isCategoryView = false
    
    var selectedCategories = [String]()
    var pselectedCategories = [String]()
    
    var selectedMembers = [String]()
    var pselectedMembers = [String]()
    
    var cells = ["Title","Amount","Category","AssignTo","Date","NoOfDays","Comments"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        
        SelectionView.isHidden = true
        
        categoriesKeys = Array(Resource.sharedInstance().categories.keys)
        
        Add = UIBarButtonItem.init(title: "\u{A009}", style: .plain, target: self, action: #selector(self.AddBudget))
        Add.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        
        Edit = UIBarButtonItem.init(title: "\u{A013}", style: .plain, target: self, action: #selector(self.EditBudget))
        Edit.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        CategoryAndMembercollectionview.dataSource = self
        CategoryAndMembercollectionview.delegate = self
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                self.walletmembers = Resource.sharedInstance().currentWallet!.members
                
                if self.isNew {
                    self.isEdit = true
                    self.navigationItem.rightBarButtonItem = self.Add
                    self.budget = Budget.init(budgetId: "", allocAmount: 0.0, title: "", period: 7, startDate: Date().timeIntervalSince1970, comments: nil, isOpen: true, categoryIDs: [], memberIDs: [], walletID: Resource.sharedInstance().currentWalletID!)
                    
                }
                else {
                    self.selectedMembers = self.budget!.getMemberIDs()
                    self.pselectedMembers = self.selectedMembers
                    self.selectedCategories = self.budget!.getCategoryIDs()
                    self.pselectedCategories = self.selectedCategories
                    self.UpdateCells()
                }
            }
        }
    }
    
    func UpdateCells() {
        self.navigationItem.rightBarButtonItem = nil
        self.cells = ["Title","Amount","Category","AssignTo","Date","NoOfDays"]
        if budget?.comments != nil {
            cells.append("Comments")
        }
        if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && budget!.wallet.isOpen {
            
            self.cells.append("Delete")
            if self.budget!.isOpen {
                self.navigationItem.rightBarButtonItem = self.Edit
            }
        }
        cells.append("Graph")
    }
    
    // Bar Button Actions
    func AddBudget() {
        
        var error = ""
        var errorDis = ""
        
        if budget!.title == "" {
            error = "Error"
            errorDis = "Task Title cannot be empty"
        }
        else if budget!.allocAmount == 0 || budget!.allocAmount == 0.0 {
            error = "Error"
            errorDis = "Amount cannot be empty"
        }
        else if budget!.getCategoryIDs() == [] {
            error = "Error"
            errorDis = "Category cannot be empty"
        }
        else if budget!.members.count == 0 {
            error = "Error"
            errorDis = "Select any member to assign this task"
        }
        
        if error == "" {
            BudgetManager.sharedInstance().addNewBudget(budget!)
            self.navigationController!.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func EditBudget() {
        if isEdit {
            var error = ""
            var errorDis = ""
            
            if budget!.title == "" {
                error = "Error"
                errorDis = "Task Title cannot be empty"
            }
            else if budget!.allocAmount == 0 || budget!.allocAmount == 0.0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if budget!.getCategoryIDs() == [] {
                error = "Error"
                errorDis = "Category cannot be empty"
            }
            else if budget!.members.count == 0 {
                error = "Error"
                errorDis = "Select any member to assign this task"
            }
            
            if error == "" {
                BudgetManager.sharedInstance().updateBudgetInWallet(budget!)
                self.navigationController!.popViewController(animated: true)
            }
            else {
                let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
            
            //     title,Amount, category, assign to / inprogess by / completed by, assign by, date, comments
        else {
            isEdit = true
            Edit.title = "\u{A009}"
            self.pageHeader.text = "EDITING BUDGET"
            cells.remove(at: 4)
            if cells[cells.count-1] == "Delete" {
                cells.remove(at: cells.count-1)
            }
            if !(cells.contains("Comments")) {
                cells.insert("Comments", at: cells.count)
            }
            self.tableview.reloadSections([0], with: .automatic)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // date button actions
    func donepressed(){
        let cell = tableview.cellForRow(at: IndexPath(row: 4, section: 0)) as! DefaultTableViewCell
        cell.textview.text = dateformat.string(from: datepicker.date)
        date = datepicker.date.timeIntervalSince1970
        budget!.startDate = datepicker.date
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        self.view.endEditing(true)
    }

    
    @IBAction func DoneBtnPressed(_ sender: Any) {
        if isCategoryView {
            pselectedCategories = selectedCategories
            for i in 0..<selectedCategories.count {
                budget!.addCategory(selectedCategories[i])
            }
        }
        else {
            pselectedMembers = selectedMembers
            for i in 0..<selectedMembers.count {
                budget!.addMember(selectedMembers[i])
            }
        }
        SelectionView.isHidden = true
        tableview.reloadData()
    }

    @IBAction func CancelBtnPressed(_ sender: Any) {
        if isCategoryView {
            selectedCategories = pselectedCategories
        }
        else {
            selectedMembers = pselectedMembers
        }
        SelectionView.isHidden = true
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count + transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cells.count {
            switch cells[indexPath.row] {
            
            case "Title":
                let cell = tableview.dequeueReusableCell(withIdentifier: "budgetTitleCell") as!     TaskTitleTableViewCell
            
                if budget?.title == nil || budget!.title == "" {
                    cell.taskTitle.text = "Enter Budget Title"
                    cell.taskTitle.textColor = .gray
                }
                else {
                    cell.taskTitle.text = budget!.title
                    cell.taskTitle.textColor = .black
                }
                cell.taskTitle.isEditable = isEdit
                cell.taskTitle.isUserInteractionEnabled = isEdit
                cell.taskTitle.delegate = self
                cell.taskTitle.tag = 1                                      // tag 1 for title
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            
            case "Comments":
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
                if budget?.comments == nil || budget!.comments == "" {
                    cell.textView.text = "Write Here"
                    cell.textView.textColor = .gray
                }
                else {
                    cell.textView.text = budget!.comments
                    cell.textView.textColor = .black
                }
                cell.textView.isUserInteractionEnabled = isEdit
                cell.textView.delegate = self
                cell.textView.tag = 5                                             // tag 5 for comments
            
                cell.textView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
                if cell.textView.contentSize.height > cell.frame.height {
                    cell.frame.size.height += (cell.textView.contentSize.height - cell.frame.height) + 8
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            
            
            case "Category":
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
                cell.name.text = selectedCategories == [] ? "None" : budget!.categories[0].name
                cell.icon.text = selectedCategories == [] ? "" : budget!.categories[0].icon
            
                cell.icon.textColor = selectedCategories == [] ? .black : budget!.categories[0].color
                cell.icon.layer.borderColor = cell.icon.textColor.cgColor
                cell.icon.layer.borderWidth = 1
                cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
                cell.isUserInteractionEnabled = isEdit
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            
                return cell
            
            case "AssignTo":
                let cell = tableview.dequeueReusableCell(withIdentifier: "assignToCell") as! AssignToTableViewCell
            
                cell.addmemberBtn.addTarget(self, action: #selector(self.assignToaddBtnPressed(_:)), for: .touchUpInside)
                cell.membersCollection.dataSource = self
                cell.membersCollection.dataSource = self
                cell.membersCollection.reloadData()
                cell.addmemberBtn.isHidden = isEdit ? false : true
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            
                return cell
            
            case "Delete":
            
                let cell = tableview.dequeueReusableCell(withIdentifier: "deleteCell") as! DeleteTableViewCell
                cell.DeleteBtn.addTarget(nil, action: #selector(self.DeleteTask) , for: .touchUpInside)
            
                return cell
            
            case "Graph":
                let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
                
                cell.title.text = "Pie Chart"
                
                return cell
            
            default:
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
                cell.title.text = cells[indexPath.row]
            
                if cell.title.text == "Amount" {
                    cell.textview.text = budget!.allocAmount != 0.0 ? "\(budget?.allocAmount ?? 0)" : "0"
                    cell.textview.tag = 2                   // amount tag 2
                }
            
                else if cell.title.text == "NoOfDays" {
                    cell.textview.text = "\(budget!.daysInbudget())"
                    cell.textview.tag = 4
                }
                
                else if cell.title.text == "Date" {
                
                    cell.textview.inputView = datepicker
                    cell.textview.text = dateformat.string(from: budget!.startDate)
                    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
                    let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
                    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                    self.toolbar.setItems([cancel,spaceButton,done], animated: false)
                    cell.textview.inputAccessoryView = self.toolbar
                    self.toolbar.backgroundColor = .lightGray
                    cell.textview.isUserInteractionEnabled = true
                    cell.textview.tag = 3                   // Date tag 3
                }
                cell.textview.isEditable = budget!.isOpen
                cell.textview.isUserInteractionEnabled = budget!.isOpen
                cell.textview.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }//Switch End
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TimelineTableViewCell
            let transaction = self.transactions[indexPath.row - cells.count]
            
            cell.categoryIcon.text = transaction.category.icon
            cell.category.text = transaction.category.name
            cell.amount.text = "\(transaction.amount)"
//            cell.imageView?.image = transaction.transactionBy.image != nil ? transaction.transactionBy.image : #imageLiteral(resourceName: "dp-male")
            
            cell.categoryIcon.textColor = transaction.category.color
            cell.categoryIcon.layer.borderColor = cell.categoryIcon.textColor.cgColor
            cell.categoryIcon.layer.borderWidth = 1
            cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEdit {
            if indexPath.row == 2 {
                SelectionView.isHidden = false
                isCategoryView = true
                CollectionViewHeader.text = "SELECT CATEGORY"
                CategoryAndMembercollectionview.reloadData()
            }
        }
        else {
            var error = "Alert" , errorDes = "You Dont Have the right to make Changes"
            if self.navigationItem.rightBarButtonItem != nil {
                errorDes = "Press Edit to make Changes"
            }
            let alert = UIAlertController(title: error, message: errorDes, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //["Title","Amount","Category","AssignTo","Date","NoOfDays","Comments"]
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew {
            return indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 6 ? 70 : 50
        }
        else if !isEdit {
            return indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 6 ? 70 : 50
        }
        else {
            return indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 6 ? 70 : 50
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == CategoryAndMembercollectionview {
            return isCategoryView ? categoriesKeys.count : walletmembers.count
        }
        else {
            return selectedMembers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if collectionView == self.CategoryAndMembercollectionview && isCategoryView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
            
            let category = Resource.sharedInstance().categories[categoriesKeys[indexPath.item]]
            
            cell.name.text = category!.name
            cell.icon.text = category!.icon
            cell.icon.textColor = category!.color
            cell.icon.layer.borderColor = category!.color.cgColor
            
            if selectedCategories.contains(category!.id) {
                cell.icon.layer.borderWidth = 1
            }
            else {
                cell.icon.layer.borderWidth = 0
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
            var user : User?
            if collectionView == self.CategoryAndMembercollectionview {
                user = walletmembers[indexPath.item]
            }
            else {
                user = budget!.members[indexPath.item]
            }
            cell.name.text = user!.userName
            cell.image.image = #imageLiteral(resourceName: "dp-male")
            cell.selectedmember.layer.cornerRadius = 5
            if budget!.getMemberIDs().contains(walletmembers[indexPath.item].getUserID()) && collectionView == self.CategoryAndMembercollectionview {
                cell.selectedmember.isHidden = false
            }
            else {
                cell.selectedmember.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCategoryView {
            let cell = collectionView.cellForItem(at: indexPath) as! CategorySelectionCollectionViewCell
            if selectedCategories.contains(categoriesKeys[indexPath.item]) {
                selectedCategories.remove(at: selectedCategories.index(of: categoriesKeys[indexPath.item])!)
                cell.icon.layer.borderWidth = 0
            }
            else {
                selectedCategories.append(categoriesKeys[indexPath.item])
                cell.icon.layer.borderWidth = 1
            }
        }
        else {
            let cell = collectionView.cellForItem(at: indexPath) as! TaskMembersCollectionViewCell
            if selectedMembers.contains(walletmembers[indexPath.item].getUserID()) {
                selectedMembers.remove(at: selectedMembers.index(of: walletmembers[indexPath.item].getUserID())!)
                cell.selectedmember.isHidden = true
            }
            else {
                selectedMembers.append(walletmembers[indexPath.item].getUserID())
                cell.selectedmember.isHidden = false
            }
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .black
        if textView.tag == 5 {
            if textView.text == "Write Here" {
                textView.text = ""
            }
            else {
                textView.text = budget!.comments
            }
        }
        if textView.tag == 1 {
            if textView.text == "Enter Budget Title" {
                textView.text = ""
            }
            else {
                textView.text = budget!.title
            }
        }
        if textView.tag == 2 {
            textView.text = textView.text == "0" || textView.text == "0.0" ? "" : "\(budget!.allocAmount)"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            budget!.title = textView.text
            textView.text = budget!.title != "" ? budget!.title : "Enter Budget Title"
            textView.textColor = budget!.title != "" ? .black : .gray
        }
        else if textView.tag == 2 {
            budget!.allocAmount = Double(textView.text) ?? 0.0
            textView.text = budget!.allocAmount == 0.0 ? "0" : "\(budget!.allocAmount)"
        }
        else if textView.tag == 4 {
            budget!.period = Int(textView.text)! ?? 0
        }
        else if textView.tag == 5 {
            budget!.comments = textView.text
            textView.text = budget?.comments != nil ? budget!.comments : "Write Here"
        }
    }
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        SelectionView.isHidden = false
        CollectionViewHeader.text = "SELECT MEMBERS"
        isCategoryView = false
        CategoryAndMembercollectionview.reloadData()
    }
    
    // Delete Task
    func DeleteTask() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this Budget", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
        //        print("Kar de Delete")
        BudgetManager.sharedInstance().removeBudgetFromWallet(budget!)
        self.navigationController!.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
        //        print("Nhn Kr Delete")
    }

    
    
}
