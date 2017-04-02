//
//  AddTaskViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITableViewDataSource , UITableViewDelegate , UITextViewDelegate , UICollectionViewDelegate , UICollectionViewDataSource{

    
    @IBOutlet weak var TitleForPage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    //Collection View
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var CategoryView: UIView!
    @IBOutlet var MemberView: UIView!
    
    @IBOutlet weak var AddTaskBtn: UIBarButtonItem!
    var datepicker = UIDatePicker()
    var dateformatter = DateFormatter()
    let toolbar = UIToolbar()
    var date : Double?
    
    var categoriesKeys = [String]()
    
    var cells = ["Title","Amount","Category","Date","Comments","AssignTo"]
    
    var task : Task?
    var isNew : Bool?
    var walletmembers : [User]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        
        tableview.delegate = self
        tableview.dataSource = self
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        
        walletmembers = Resource.sharedInstance().currentWallet!.members
        
        for key in Resource.sharedInstance().categories.keys {
            categoriesKeys.append(key)
        }
        
        acceptBtn.isHidden = true
        rejectBtn.isHidden = true
        
        if self.isNew! {
            self.task = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: nil, dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: "", status: .open, doneByID: "", payeeID: "", memberIDs: [], walletID:Resource.sharedInstance().currentWalletID!)
        }
        
        else if !(isNew!) {
            cells.insert("Created By", at: 0)
            if Resource.sharedInstance().currentWallet?.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet?.memberTypes[Resource.sharedInstance().currentUserId!] == .owner || task!.creatorID == Resource.sharedInstance().currentUserId || task!.doneByID == Resource.sharedInstance().currentUserId {

                AddTaskBtn.title = "EDIT"
                cells.append("Delete")
            }
            if self.task?.status == .open && (task?.memberIDs.contains(Resource.sharedInstance().currentUserId!))! {
                acceptBtn.isHidden = false
                rejectBtn.isHidden = false
            }
            else if self.task?.status != .open  {
                acceptBtn.setTitle("COMPLETED", for: .normal)
                rejectBtn.setTitle("NOT DOING", for: .normal)
                acceptBtn.isHidden = false
                rejectBtn.isHidden = false
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
            cell.taskTitle.isUserInteractionEnabled = isNew! ? true : false
            cell.taskTitle.delegate = self
            cell.taskTitle.tag = 0                                         // tag 0 for title
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
            cell.textView.isUserInteractionEnabled = isNew! ? true : false
            cell.textView.delegate = self
            cell.textView.tag = 5                                             // tag 5 for comments
            
            cell.textView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            if cell.textView.contentSize.height > cell.frame.height {
                cell.frame.size.height += (cell.textView.contentSize.height - cell.frame.height) + 8
            }
            
            return cell
            
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
//            if task?.categoryID != nil || task?.categoryID != "" {
//                cell.name.text = task!.category!.name
//                cell.icon.text = task!.category!.icon
//            }
            cell.name.text = task?.categoryID != nil || task?.categoryID != "" ? task!.category!.name : "None"
            cell.icon.text = task?.categoryID != nil || task?.categoryID != "" ? task!.category!.icon : ""
            cell.icon.backgroundColor = .white
            cell.icon.textColor = task!.category!.color
            cell.icon.layer.borderColor = task!.category!.color.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
            return cell
            
        case "AssignTo":
            let cell = tableview.dequeueReusableCell(withIdentifier: "assignToCell") as! AssignToTableViewCell
            
            cell.addmemberBtn.addTarget(self, action: #selector(self.assignToaddBtnPressed(_:)), for: .touchUpInside)
            
            cell.addmemberBtn.isHidden = isNew! ? false : true
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textview.text = task?.amount != 0.0 ? "\(task?.amount ?? 0)" : "0"
                cell.textview.tag = 1                   // amount tag 0
            }
                
            else if cell.title.text == "Date" {
                
                cell.textview.inputView = datepicker
                cell.textview.text = dateformatter.string(from: task!.dueDate)
                let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
                let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
                let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
                self.toolbar.setItems([cancel,spaceButton,done], animated: false)
                cell.textview.inputAccessoryView = self.toolbar
            }
            
            cell.textview.isUserInteractionEnabled = isNew! ? true : false
            cell.textview.delegate = self
            return cell
        }//Switch End
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 && isNew! {
            addView(view: CategoryView)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isNew! {
            return indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5 ? 70 : 50
        }
        else {
            return indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 6 ? 70 : 50
        }
    }
    
    
//    TextView Delegates
//    Title tag == 0
//    Amount tag == 1
//    comment tag == 5
    
    func textViewDidChange(_ textView: UITextView) {
//        tableview.reloadData()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .black
        if textView.tag == 0 || textView.tag == 5 {
            if textView.text == "Write Here" || textView.text == "Enter Title" {
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 0 {
            task!.title = textView.text
        }
        else if textView.tag == 1 {
            task!.amount = Double(textView.text)!
        }
        else if textView.tag == 5 {
            task!.comment = textView.text
            textView.text = task?.comment != nil || task?.comment != "" ? task?.comment : "Write Here"
        }
    }
    
    // Collection View for categories and WalletMembers
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView != membersCollectionView {
            return categoriesKeys.count
        }
        else {
            return (walletmembers?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView != membersCollectionView {
            
            let Categorycell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategorySelectionCollectionViewCell
        
            let category = Resource.sharedInstance().categories[categoriesKeys[indexPath.item]]
            Categorycell.name.text = category!.name
            Categorycell.icon.text = category!.icon
        
            if task?.categoryID == category!.id {
                Categorycell.selectedCategory.isHidden = false
                Categorycell.selectedCategory.layer.cornerRadius = Categorycell.selectedCategory.layer.frame.width/2
                Categorycell.selectedCategory.layer.borderWidth = 1
                Categorycell.selectedCategory.layer.borderColor = Categorycell.selectedCategory.textColor.cgColor
                Categorycell.selectedCategory.backgroundColor = .white
            }
            else {
                Categorycell.selectedCategory.isHidden = true
            }
            
            Categorycell.icon.textColor = category!.color
            Categorycell.icon.layer.cornerRadius = Categorycell.icon.layer.frame.width/2
            Categorycell.icon.layer.borderWidth = 1
            Categorycell.icon.layer.borderColor = Categorycell.icon.textColor.cgColor
        
            return Categorycell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
            cell.image.image = #imageLiteral(resourceName: "persontemp")
            cell.name.text = walletmembers![indexPath.item].userName
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == membersCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! TaskMembersCollectionViewCell
            cell.memberSelected.isHidden = false
            
            cell.memberSelected.layer.cornerRadius = cell.memberSelected.layer.frame.width/2
            cell.memberSelected.layer.borderWidth = 1
            cell.memberSelected.layer.borderColor = cell.memberSelected.textColor.cgColor
            task!.addMember(walletmembers![indexPath.item].getUserID())
        }
        else {
            task!.categoryID = categoriesKeys[indexPath.row]
            tableview.reloadData()
            removeView(view: CategoryView)
        }
    }
    // members view Done btn
    @IBAction func RemoveMemberView(_ sender: Any) {
        tableview.reloadData()
        removeView(view: MemberView)
    }
    
    
    
    @IBAction func AcceptBtnPressed(_ sender: Any) {
    }
    
    @IBAction func RejectBtnPressed(_ sender: Any) {
    }
    
    @IBAction func AddTaskBtnPressed(_ sender: Any) {
        if AddTaskBtn.title == "DONE" {
            
        }
        else if AddTaskBtn.title == "EDIT" {
            cells.remove(at: 0)
            cells.remove(at: cells.count-1)
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
            isNew! = true
            
            let indexpath = IndexPath(item: cells.count, section: 0)
            tableview.reloadRows(at: [indexpath], with: .automatic)
//            let range = NSMakeRange(0, tableView.numberOfSections)
//            let sections = NSIndexSet(indexesIn: range)
//            self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        }
    }
    
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        //WalletMembers identifier
        if isNew! {
            addView(view: MemberView)
        }
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
