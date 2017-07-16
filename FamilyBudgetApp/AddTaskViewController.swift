//
//  AddTaskViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource, TaskDelegate, WalletMemberDelegate, TaskMemberDelegate, WalletDelegate{

    @IBOutlet weak var actionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionviewTitle: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var TitleForPage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var SelectionView: UIView!
    @IBOutlet weak var DateView: UIView!
    
    @IBOutlet weak var acceptRejectBtnView: UIView!
    @IBOutlet weak var acceptBtnView: UIView!
    @IBOutlet weak var datepicker: UIDatePicker!
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!

    var backView : UIView?
    var Add = UIBarButtonItem()
    var Edit = UIBarButtonItem()
    var dateformatter = DateFormatter()
    var date : Double?
    var categoriesKeys = [String]()
    var walletmembers : [User]?
    var cells = ["Title","Amount","Category","Due Date","Comments"]
    var newTask : Task?
    var isNew : Bool?
    var isEdit = false
    var isCategoryView = true
    var isKeyboardOpen = false
    var selectedCategory = String()
    var pselectedCategory = String()
    var selectedMembers = [String]()
    var pselecctedMembers = [String]()
    var tap = UITapGestureRecognizer()
    var taskEdited = false
    var task : Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView = UIView(frame: self.view.frame)
        backView!.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        backView!.addGestureRecognizer(tap)
        backView!.backgroundColor = .lightGray
        backView!.alpha = 0.5
        backView!.isUserInteractionEnabled = true
        
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        datepicker.minimumDate = Date()
        
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
        
        self.acceptBtnView.isHidden = true
        self.acceptRejectBtnView.isHidden = true
        self.actionViewHeight.constant = 0
        SelectionView.isHidden = true
        DateView.isHidden = true
        DateView.frame.origin.y += DateView.frame.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        Add = UIBarButtonItem.init(image: #imageLiteral(resourceName: "done"), style: .plain, target: self, action: #selector(self.AddTask))
        Add.tintColor = darkThemeColor
        
        Edit = UIBarButtonItem.init(image: #imageLiteral(resourceName: "edit"), style: .plain, target: self, action: #selector(self.EditTask))

        Delegate.sharedInstance().addTaskDelegate(self)
        Delegate.sharedInstance().addTaskMemberDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                
                self.walletmembers = Resource.sharedInstance().currentWallet!.members
                // Creating New Task
                if self.isNew! {
                    self.isEdit = true
                    self.newTask = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: nil, dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: Resource.sharedInstance().currentUserId!, status: .open, doneByID: nil, memberIDs: [], walletID:Resource.sharedInstance().currentWalletID!)
                    self.navigationItem.rightBarButtonItem = self.Add
                    self.datepicker.date = Date()
                    if Resource.sharedInstance().currentWallet!.isPersonal {
                        self.newTask!.addMember(Resource.sharedInstance().currentUserId!)
                        self.newTask!.doneByID = Resource.sharedInstance().currentUserId
                    }
                    else {
                        self.cells.append("AssignTo")
                    }
                }
                    
                // Previous Tasks Viewing
                else {
                    self.newTask = Task(taskID: self.task!.id, title: self.task!.title, categoryID: self.task!.categoryID, amount: self.task!.amount, comment: self.task?.comment, dueDate: self.task!.dueDate.timeIntervalSince1970, startDate: self.task!.startDate.timeIntervalSince1970, creatorID: self.task!.creatorID, status: self.task!.status, doneByID: self.task?.doneByID, memberIDs: self.task!.memberIDs, walletID: self.task!.walletID)
                    
                    self.acceptBtn.contentHorizontalAlignment = .center
                    self.acceptBtn.center = self.view.center
                    self.selectedCategory = self.newTask!.categoryID
                    self.pselectedCategory = self.selectedCategory
                    self.selectedMembers = self.newTask!.memberIDs
                    self.pselecctedMembers = self.selectedMembers
                    self.datepicker.date = self.newTask!.dueDate
                    self.updateCells()
                }
            }
        }
        
                // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Resource.sharedInstance().currentWalletID != task?.walletID && !isNew! {
            self.navigationController?.popViewController(animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    // Bar Button Actions
    func AddTask() {
        
        self.view.endEditing(true)
        
        var error = ""
        var errorDis = ""
        
        if newTask!.title == "" {
            error = "Error"
            errorDis = "Task Title cannot be empty"
        }
        else if newTask!.amount == 0 || newTask!.amount == 0.0 {
            error = "Error"
            errorDis = "Amount cannot be empty"
        }
        else if newTask!.categoryID == "" {
            error = "Error"
            errorDis = "Category cannot be empty"
        }
        else if newTask!.members.count == 0 {
            error = "Error"
            errorDis = "Select any member to assign this task"
        }
        
        if error == "" {
            TaskManager.sharedInstance().addNewTask(newTask!)
            if Resource.sharedInstance().currentWallet!.isPersonal {
                TaskManager.sharedInstance().taskStatusChanged(newTask!)
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
            self.view.endEditing(true)
            
            var error = ""
            var errorDis = ""
            
            if newTask!.title == "" {
                error = "Error"
                errorDis = "Task Title cannot be empty"
            }
            else if newTask!.amount == 0 || newTask!.amount == 0.0 {
                error = "Error"
                errorDis = "Amount cannot be empty"
            }
            else if newTask!.categoryID == "" {
                error = "Error"
                errorDis = "Category cannot be empty"
            }
            else if newTask!.members.count == 0 {
                error = "Error"
                errorDis = "Select any member to assign this task"
            }
            
            if error == "" {
                TaskManager.sharedInstance().updateTask(newTask!)
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
            acceptBtnView.isHidden = true
            acceptRejectBtnView.isHidden = true
            self.actionViewHeight.constant = 0
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
            
            if newTask?.title == nil || newTask!.title == "" {
                cell.taskTitle.text = "Enter Title"
                cell.taskTitle.textColor = .gray
            }
            else {
                cell.taskTitle.text = newTask!.title
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
            if newTask?.comment == nil || newTask!.comment == "" {
                cell.textView.text = "Write Here"
                cell.textView.textColor = .gray
            }
            else {
                cell.textView.text = newTask!.comment
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
            
            cell.name.text = selectedCategory == "" ? "None" : newTask!.category!.name
            cell.icon.text = selectedCategory == "" ? "" : newTask!.category!.icon
            
            cell.icon.textColor = newTask!.category!.color
            cell.icon.layer.borderColor = newTask!.category!.color.cgColor
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
            cell.addmemberBtn.isHidden = !isEdit
            cell.selectionStyle = UITableViewCellSelectionStyle.none

            return cell
            
        case "Delete":
            
            let cell = tableview.dequeueReusableCell(withIdentifier: "deleteCell") as! DeleteTableViewCell
            cell.DeleteBtn.addTarget(nil, action: #selector(self.DeleteTask) , for: .touchUpInside)
            
            return cell
            
        case "Created By":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionbyCell") as! TransactionByTableViewCell
            cell.title.text = "Assign By "
            cell.name.text = newTask!.creator!.userName
            let type = Resource.sharedInstance().currentWallet?.memberTypes[(newTask!.creatorID)]
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
            cell.title.text = newTask!.status == .open ? "In Progress By " : "Completed By"
            cell.name.text = newTask!.doneBy?.userName
            let type = Resource.sharedInstance().currentWallet?.memberTypes[(newTask!.doneByID)!]
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
                cell.textview.text = newTask!.amount != 0.0 ? "\(newTask?.amount ?? 0)" : "0"
                cell.textview.tag = 2     // amount tag 2
                cell.textview.isEditable = newTask!.status == .completed ? false : isNew! || isEdit
            }
                
            else if cell.title.text == "Due Date" {
                cell.textview.text = dateformatter.string(from: newTask!.dueDate)
                cell.textview.isUserInteractionEnabled = false
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
                collectionviewTitle.text = "SELECT CATEGORY"
                self.addView(SelectionView)
            }
            if cells[indexPath.row] == "Due Date" {
                self.addView(DateView)
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

        if cells[indexPath.row] == "Category" || cells[indexPath.row] == "Created By" || cells[indexPath.row] == "In Progress By" || cells[indexPath.row] == "Comments" || cells[indexPath.row] == "AssignTo" {
            return 70
        }
        else {
            return 45
        }
    }
    
    func addView(_ showView : UIView) {
        self.backView?.addGestureRecognizer(tap)
        if showView == SelectionView {
            self.collectionview.reloadData()
        }
        view.addSubview(backView!)
        if showView == SelectionView {
            showView.isHidden = false
            showView.alpha = 0
            self.view.bringSubview(toFront: SelectionView)
            UIView.animate(withDuration: 0.3, animations: {
                showView.alpha = 1.0
            })
        }
        else {
            self.DateView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: { 
                self.DateView.frame.origin.y -= self.DateView.frame.height
            })
            self.view.bringSubview(toFront: DateView)
        }
        
    }
    
    func removeView() {
        if isKeyboardOpen {
            self.view.removeGestureRecognizer(tap)
            self.view.endEditing(true)
        }
        if !SelectionView.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.SelectionView.alpha = 0
            }) { (Success) in
                self.SelectionView.isHidden = true
                self.backView!.removeFromSuperview()
            }
        }
        else if !DateView.isHidden {
            self.DateView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.DateView.frame.origin.y += self.DateView.frame.height
            }) { (Success) in
                self.backView!.removeFromSuperview()
                self.DateView.isHidden = true
            }
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
                textView.text = newTask!.comment
            }
            UIView.animate(withDuration: 0.4, animations: { 
                self.view.frame.origin.y -= self.SizeOfKeyboard/2
            })
        }
        else if textView.tag == 1 {
            if textView.text == "Enter Title" {
                textView.text = ""
            }
            else {
                textView.text = newTask!.title
            }
        }
        else if textView.tag == 2 {
            textView.text = textView.text == "0" ? "" : "\(newTask!.amount)"
        }
        taskEdited = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            newTask!.title = textView.text
            textView.textColor = textView.text == "" ? .gray : .black
            textView.text = textView.text == "" ? "Task title" : textView.text
        }
        else if textView.tag == 2 {
            newTask!.amount = Double(textView.text) ?? 0.0
            textView.text = newTask!.amount == 0.0 ? "0" : "\(newTask!.amount)"
        }
        else if textView.tag == 5 {
            newTask?.comment = textView.text
            textView.textColor = textView.text == "" ? .gray : .black
            textView.text = textView.text == "" ? "Write here" : textView.text
            self.view.frame.origin.y += self.SizeOfKeyboard/2
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
            return newTask!.members.count
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
                user = newTask!.members[indexPath.item]
            }
            cell.name.text = user!.userName
            cell.image.image = #imageLiteral(resourceName: "dp-male")
            cell.selectedmember.layer.cornerRadius = 5
            if newTask!.memberIDs.contains(walletmembers![indexPath.item].getUserID()) && collectionView == self.collectionview {
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
            taskEdited = true
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
            taskEdited = true
        }
        
    }
    
    
    
    
    @IBAction func AcceptBtnPressed(_ sender: Any) {
        if acceptBtn.titleLabel!.text == "ACCEPT" {
            newTask!.doneByID = Resource.sharedInstance().currentUserId
        }
        else if acceptBtn.titleLabel!.text == "COMPLETED" {
            newTask!.status = .completed
        }
        updateCells()
        TaskManager.sharedInstance().taskStatusChanged(newTask!)
        TaskManager.sharedInstance().updateTask(newTask!)
    }
    
    @IBAction func RejectBtnPressed(_ sender: Any) {

        if rejectBtn.titleLabel!.text == "REJECT" {
            newTask!.removeMember(Resource.sharedInstance().currentUserId!)
            TaskManager.sharedInstance().removeMemberFromTask(newTask!.id, member: Resource.sharedInstance().currentUserId!)
        }
        else if rejectBtn.titleLabel!.text == "NOT DOING" {
            newTask!.memberIDs.remove(at: newTask!.memberIDs.index(of: Resource.sharedInstance().currentUserId!)!)
            newTask!.doneByID = nil
            newTask!.status = .open
            TaskManager.sharedInstance().taskStatusChanged(newTask!)
        }
        updateCells()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        collectionviewTitle.text = "SELECT MEMBERS"
        isCategoryView = false
        self.addView(SelectionView)
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
        TaskManager.sharedInstance().deleteTask(newTask!)
        self.navigationController!.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
//        print("Nhn Kr Delete")
    }

    //Collection View And Date Buttons Actions
    @IBAction func DonePressed(_ sender: UIButton) {
        if sender.tag == 1 {
            let cell = tableview.cellForRow(at: IndexPath(row: cells.index(of: "Due Date")!, section: 0)) as! DefaultTableViewCell
            cell.textview.text = dateformatter.string(from: datepicker.date)
            date = datepicker.date.timeIntervalSince1970
            newTask!.dueDate = datepicker.date
            taskEdited = true
        }
        else {
            if isCategoryView {
                pselectedCategory = selectedCategory
                newTask!.categoryID = selectedCategory
            }
            else {
                pselecctedMembers = selectedMembers
                newTask!.memberIDs = selectedMembers
            }
        }
        self.removeView()
        tableview.reloadData()
    }
    
    @IBAction func CancelPressed(_ sender: UIButton) {
        if isCategoryView {
            selectedCategory = pselectedCategory
        }
        else {
            selectedMembers = pselecctedMembers
        }
        self.removeView()
        tableview.reloadData()
    }
    
    
    // Task Delegate
    func taskAdded(_ task: Task) {
    }
    
    func taskDeleted(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            if task.id == self.newTask!.id {
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
            if task.id == self.newTask!.id {
                self.newTask! = task
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
            if self.newTask!.memberIDs.contains(member.getUserID()) {
                self.newTask!.memberIDs.remove(at: self.newTask!.memberIDs.index(of: member.getUserID())!)
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
        if task.id == self.newTask!.id {
            self.newTask!.memberIDs = task.memberIDs
            self.tableview.reloadData()
        }
    }
    
    func memberAdded(_ member: User, task: Task) {
        if task.id == self.newTask!.id {
            self.newTask!.memberIDs = task.memberIDs
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
        self.acceptBtnView.isHidden = true
        self.acceptRejectBtnView.isHidden = true
        self.actionViewHeight.constant = 0

        self.navigationItem.rightBarButtonItem = nil
        
        self.cells = ["Title","Amount","Category","Created By","Due Date"]
        
        if self.newTask!.status == .open {
            if self.newTask!.doneByID == nil {
                self.cells.insert("AssignTo", at: 3)
            }
            else {
                self.cells.insert("In Progress By", at: 3)
            }
        }
        else if self.newTask!.status == .completed {
            self.cells.insert("In Progress By", at: 3)
        }
        
        self.TitleForPage.text = "TASK DETAILS"
        
        if self.newTask?.comment != nil {
            self.cells.append("Comments")
        }
        
        if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner || self.newTask!.creatorID == Resource.sharedInstance().currentUserId) && newTask!.wallet!.isOpen {
            
            self.cells.append("Delete")
            if self.newTask!.status == .open {
                self.navigationItem.rightBarButtonItem = self.Edit
            }
        }
        if self.newTask!.status == .open && (self.newTask?.doneByID == "" || self.newTask?.doneByID == nil) && self.newTask!.memberIDs.contains(Resource.sharedInstance().currentUserId!) {
            self.acceptBtn.setTitle("ACCEPT", for: .normal)
            self.rejectBtn.setTitle("REJECT", for: .normal)
            self.acceptRejectBtnView.isHidden = false
            self.acceptBtnView.isHidden = true
            self.actionViewHeight.constant = 70
        }
        if self.newTask!.status == .open && self.newTask!.doneByID == Resource.sharedInstance().currentUserId! {
            self.acceptBtn.setTitle("COMPLETED", for: .normal)
            self.rejectBtn.setTitle("NOT DOING", for: .normal)
            
            if Resource.sharedInstance().currentWallet!.isPersonal {
                self.acceptBtnView.isHidden = false
                self.acceptRejectBtnView.isHidden = true
            }
            else {
                self.acceptBtnView.isHidden = true
                self.acceptRejectBtnView.isHidden = false
            }
            self.actionViewHeight.constant = 70
        }
        if self.newTask!.status == .completed || !(self.newTask!.wallet!.isOpen) {
            self.acceptBtnView.isHidden = true
            self.acceptRejectBtnView.isHidden = true
            self.actionViewHeight.constant = 0
        }
    }

}
