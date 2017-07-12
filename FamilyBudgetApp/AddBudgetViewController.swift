//
//  AddBudgetViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/7/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, BudgetDelegate, WalletMemberDelegate {

    
    @IBOutlet weak var CategoryAndMembercollectionview: UICollectionView!
    @IBOutlet weak var CollectionViewHeader: UILabel!
    @IBOutlet weak var SelectionView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var pageHeader: UILabel!
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var DaysPicker: UIPickerView!
    @IBOutlet weak var DateAndDaysView: UIView!
    
    var budget : Budget?
    
    var isDataAvailable = false
    
    var backView = UIView()
    
    var walletmembers = [User]()
    var categoriesKeys = [String]()
    
    var Add = UIBarButtonItem()
    
    var dateformat = DateFormatter()
    
    var isDatePicker = true
    var isCategoryView = false
    
    var isNew = false
    var isEdit = false
    var isKeyboardOpen = false
    
    var selectedCategories = [String]()
    var pselectedCategories = [String]()
    
    var selectedMembers = [String]()
    var pselectedMembers = [String]()
    
    var selectedIndex : Int = 0
    
    var cells = ["Title","Amount","Category","AssignTo","Date","NoOfDays","Comments"]
    var Days = [7,15,30]
    
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        backView = UIView(frame: self.view.frame)
        backView.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        backView.addGestureRecognizer(tap)
        backView.backgroundColor = .lightGray
        backView.alpha = 0.5
        backView.isUserInteractionEnabled = true
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        DateAndDaysView.isHidden = true
        SelectionView.isHidden = true
        
        categoriesKeys = Array(Resource.sharedInstance().categories.keys)
        
        Add = UIBarButtonItem.init(title: "\u{A009}", style: .plain, target: self, action: #selector(self.AddBudget))
        Add.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        self.DaysPicker.dataSource = self
        self.DaysPicker.delegate = self
        self.DaysPicker.backgroundColor = .white
        
        CategoryAndMembercollectionview.dataSource = self
        CategoryAndMembercollectionview.delegate = self
        
        Delegate.sharedInstance().addBudgetDelegate(self)
        
        self.navigationItem.rightBarButtonItem = self.Add
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                self.selectedMembers = []
                self.selectedCategories = []
                self.pselectedMembers = []
                self.pselectedCategories = []
                
                BudgetObserver.sharedInstance().startObserving(BudgetsOf: Resource.sharedInstance().currentWallet!)
                
                self.walletmembers = Resource.sharedInstance().currentWallet!.members
                
                if Resource.sharedInstance().currentWallet!.isPersonal {
                    self.cells.remove(at: self.cells.index(of: "AssignTo")!)
                }
                
                if self.isNew {
                    self.isEdit = true
                    self.budget = Budget.init(budgetId: "", allocAmount: 0.0, title: "", period: 7, startDate: Date().timeIntervalSince1970, comments: nil, isOpen: true, categoryIDs: [], memberIDs: [], walletID: Resource.sharedInstance().currentWalletID!)
                    if Resource.sharedInstance().currentWallet!.isPersonal {
                        self.budget!.addMember(Resource.sharedInstance().currentUserId!)
                    }
                }
                else {
                    self.selectedMembers = self.budget!.getMemberIDs()
                    self.pselectedMembers = self.selectedMembers
                    self.selectedCategories = self.budget!.getCategoryIDs()
                    self.pselectedCategories = self.selectedCategories
                }
            }
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
    
    func ViewTap() {
        removeView()
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Days[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    // Bar Button Actions
    func AddBudget() {
        
        self.view.endEditing(true)
        
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
            if isNew {
                BudgetManager.sharedInstance().addNewBudget(budget!)
            }
            else {
                BudgetManager.sharedInstance().addCategoriesToBudget(budget!.id, categories: selectedCategories)
                BudgetManager.sharedInstance().addMembersToBudget(budget!.id, members: selectedMembers)
                BudgetManager.sharedInstance().updateBudgetInWallet(budget!)
            }
            self.navigationController!.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func DoneBtnPressed(_ sender: UIButton) {
        // Tag 0 for Category and members
        if sender.tag == 0 {
            if isCategoryView {
                pselectedCategories = selectedCategories
                for i in 0..<selectedCategories.count {
                    budget!.addCategory(selectedCategories[i])
                }
//                let bCategories = budget!.getCategoryIDs()
//                if selectedCategories.contains(where: { (_category) -> Bool in
//                    return _category
//                })
//                
                for i in 0..<budget!.getCategoryIDs().count {
                    if i < budget!.getCategoryIDs().count {
                        if !selectedCategories.contains(where: { (_category) -> Bool in
                            return _category == budget!.categories[i].id
                        }){
                            budget!.removeCategory(budget!.categories[i].id)
                        }
                    }
                }
            }
            else {
                pselectedMembers = selectedMembers
                for i in 0..<selectedMembers.count {
                    budget!.addMember(selectedMembers[i])
                }
            }
            removeView()
        }
            
        else {
            if isDatePicker {
                let cell = tableview.cellForRow(at: IndexPath(row: 4, section: 0)) as! DefaultTableViewCell
                cell.textview.text = dateformat.string(from: DatePicker.date)
                budget!.startDate = DatePicker.date
            }
            else {
                let cell = tableview.cellForRow(at: IndexPath(row: cells.index(of: "NoOfDays")!, section: 0)) as! DefaultTableViewCell
                cell.textview.text = "\(Days[selectedIndex])"
                budget!.period = Days[selectedIndex]
            }
            removeView()
        }
        tableview.reloadData()
    }

    @IBAction func CancelBtnPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            if isCategoryView {
                selectedCategories = pselectedCategories
            }
            else {
                selectedMembers = pselectedMembers
            }
            removeView()
        }
        else {
            if isDatePicker {
                let cell = tableview.cellForRow(at: IndexPath(row: 4, section: 0)) as! DefaultTableViewCell
                cell.textview.text = dateformat.string(from: budget!.startDate)
            }
            else {
                let cell = tableview.cellForRow(at: IndexPath(row: cells.index(of: "NoOfDays")!, section: 0)) as! DefaultTableViewCell
                cell.textview.text = "\(budget!.period)"
            }
            removeView()
        }
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            
                return cell

            
            default:
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
                cell.title.text = cells[indexPath.row]
            
                if cell.title.text == "Amount" {
                    cell.textview.text = "\(budget!.allocAmount)"
                    cell.textview.isEditable = isEdit
                    cell.textview.isUserInteractionEnabled = isEdit
                    
                    cell.textview.tag = 2                   // amount tag 2
                }
            
                else if cell.title.text == "NoOfDays" {
                    cell.textview.text = "\(budget!.period)"
                    cell.textview.isUserInteractionEnabled = false
                    cell.textview.isEditable = false
                }
                
                else if cell.title.text == "Date" {
                    cell.textview.text = dateformat.string(from: budget!.startDate)
                    cell.textview.isUserInteractionEnabled = false
                    cell.textview.isEditable = false// Date tag 3
                }
                
                cell.textview.delegate = self
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }//Switch End
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEdit {
            if indexPath.row == 2 {
                isCategoryView = true
                CollectionViewHeader.text = "SELECT CATEGORY"
                addView(SelectionView)
                CategoryAndMembercollectionview.reloadData()
            }
            else if cells[indexPath.row] == "Date" {
                isDatePicker = true
                addView(DateAndDaysView)
            }
            else if cells[indexPath.row] == "NoOfDays" {
                isDatePicker = false
                addView(DateAndDaysView)
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
        return cells[indexPath.row] == "Category" || cells[indexPath.row] == "Comments" ? 70 : cells[indexPath.row] == "AssignTo" ? 80 : 50
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
            cell.selectedmember.layer.borderWidth = 1
            cell.selectedmember.layer.borderColor = darkThemeColor.cgColor
            cell.selectedmember.layer.cornerRadius = cell.selectedmember.frame.width / 2
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
            cell.selectedmember.layer.borderWidth = 1
            cell.selectedmember.layer.borderColor = darkThemeColor.cgColor
            cell.selectedmember.layer.cornerRadius = cell.selectedmember.frame.width / 2
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
            UIView.animate(withDuration: 0.6) {
                self.view.frame.origin.y -= self.SizeOfKeyboard
            }
        }
        else if textView.tag == 1 {
            if textView.text == "Enter Budget Title" {
                textView.text = ""
            }
            else {
                textView.text = budget!.title
            }
        }
        else if textView.tag == 2 {
            textView.text = textView.text == "0" || textView.text == "0.0" ? "" : floor(budget!.allocAmount) == budget!.allocAmount ? "\(Int(budget!.allocAmount))" : "\(budget!.allocAmount)"
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
        else if textView.tag == 5 {
            budget!.comments = textView.text
            textView.text = budget?.comments != nil ? budget!.comments : "Write Here"
            UIView.animate(withDuration: 0.6) {
                self.view.frame.origin.y += self.SizeOfKeyboard
            }
        }
    }
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        CollectionViewHeader.text = "SELECT MEMBERS"
        isCategoryView = false
        addView(SelectionView)
        CategoryAndMembercollectionview.reloadData()
    }
    
    func addView(_ showView : UIView) {
        self.CategoryAndMembercollectionview.reloadData()
        view.addSubview(backView)
        DaysPicker.isHidden = isDatePicker
        showView.isHidden = false
        self.view.bringSubview(toFront: showView)
        
        if showView == DateAndDaysView {
//            showView.fra -= showView.frame.size.width
            UIView.animate(withDuration: 0.6, animations: {
                showView.frame.origin.y -= showView.frame.size.width
            })
        }
        else {
            showView.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {
                showView.alpha = 1.0
            })
        }
    }
    
    func removeView() {
        self.view.removeGestureRecognizer(tap)
        if self.DateAndDaysView.isHidden {
            UIView.animate(withDuration: 0.4, animations: {
                self.SelectionView.alpha = 1.0
            })
            self.SelectionView.isHidden = true
        }
        else if self.SelectionView.isHidden {
            UIView.animate(withDuration: 0.6, animations: {
                self.DateAndDaysView.frame.origin.y += self.DateAndDaysView.frame.size.width
            })
            self.DateAndDaysView.isHidden = true
        }
        self.backView.removeFromSuperview()
    }

    //Budget Delegates
    func budgetAdded(_ budget: Budget) {
    }
    
    func budgetDeleted(_ budget: Budget) {
        if isDataAvailable {
            if self.budget!.id == budget.id {
                let alert = UIAlertController(title: "Alert", message: "This Budget Has been deleted", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (flag) in
                    self.navigationController?.popViewController(animated: true)
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)

            }
        }
    }
    
    func budgetUpdated(_ budget: Budget) {
        if isDataAvailable {
            if self.budget!.id == budget.id {
                let alert = UIAlertController(title: "Alert", message: "This Budget Has been Updated", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (flag) in
                    self.budget! = budget
                    self.tableview.reloadData()
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //Wallet mnember delegate
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if isDataAvailable{
            if wallet.id == Resource.sharedInstance().currentWalletID! {
                for i in 0..<walletmembers.count {
                    if walletmembers[i].getUserID() == member.getUserID() {
                        walletmembers.remove(at: i)
                        break
                    }
                }
                if !isCategoryView {
                    CategoryAndMembercollectionview.reloadData()
                }
            }
        }
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        if isDataAvailable{
            if wallet.id == Resource.sharedInstance().currentWalletID! {
                if !walletmembers.contains(where: { (_user) -> Bool in
                    return _user.getUserID() == member.getUserID()
                }){
                    walletmembers.append(member)
                }
                if !isCategoryView {
                    CategoryAndMembercollectionview.reloadData()
                }
            }
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if isDataAvailable{
            if wallet.id == Resource.sharedInstance().currentWalletID! {
                for i in 0..<walletmembers.count {
                    if walletmembers[i].getUserID() == member.getUserID() {
                        walletmembers[i] = member
                        break
                    }
                }
                if !isCategoryView {
                    CategoryAndMembercollectionview.reloadData()
                }
            }
        }
    }
    
}
