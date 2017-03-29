//
//  AddTaskViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController, UITableViewDataSource , UITableViewDelegate , UITextViewDelegate{

    
    @IBOutlet weak var TitleForPage: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var DoneBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    
    var datepicker = UIDatePicker()
    var dateformatter = DateFormatter()
    let toolbar = UIToolbar()
    var date : Double?
    
    var cells = ["Title","Amount","Category","Date","Comments","AssignTo"]
    var task : Task?
    var isNew : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformatter.dateFormat = "dd-MMM-yyyy"
        
        tableview.delegate = self
        tableview.dataSource = self
        
        if isNew! {
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
        }
        
        if self.isNew! {
            self.task = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: "", dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: "", status: .open, doneByID: "", payeeID: "", memberIDs: [], walletID: "")//Resource.sharedInstance().currentWalletID!)
        }
        
//        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
//            if flag {
//                if self.isNew! {
//                    self.task = Task.init(taskID: "", title: "", categoryID: "", amount: 0.0, comment: "", dueDate: Date().timeIntervalSince1970, startDate: Date().timeIntervalSince1970, creatorID: "", status: .open, doneByID: "", payeeID: "", memberIDs: [], walletID: Resource.sharedInstance().currentWalletID!)
//                }
//            }
//        }        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // date button actions
    
    func donepressed(){
        let cell = tableview.cellForRow(at: IndexPath(row: 2, section: 0)) as! DefaultTableViewCell
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
            if isNew! {
                cell.taskTitle.isUserInteractionEnabled = true
            }
            else if !(isNew!) {
                cell.taskTitle.isUserInteractionEnabled = false
            }
            cell.taskTitle.delegate = self
            cell.taskTitle.tag = 0                                                      // tag 0 for title
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
            if isNew! {
                cell.textView.isUserInteractionEnabled = true
            }
            else if !(isNew!) {
                cell.textView.isUserInteractionEnabled = false
            }
            cell.textView.delegate = self
            cell.textView.tag = 5                                                       // tag 5 for comments
            
            cell.textView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            if cell.textView.contentSize.height > cell.frame.height {
                cell.frame.size.height += (cell.textView.contentSize.height - cell.frame.height) + 8
            }
            
            return cell
            
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
//            if task?.categoryID != nil {
//                cell.name.text = task!.category!.name
//                cell.icon.text = task!.category!.icon
//            }
            cell.name.text = task?.categoryID != nil ? task!.category!.name : "None"
            cell.icon.text = task?.categoryID != nil ? task!.category!.icon : ""
            cell.icon.backgroundColor = task!.category != nil ? task!.category?.color : UIColor.lightGray
            cell.icon.textColor = task!.category!.color
            cell.icon.backgroundColor = .white
            cell.icon.layer.borderColor = task!.category!.color.cgColor
            cell.icon.layer.borderWidth = 1
            cell.icon.layer.cornerRadius = cell.icon.frame.width/2
            
            return cell
            
        case "AssignTo":
            let cell = tableview.dequeueReusableCell(withIdentifier: "assignToCell") as! AssignToTableViewCell
            cell.addmemberBtn.addTarget(self, action: #selector(self.assignToaddBtnPressed(_:)), for: .touchUpInside)
            if isNew! {
                cell.addmemberBtn.isHidden = false
                cell.addmemberBtn.isEnabled = true
            }
            else {
                cell.addmemberBtn.isHidden = true
                cell.addmemberBtn.isEnabled = false
            }
            return cell
            
        case "Delete":
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell") as! DeleteTableViewCell
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                cell.textview.text = task?.amount != 0.0 ? "\(task?.amount ?? 0)" : "0"
                cell.textview.tag = 1                                           // amount tag 1
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
                
            else if cell.title.text == "Assign By" {
                cell.textview.text = ""
                cell.textview.isUserInteractionEnabled = false
            }
            
            if isNew! {
                cell.textview.isUserInteractionEnabled = true
            }
            else {
                cell.textview.isUserInteractionEnabled = false
            }
            cell.textview.delegate = self
            return cell
        }//Switch End
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            performSegue(withIdentifier: "Category", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 2 ? 70 : 50
    }
    
    
//    TextView Delegates
//    Title tag == 0
//    Amount tag == 1
//    comment tag == 5
    
    func textViewDidChange(_ textView: UITextView) {
        tableview.reloadData()
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
        }
    }
    
    @IBAction func DeleteTask(_ sender: Any) {
    }
    
    @IBAction func DoneBtnPressed(_ sender: Any) {
    }
    
    @IBAction func AcceptBtnPressed(_ sender: Any) {
    }
    
    @IBAction func RejectBtnPressed(_ sender: Any) {
    }
    
    @IBAction func assignToaddBtnPressed(_ sender: Any) {
        //WalletMembers identifier
        if isNew! {
            performSegue(withIdentifier: "WalletMembers", sender: nil)
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
