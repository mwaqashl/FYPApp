//
//  AddTaskViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITableViewDataSource , UITableViewDelegate , UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource, TaskDelegate{

    
    @IBOutlet weak var TitleForPage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    //Collection View
    @IBOutlet weak var membersCollectionView: UICollectionView!             // to display wallet members
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var CategoryView: UIView!
    @IBOutlet var MemberView: UIView!
    
    @IBOutlet weak var AddTaskBtn: UIBarButtonItem!
    
    var Add = UIBarButtonItem()
    var Edit = UIBarButtonItem()
    
    var datepicker = UIDatePicker()
    var dateformatter = DateFormatter()
    let toolbar = UIToolbar()
    var date : Double?
    
    var categoriesKeys = [String]()
    var TaskCategoryID : String? = nil
    
    var cells = ["Title","Amount","Category","Date","AssignTo"]
    
    var task : Task?
    var isNew : Bool?
    var isEdit = false
    var walletmembers : [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        toolbar.sizeToFit()
        
        
        tableview.delegate = self
        tableview.dataSource = self
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        walletmembers = Resource.sharedInstance().currentWallet!.members
        
        categoriesKeys = Array(Resource.sharedInstance().categories.keys)
        
        acceptBtn.layer.cornerRadius = acceptBtn.layer.frame.height/2
        rejectBtn.layer.cornerRadius = rejectBtn.layer.frame.height/2
        
        acceptBtn.layer.borderWidth = 1
        rejectBtn.layer.borderWidth = 1
        
        acceptBtn.layer.borderColor = acceptBtn.titleLabel!.textColor.cgColor
        rejectBtn.layer.borderColor = rejectBtn.titleLabel!.textColor.cgColor
        
        acceptBtn.isHidden = true
        rejectBtn.isHidden = true
        
        Add = UIBarButtonItem.init(title: "Add", style: .plain, target: self, action: #selector(self.AddTask))
        Edit = UIBarButtonItem.init(title: "Edit", style: .plain, target: self, action: #selector(self.EditTask))
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                
                // Creating New Task
                
                if self.isNew! {
                    self.task = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: nil, dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: Resource.sharedInstance().currentUserId!, status: .open, doneByID: nil, memberIDs: [], walletID:Resource.sharedInstance().currentWalletID!)
                    self.cells.insert("Comments", at: 4)
                    self.navigationItem.rightBarButtonItem = self.Add
                }
                    
                    // Previous Tasks Viewing
                    
                else if !(self.isNew!) {
                    
//                    title,Amount, category, assign to / inprogess by / completed by, assign by, date, comments
                    self.cells = ["Title","Amount","Category","Created By","Date"]
                    
                    if self.task!.status == .open {
                        if self.task!.doneByID == nil || self.task!.doneByID == "" {
                            self.cells.insert("AssignTo", at: 3)
                        }
                        else if self.task!.doneByID != nil {
                            self.cells.insert("In Progress By", at: 3)
                        }
                    }
                    else if self.task!.status == .completed {
                        self.cells.insert("In Progress By", at: 3)
                    }
                    
                    self.navigationItem.rightBarButtonItem = self.Edit
                    self.TitleForPage.text = "TASK DETAILS"
                    
                    self.TaskCategoryID = self.task!.categoryID
                    if self.task!.comment != nil || self.task!.comment != "" {
                        self.cells.append("Comments")
                    }
                    
                    
                    self.AddTaskBtn.title = "\u{A013}"
                    if Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner || self.task!.creatorID == Resource.sharedInstance().currentUserId {
                        
                        
                        self.cells.append("Delete")
                    }
                    if self.task!.status == .open && (self.task?.doneByID == "" || self.task?.doneByID == nil) && self.task!.memberIDs.contains(Resource.sharedInstance().currentUserId!) {
                        self.acceptBtn.isHidden = false
                        self.rejectBtn.isHidden = false
                    }
                    if self.task!.status == .open && self.task!.doneByID == Resource.sharedInstance().currentUserId! {
                        self.acceptBtn.setTitle("COMPLETED", for: .normal)
                        self.rejectBtn.setTitle("NOT DOING", for: .normal)
                        self.acceptBtn.isHidden = false
                        self.rejectBtn.isHidden = false
                    }
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
            self.TitleForPage.text = "EDITING TASK"
            cells.remove(at: 4)
            if cells[cells.count-1] == "Delete" {
                cells.remove(at: cells.count-1)
            }
            if !(cells.contains("Comments")) {
                cells.insert("Comments", at: cells.count-1)
            }
            self.tableview.reloadSections([0], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(cells.count)
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
            cell.taskTitle.isEditable = isNew! || isEdit ? true : false
            cell.taskTitle.isUserInteractionEnabled = isNew! || isEdit ? true : false
            cell.taskTitle.delegate = self
            cell.taskTitle.tag = 1                  // tag 1 for title
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            return cell
            
        case "Comments":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
            if task?.title == nil || task!.title == "" {
                cell.textView.text = "Write Here"
                cell.textView.textColor = .gray
            }
            else {
                cell.textView.text = task!.title
                cell.textView.textColor = .black
            }
            cell.textView.isUserInteractionEnabled = isNew! || isEdit ? true : false
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
            
            cell.name.text = TaskCategoryID == nil ? "None" : task!.category!.name
            cell.icon.text = TaskCategoryID == nil ? "" : task?.category!.icon
            
            cell.icon.backgroundColor = .white
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
            cell.addmemberBtn.isHidden = isNew! || isEdit ? false : true
            
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
                cell.textview.text = task?.amount != 0.0 ? "\(task?.amount ?? 0)" : "0"
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
                cell.textview.tag = 3
            }
            cell.textview.isEditable = task!.status == .completed ? false : (isNew! || isEdit) ? true : false
            cell.textview.isUserInteractionEnabled = task!.status == .completed ? false : (isNew! || isEdit) ? true : false
            cell.textview.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }//Switch End
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 && isNew! {
            addView(view: CategoryView)
        }
        else if indexPath.row == 2 && isEdit {
            addView(view: CategoryView)
        }
        
        var error = "Alert" , errorDes = "You Dont Have the right to make Changes"
        if cells.contains("Delete") {
            errorDes = "Press Edit to make Changes"
        }
        let alert = UIAlertController(title: error, message: errorDes, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
        }
        if textView.tag == 1 {
            if textView.text == "Enter Title" {
                textView.text = ""
            }
        }
        if textView.tag == 2 {
            textView.text = textView.text == "0" ? "" : "\(task!.amount)"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            task!.title = textView.text
            textView.text = task?.title != nil || task?.title != "" ? task?.title : "Enter Title"
        }
        else if textView.tag == 2 {
            task!.amount = Double(textView.text) ?? 0.0
            textView.text = "\(task!.amount)"
        }
        else if textView.tag == 5 {
            task!.comment = textView.text
            textView.text = task?.comment != nil || task?.comment != "" ? task?.comment : "Write Here"
        }
    }
    
    // Collection View for categories and WalletMembers
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categoriesKeys.count
        }
        else if collectionView == membersCollectionView {
            return (walletmembers?.count)!
        }
        else {
            if task!.status == .open {
                if task!.doneByID == nil {
                    return task!.memberIDs.count
                }
                else if task?.doneByID != nil {
                    return 1
                }
            }
            else {
                return 1
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == categoryCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
        
            let category = Resource.sharedInstance().categories[categoriesKeys[indexPath.item]]
            cell.name.text = category!.name
            cell.icon.text = category!.icon
            
            cell.icon.textColor = category!.color
            cell.icon.layer.borderColor = UIColor.gray.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
            if task?.categoryID == category?.id {
                cell.icon.layer.borderColor = category?.color.cgColor
            }
            
            return cell
        }
        
        else if collectionView == membersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
            cell.image.image = #imageLiteral(resourceName: "dp-male")
            cell.name.text = walletmembers![indexPath.item].userName
            cell.memberSelected.isHidden = true
            return cell
        }
            // table cell collection view
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
            
            cell.image.image = Resource.sharedInstance().currentUser!.image ?? #imageLiteral(resourceName: "dp-male")
            
            if task!.status == .open {
                if task!.doneByID == "" || task!.doneByID == nil {
                    cell.name.text = task!.members[indexPath.item].userName
                }
                else if task!.doneByID != "" {
                    cell.name.text = task!.doneBy!.userName
                }
            }
            else {
                cell.name.text = task!.doneBy!.userName
            }
            
            cell.name.layer.cornerRadius = cell.name.layer.frame.height/2
            cell.memberSelected.isHidden = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == membersCollectionView {
            
            let cell = collectionView.cellForItem(at: indexPath) as! TaskMembersCollectionViewCell
            
            if cell.memberSelected.isHidden {
                cell.memberSelected.isHidden = false
            
                cell.memberSelected.layer.cornerRadius = cell.memberSelected.layer.frame.width/2
                cell.memberSelected.layer.borderWidth = 1
                cell.memberSelected.layer.borderColor = cell.memberSelected.textColor.cgColor
                task!.addMember(walletmembers![indexPath.item].getUserID())
            }
            else {
                cell.memberSelected.isHidden = true
                task!.removeMember(walletmembers![indexPath.item].getUserID())
            }
        }
        // Category Selection
        else {
            TaskCategoryID = categoriesKeys[indexPath.row]
            task!.categoryID = categoriesKeys[indexPath.row]
            tableview.reloadData()
            removeView(view: CategoryView)
        }
        print(task!.members.count)
    }
    
    
    // members view Done btn
    @IBAction func RemoveMemberView(_ sender: Any) {
        tableview.reloadData()
        removeView(view: MemberView)
    }
    
    
    
    @IBAction func AcceptBtnPressed(_ sender: Any) {
        TaskManager.sharedInstance().taskStatusChanged(task!)
    }
    
    @IBAction func RejectBtnPressed(_ sender: Any) {

        if rejectBtn.titleLabel!.text == "REJECT" {
            task!.removeMember(Resource.sharedInstance().currentUserId!)
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
            tableview.reloadSections([0], with: .automatic)
        }
        if rejectBtn.titleLabel!.text == "NOT DOING" {
            task!.doneByID = nil
            TaskManager.sharedInstance().updateTask(task!)
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
            tableview.reloadSections([0], with: .automatic)
        }
    }
    
    @IBAction func AddTaskBtnPressed(_ sender: Any) {
        
        if AddTaskBtn.title == "ADD" {
            
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
                self.navigationController!.popViewController(animated: true)
            }
            else {
                let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
        else if AddTaskBtn.title == "\u{A009}" {
            
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
            
        else if AddTaskBtn.title == "\u{A013}" {
            AddTaskBtn.title = "\u{A009}"
            cells.remove(at: 0)
            if cells[cells.count-1] == "Delete" {
                cells.remove(at: cells.count-1)
            }
        }
    }
    
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        if isNew! || isEdit {
            addView(view: MemberView)
        }
    }
    
    // Delete Task
    
    func DeleteTask() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this tansaction", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
//        print("Kar de Delete")
        TaskManager.sharedInstance().deleteTask(task!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
//        print("Nhn Kr Delete")
    }

    
    
    // Animation and adding category view
    func addView(view : UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 22.0
        self.mainView.addSubview(view)
        view.center = self.mainView.center
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        tableview.alpha = 0.2
        TitleForPage.layer.opacity = 0.2
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = 1.0
            view.transform = CGAffineTransform.identity
        })
    }
    
    func removeView(view : UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            view.alpha = 0

        }) { (Success) in
            view.removeFromSuperview()
            self.TitleForPage.layer.opacity = 1
            self.tableview.alpha = 1
        }
    }
    
    // Task Delegate
    func taskAdded(_ task: Task) {
        
    }
    
    func taskDeleted(_ task: Task) {
        
    }
    
    func taskUpdated(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            if task.id == self.task!.id {
                self.task! = task
                if task.memberIDs.contains(Resource.sharedInstance().currentUserId!) {
                    if task.doneByID == nil {
                        acceptBtn.titleLabel!.text = "ACCEPT"
                        rejectBtn.titleLabel!.text = "REJECT"
                        acceptBtn.isHidden = true
                        rejectBtn.isHidden = true
                    }
                    else if task.doneByID == Resource.sharedInstance().currentUserId {
                        acceptBtn.titleLabel!.text = "ACCEPT"
                        rejectBtn.titleLabel!.text = "REJECT"
                        acceptBtn.isHidden = true
                        rejectBtn.isHidden = true
                    }
                    else if task.status == .completed {
                        acceptBtn.isHidden = true
                        rejectBtn.isHidden = true
                    }
                }
                self.tableview.reloadSections([0], with: .automatic)
            }
        }
    }
    
    
    //
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
