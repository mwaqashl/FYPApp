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
    
    
    let cells = ["Amount","Category","Date","Comments"]
    var transaction : Transaction?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor(red: 43/255, green: 190/255, blue: 230/255, alpha: 1.0).cgColor
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self

        // Do any additional setup after loading the view.
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.row] {
            
        case "Comments":
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
            
            cell.textView.text = transaction?.comments != nil ? (transaction?.comments == "" ? "Write here" : transaction!.comments) : "Write here"
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
            else {
                
                cell.textView.isUserInteractionEnabled = false
            }
            
            return cell
            
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
