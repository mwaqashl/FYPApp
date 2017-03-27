//
//  CategoriesViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/25/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController , UITableViewDelegate, UITableViewDataSource , CategoryDelegate{

    
    var transaction : Transaction?
    @IBOutlet weak var tableview: UITableView!
    
    var income = [String]()
    var expence = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //income = Resource.sharedInstance().categories
        print("\(income.count)")
        for key in Resource.sharedInstance().categories.keys {
            let curr = Resource.sharedInstance().categories[key]
            if curr!.isExpense {
                expence.append(key)
            }
            else {
                income.append(key)
            }
        }
        print("Expenxe = \(transaction?.isExpense)")
//        print("Income = \(transaction?.currencyId)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Inside numberofrows \(transaction!.isExpense)")
        if (transaction!.isExpense) {
            return expence.count
        }
        else {
            return income.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var category : Category?
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! SelectCategoryTableViewCell
        
        if (transaction!.isExpense) {
            category = Resource.sharedInstance().categories[expence[indexPath.row]]
            if transaction!.categoryId == expence[indexPath.row] {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        else {
            category = Resource.sharedInstance().categories[income[indexPath.row]]
            if transaction!.categoryId == income[indexPath.row] {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        cell.CategoryIcon.text = category!.icon
        cell.CategoryName.text = category!.name
        cell.CategoryIcon.layer.borderWidth = 2
        cell.CategoryIcon.backgroundColor = .white
        cell.CategoryIcon.layer.borderColor = category?.color.cgColor
        cell.CategoryIcon.layer.cornerRadius = 22
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (transaction!.isExpense) {
            transaction!.categoryId = expence[indexPath.row]
        }
        else {
            transaction!.categoryId = income[indexPath.row]
        }
        let new = AddTransactionViewController()
        new.transaction = self.transaction
        self.navigationController!.popViewController(animated: true)
    }
    
    //Category Delegates
    func categoryAdded(_ category : Category){
        print(category.name)
        tableview.reloadData()
    }
    func categoryUpdated(_ category : Category){
        
    }
    func categoryDeleted(_ category : Category){
        
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
