//
//  AddTransactionViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/22/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddTransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    
    let cells = ["Amount","Category","Date","Comments"]
    var transaction : Transaction?
    
    var datepicker = UIDatePicker()
    let toolbar = UIToolbar()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor(red: 43/255, green: 190/255, blue: 230/255, alpha: 1.0).cgColor
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        
        datepicker.maximumDate = Date()
        datepicker.datePickerMode = .date
        datepicker.backgroundColor = .white
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        // Do any additional setup after loading the view.
    }
    
    func donepressed(){
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        self.view.endEditing(true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        
        
        
    }
    
    
    // TableView Functions Delegate and Datasources
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return indexPath.row == 1 || indexPath.row == 3 ? 70 : 50
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            cell.textView.inputView = self.datepicker
            cell.textView.inputAccessoryView = toolbar
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.row] {
            
        case "Comments":
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
            
            cell.textView.text = transaction?.comments != nil ? (transaction?.comments == "" ? "Write here" : transaction!.comments) : "Write here"
            
            cell.textView.autoresizingMask = UIViewAutoresizing.flexibleHeight
            
            if cell.textView.contentSize.height > cell.frame.height {
                cell.frame.size.height += (cell.textView.contentSize.height - cell.frame.height) + 8
            }
            
            cell.textView.delegate = self
            return cell
            
        case "Category":
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryTableViewCell
            
            cell.name.text = transaction?.category != nil ? transaction!.category.name : "None"
            cell.icon.backgroundColor = transaction?.category != nil ? transaction!.category.color : UIColor.lightGray
            cell.icon.textColor = UIColor.white
            cell.icon.text = transaction?.category.icon
            
            return cell
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell") as! DefaultTableViewCell
            
            cell.title.text = cells[indexPath.row]
            
            if cell.title.text == "Amount" {
                
                cell.textView.isUserInteractionEnabled = true
                
            }
            else if cell.title.text == "Date" {
                cell.textView.inputView = datepicker
            }
            else {
                
                cell.textView.isUserInteractionEnabled = false
            }
            
            return cell
            
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        transaction?.comments = textView.text
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
