//
//  AddTaskViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITableViewDataSource , UITableViewDelegate , UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource, TaskDelegate, WalletMemberDelegate, TaskMemberDelegate, WalletDelegate{

    @IBOutlet weak var collectionviewTitle: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var TitleForPage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var SelectionView: UIView!
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!

    var Add = UIBarButtonItem()
    var Edit = UIBarButtonItem()
    
    var datepicker = UIDatePicker()
    var dateformatter = DateFormatter()
    let toolbar = UIToolbar()
    var date : Double?
    
    var categoriesKeys = [String]()
    var walletmembers : [User]?
    
    var cells = ["Title","Amount","Category","Date","Comments"]
    
    var task : Task?
    var isNew : Bool?
    var isEdit = false
    var isCategoryView = true
    
    var selectedCategory = String()
    var pselectedCategory = String()
    
    var selectedMembers = [String]()
    var pselecctedMembers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        toolbar.sizeToFit()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        collectionview.dataSource = self
        collectionview.delegate = self
        
        categoriesKeys = Array(Resource.sharedInstance().categories.keys)
        
        acceptBtn.layer.cornerRadius = acceptBtn.layer.frame.height/2
        rejectBtn.layer.cornerRadius = rejectBtn.layer.frame.height/2
        
        acceptBtn.layer.borderWidth = 1
        rejectBtn.layer.borderWidth = 1
        
        acceptBtn.layer.borderColor = acceptBtn.titleLabel!.textColor.cgColor
        rejectBtn.layer.borderColor = rejectBtn.titleLabel!.textColor.cgColor
        
        acceptBtn.isHidden = true
        rejectBtn.isHidden = true
        
        SelectionView.isHidden = true
        
        Add = UIBarButtonItem.init(title: "\u{A009}", style: .plain, target: self, action: #selector(self.AddTask))
        Add.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        
        Edit = UIBarButtonItem.init(title: "\u{A013}", style: .plain, target: self, action: #selector(self.EditTask))
        Edit.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        Delegate.sharedInstance().addTaskDelegate(self)
        Delegate.sharedInstance().addTaskMemberDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                
                self.walletmembers = Resource.sharedInstance().currentWallet!.members

                // Creating New Task
                if self.isNew! {
                    self.isEdit = true
                    self.task = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: nil, dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: Resource.sharedInstance().currentUserId!, status: .open, doneByID: nil, memberIDs: [], walletID:Resource.sharedInstance().currentWalletID!)
                    self.navigationItem.rightBarButtonItem = self.Add
                    
                    if Resource.sharedInstance().currentWallet!.isPersonal {
                        self.task!.addMember(Resource.sharedInstance().currentUserId!)
                        self.task!.doneByID = Resource.sharedInstance().currentUserId
                    }
                    else {
                        self.cells.append("AssignTo")
                    }
                }
                    
                // Previous Tasks Viewing
                else {
                    self.selectedCategory = self.task!.categoryID
                    self.pselectedCategory = self.selectedCategory
                    self.selectedMembers = self.task!.memberIDs
                    self.pselecctedMembers = self.selectedMembers
                    self.updateCells()
                }
            }
        }
        
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // date button actions
    func donepressed(){
        let cell = tableview.cellForRow(at: IndexPath(row: 3, section: 0)) as! DefaultTableViewCell
        cell.textview.text = dateformatter.string(from: datepicker.date)
        date = datepicker.date.timeIntervalSince1970
        task!.dueDate = datepicker.date
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        self.view.endEditing(true)
    }
    
    // Bar Button Actions
    func AddTask() {
        
        var error = ""
        var errorDis = ""
        
        if task!.title == "" {
            error = "Error"
            errorDis = "Task Title cannot be empty"
        }
        else if task!.amount == 0 || task!.amount == 0.0 {
            error = "Error"
            errorDis = "Amount cannot be empty"
        }
        else if task!.categoryID == "" {
            error = "Error"
            errorDis = "Category cannot be empty"
        }
        else if task!.members.count == 0 {
            error = "Error"
            errorDis = "Select any member to assign this task"
        }
        
        if error == "" {
            TaskManager.sharedInstance().addNewTask(task!)
            if Resource.sharedInstance().currentWallet!.isPersonal {
                TaskManager.sharedInstance().taskStatusChanged(task!)
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
    
    func EditTask() {
        if isEdit {
            var error = ""
            var errorDis = ""
            
            if task!.title == "" {
                error = "Error"
                errorDis = "Task Title cannot be empty"
            }
            else if task!.amount == 0 || task!.amount == 0.0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if task!.categoryID == "" {
                error = "Error"
                errorDis = "Category cannot be empty"
            }
            else if task!.members.count == 0 {
                error = "Error"
                errorDis = "Select any member to assign this task"
            }
            
            if error == "" {
                TaskManager.sharedInstance().updateTask(task!)
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
            self.TitleForPage.text = "EDITING TASK"
            cells.remove(at: 4)
            if cells[cells.count-1] == "Delete" {
                cells.remove(at: cells.count-1)
            }
            if !(cells.contains("Comments")) {
                cells.insert("Comments", at: cells.count)
            }
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
            self.tableview.reloadSections([0], with: .automatic)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.row] {
            
        case "Title":
            let cell = tableview.dequeueReusableCell(withIdentifier: "taskTitleCell") as! TaskTitleTableViewCell
            
            if task?.title == nil || task!.title == "" {
                cell.taskTitle.text = "Enter Title"
                cell.taskTitle.textColor = .gray
            }
            else {
                cell.taskTitle.text = task!.title
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
            if task?.comment == nil || task!.comment == "" {
                cell.textView.text = "Write Here"
                cell.textView.textColor = .gray
            }
            else {
                cell.textView.text = task!.title
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
            
            cell.name.text = selectedCategory == "" ? "None" : task!.category!.name
            cell.icon.text = selectedCategory == "" ? "" : task!.category!.icon
            
            cell.icon.textColor = task!.category!.color
            cell.icon.layer.borderColor = task!.category!.color.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
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
            
        case "Created By":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionbyCell") as! TransactionByTableViewCell
            cell.title.text = "Assign By "
            cell.name.text = task!.creator!.userName
            let type = Resource.sharedInstance().currentWallet?.memberTypes[(task!.creatorID)]
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
            cell.isUserInteractionEnabled = false
            return cell
            
        case "In Progress By":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionbyCell") as! TransactionByTableViewCell
            cell.title.text = task!.status == .open ? "In Progress By " : "Completed By"
            cell.name.text = task!.doneBy?.userName
            let type = Resource.sharedInstance().currentWallet?.memberTypes[(task!.doneByID)!]
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
            cell.isUserInteractionEnabled = false
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textview.text = task!.amount != 0.0 ? "\(task?.amount ?? 0)" : "0"
                cell.textview.tag = 2                   // amount tag 2
            }
                
            else if cell.title.text == "Date" {
                
                cell.textview.inputView = datepicker
                cell.textview.text = dateformatter.string(from: task!.dueDate)
                let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
                let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
                let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                self.toolbar.setItems([cancel,spaceButton,done], animated: false)
                cell.textview.inputAccessoryView = self.toolbar
                self.toolbar.backgroundColor = .lightGray
                cell.textview.isUserInteractionEnabled = true
                cell.textview.tag = 3                   // Date tag 3
            }
            cell.textview.isEditable = task!.status == .completed ? false : isNew! || isEdit
            cell.textview.isUserInteractionEnabled = task!.status == .completed ? false : isNew! || isEdit
            cell.textview.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }//Switch End
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isEdit {
            if indexPath.item == 2 {
                SelectionView.isHidden = false
                isCategoryView = true
                collectionviewTitle.text = "SELECT CATEGORY"
                collectionview.reloadData()
            }
        }
        else {
            var error = "Alert" , errorDes = "You Dont Have the right to make Changes"
            if cells.contains("Delete") {
                errorDes = "Press Edit to make Changes"
            }
            let alert = UIAlertController(title: error, message: errorDes, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    Title,Amount, category, assign to / inprogess by / completed by, assign by, date, comments
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew! {
            return indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5 ? 70 : 50
        }
        else if !isEdit {
            return indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 6 ? 70 : 50
        }
        else {
            return indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 5 ? 70 : 50
        }
    }

//    TextView Delegates
//    Title tag == 1
//    Amount tag == 2
//    comment tag == 5
    
    func textViewDidChange(_ textView: UITextView) {

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .black
        if textView.tag == 5 {
            if textView.text == "Write Here" {
                textView.text = ""
            }
            else {
                textView.text = task!.comment
            }
        }
        if textView.tag == 1 {
            if textView.text == "Enter Title" {
                textView.text = ""
            }
            else {
                textView.text = task!.title
            }
        }
        if textView.tag == 2 {
            textView.text = textView.text == "0" ? "" : "\(task!.amount)"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            task!.title = textView.text
            textView.text = task?.title != nil || task!.title != "" ? task!.title : "Enter Title"
        }
        else if textView.tag == 2 {
            task!.amount = Double(textView.text) ?? 0.0
            textView.text = task!.amount == 0.0 ? "0" : "\(task!.amount)"
        }
        else if textView.tag == 5 {
            task!.comment = textView.text
            textView.text = task?.comment != nil || task!.comment != "" ? task!.comment : "Write Here"
        }
    }
    
    // Collection View for categories and WalletMembers
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionview && isCategoryView {
            return categoriesKeys.count
        }
        else if collectionView == self.collectionview && !isCategoryView {
            return walletmembers!.count
        }
        else {
            return task!.members.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionview && isCategoryView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
            
            let category = Resource.sharedInstance().categories[categoriesKeys[indexPath.item]]
            
            cell.name.text = category!.name
            cell.icon.text = category!.icon
            cell.icon.textColor = category!.color
            cell.icon.layer.borderColor = category!.color.cgColor
            
            if selectedCategory == category!.id {
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
            if collectionView == self.collectionview {
                user = walletmembers![indexPath.item]
            }
            else {
                user = task!.members[indexPath.item]
            }
            cell.name.text = user!.userName
            cell.image.image = #imageLiteral(resourceName: "dp-male")
            cell.selectedmember.layer.cornerRadius = 5
            if task!.memberIDs.contains(walletmembers![indexPath.item].getUserID()) && collectionView == self.collectionview {
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
            if selectedCategory != "" {
                guard let cell = collectionView.cellForItem(at: IndexPath(item: categoriesKeys.index(of: selectedCategory)!, section: 0)) as? CategorySelectionCollectionViewCell else {
                    let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCollectionViewCell
                    cell!.icon.layer.borderWidth = 1
                    selectedCategory = categoriesKeys[indexPath.item]
                    return
                }
                cell.icon.layer.borderWidth = 0
            }
            
            let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCollectionViewCell
            cell!.icon.layer.borderWidth = 1
            selectedCategory = categoriesKeys[indexPath.item]
        }
        
        else {
            let cell = collectionView.cellForItem(at: indexPath) as? TaskMembersCollectionViewCell
            if cell!.selectedmember.isHidden {
                cell!.selectedmember.isHidden = false
                selectedMembers.append(walletmembers![indexPath.item].getUserID())
                print("\(walletmembers![indexPath.item].userName)")
            }
            else {
                cell!.selectedmember.isHidden = true
                selectedMembers.remove(at: selectedMembers.index(of: walletmembers![indexPath.item].getUserID())!)
                print("\(walletmembers![indexPath.item].userName)")
            }
        }
        
    }
    
    
    @IBAction func AcceptBtnPressed(_ sender: Any) {
        if acceptBtn.titleLabel!.text == "ACCEPT" {
            task!.doneByID = Resource.sharedInstance().currentUserId
        }
        else if acceptBtn.titleLabel!.text == "COMPLETED" {
            task!.status = .completed
        }
        updateCells()
        TaskManager.sharedInstance().taskStatusChanged(task!)
        TaskManager.sharedInstance().updateTask(task!)
    }
    
    @IBAction func RejectBtnPressed(_ sender: Any) {

        if rejectBtn.titleLabel!.text == "REJECT" {
            task!.removeMember(Resource.sharedInstance().currentUserId!)
        }
        else if rejectBtn.titleLabel!.text == "NOT DOING" {
            if Resource.sharedInstance().currentWallet!.isPersonal{
                TaskManager.sharedInstance().deleteTask(task!)
            }
            else {
                task!.doneByID = nil
                task!.status = .open
            }
            TaskManager.sharedInstance().taskStatusChanged(task!)
            TaskManager.sharedInstance().updateTask(task!)
            updateCells()
        }
    }
    
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        SelectionView.isHidden = false
        collectionviewTitle.text = "SELECT MEMBERS"
        isCategoryView = false
        collectionview.reloadData()
    }
    
    // Delete Task
    func DeleteTask() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this tansaction", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
//        print("Kar de Delete")
        TaskManager.sharedInstance().deleteTask(task!)
        self.navigationController!.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
//        print("Nhn Kr Delete")
    }

    //Collection View Buttons Actions
    @IBAction func DoneButton(_ sender: Any) {
        if isCategoryView {
            pselectedCategory = selectedCategory
            task!.categoryID = selectedCategory
        }
        else {
            pselecctedMembers = selectedMembers
            task!.memberIDs = selectedMembers
        }
        SelectionView.isHidden = true
        tableview.reloadData()
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        if isCategoryView {
            selectedCategory = pselectedCategory
        }
        else {
            selectedMembers = pselecctedMembers
        }
        SelectionView.isHidden = true
        tableview.reloadData()
    }
    
    // Task Delegate
    func taskAdded(_ task: Task) {
    }
    
    func taskDeleted(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            if task.id == self.task!.id {
                let alert = UIAlertController(title: "Alert", message: "The Task Has Been Deleted", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (flag) in
                    self.navigationController?.popViewController(animated: true)
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func taskUpdated(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            if task.id == self.task!.id {
                self.task! = task
                self.updateCells()
                self.tableview.reloadSections([0], with: .automatic)
            }
        }
    }
    
    //Wallet members
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            if member.getUserID() == Resource.sharedInstance().currentUserId {
                self.navigationController?.popViewController(animated: true)
            }
            if self.task!.memberIDs.contains(member.getUserID()) {
                self.task!.memberIDs.remove(at: self.task!.memberIDs.index(of: member.getUserID())!)
            }
            self.walletmembers = Resource.sharedInstance().currentWallet!.members
            if !SelectionView.isHidden && !isCategoryView {
                self.collectionview.reloadData()
            }
        }
        
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            self.walletmembers = Resource.sharedInstance().currentWallet!.members
            if !SelectionView.isHidden && !isCategoryView {
                self.collectionview.reloadData()
            }
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            self.walletmembers = Resource.sharedInstance().currentWallet!.members
            if member.getUserID() == Resource.sharedInstance().currentUserId && !(isNew!) {
                self.updateCells()
                self.tableview.reloadData()
            }
        }
    }
    
    //Task Member Delegates
    func memberLeft(_ member: User, task: Task) {
        if task.id == self.task!.id {
            self.task!.memberIDs = task.memberIDs
            self.tableview.reloadData()
        }
    }
    
    func memberAdded(_ member: User, task: Task) {
        if task.id == self.task!.id {
            self.task!.memberIDs = task.memberIDs
            self.tableview.reloadData()
        }
    }
    
    //wallet Delegate
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            if !wallet.isOpen {
                if self.isNew! {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    SelectionView.isHidden = true
                    self.isEdit = false
                    updateCells()
                    self.tableview.reloadData()
                }
            }
            else if wallet.isOpen {
                    SelectionView.isHidden = true
                    self.isEdit = false
                    updateCells()
                    self.tableview.reloadData()
            }
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func updateCells() {
        
        self.navigationItem.rightBarButtonItem = nil
        
        self.cells = ["Title","Amount","Category","Created By","Date"]
        
        if self.task!.status == .open {
            if self.task!.doneByID == nil || self.task!.doneByID == "" {
                self.cells.insert("AssignTo", at: 3)
            }
            else {
                self.cells.insert("In Progress By", at: 3)
            }
        }
        else if self.task!.status == .completed {
            self.cells.insert("In Progress By", at: 3)
        }
        
        self.TitleForPage.text = "TASK DETAILS"
        
        if self.task!.comment != nil {
            self.cells.append("Comments")
        }
        
        if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner || self.task!.creatorID == Resource.sharedInstance().currentUserId) && task!.wallet!.isOpen {
            
            self.cells.append("Delete")
            if self.task!.status == .open {
                self.navigationItem.rightBarButtonItem = self.Edit
            }
        }
        if self.task!.status == .open && (self.task?.doneByID == "" || self.task?.doneByID == nil) && self.task!.memberIDs.contains(Resource.sharedInstance().currentUserId!) {
            self.acceptBtn.setTitle("ACCEPT", for: .normal)
            self.rejectBtn.setTitle("REJECT", for: .normal)
            self.acceptBtn.isHidden = false
            self.rejectBtn.isHidden = false
        }
        if self.task!.status == .open && self.task!.doneByID == Resource.sharedInstance().currentUserId! {
            self.acceptBtn.setTitle("COMPLETED", for: .normal)
            self.rejectBtn.setTitle("NOT DOING", for: .normal)
            self.acceptBtn.isHidden = false
            self.rejectBtn.isHidden = false
        }
        if self.task!.status == .completed || !(self.task!.wallet!.isOpen) {
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
        }
    }

}
