//
//  TaskCategoryViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/28/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class TaskCategoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , CategoryDelegate{

    var categories = [Category]()
    var task : Task?
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for key in Resource.sharedInstance().categories.keys {
            categories.append(Resource.sharedInstance().categories[key]!)
        }
        
        tableview.dataSource = self
        tableview.delegate = self
        
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
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableview.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryTableViewCell
        cell.name.text = categories[indexPath.row].name
        cell.icon.text = categories[indexPath.row].icon
        
        cell.icon.layer.borderWidth = 1
        cell.icon.backgroundColor = .white
        cell.icon.layer.borderColor = categories[indexPath.row].color.cgColor
        cell.icon.textColor = categories[indexPath.row].color
        cell.icon.layer.cornerRadius = cell.icon.frame.width/2
        
        if task!.categoryID == categories[indexPath.row].id {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func categoryAdded(_ category: Category) {
        categories.append(category)
        tableview.reloadData()
    }
    
    func categoryDeleted(_ category: Category) {
        
        for i in 0..<categories.count {
            if categories[i].id == category.id {
                categories.remove(at: i)
            }
        }
        tableview.reloadData()
    }
    
    func categoryUpdated(_ category: Category) {
        tableview.reloadData()
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
