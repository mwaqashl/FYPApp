//
//  BudgetDetailsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/28/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class BudgetDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var curr = NSAttributedString()
    
    var budget : Budget?
    var transactions = [Transaction]()
    var transactionAndCategorys : [String:Double] = [:]
    
    var Edit = UIBarButtonItem()
    
    var dateformat = DateFormatter()
    
    var cells = ["Budget Overview","Graph","Transactions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateformat.dateFormat = "dd-MMM-yyyy"
        
        Edit = UIBarButtonItem.init(title: "\u{A013}", style: .plain, target: self, action: #selector(self.EditBudget))
        Edit.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "untitled-font-7", size: 24)!], for: .normal)
        Edit.tintColor = darkThemeColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                if self.transactions.count == 0 {
                    self.cells.append("NoTransaction")
                }
                if (Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .admin || Resource.sharedInstance().currentWallet!.memberTypes[Resource.sharedInstance().currentUserId!] == .owner ) && self.budget!.wallet.isOpen {
                    
                    self.cells.append("Delete")
                    if self.budget!.isOpen {
                        self.navigationItem.rightBarButtonItem = self.Edit
                    }
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func EditBudget() {
        performSegue(withIdentifier: "EditBudget", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditBudget" {
            let destination = segue.destination as! AddBudgetViewController
            destination.budget = self.budget
            destination.isNew = false
            destination.isEdit = true
        }
    }
    
    func BudgetCalculation(_ budget: Budget) -> Double {
    
        var total = 0.0
        let members = budget.getMemberIDs()
        let categories = budget.getCategoryIDs()
        
        //End date validation not done
        
        for i in 0..<transactions.count {
            if categories.contains(transactions[i].categoryId) && transactions[i].date >= budget.startDate && members.contains(transactions[i].transactionById) {
                print("\(i)")
                total += transactions[i].amount
            }
        }
        return total
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 130 : indexPath.section == 1 ? 300 : cells[indexPath.section] == "Transactions" ? 60 : cells[indexPath.section] == "NoTransaction" ? 80 : 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Budget OverView" : section == 1 ? "Graph" : cells[section] == "Transactions" ? "Transactions" : ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section] == "Transactions" ? transactions.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.section] {
        
        case "Delete":
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell") as! DeleteTableViewCell
            cell.DeleteBtn.addTarget(nil, action: #selector(self.DeleteTask) , for: .touchUpInside)
        
                return cell
            
        case "Transactions":
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as! TimelineTableViewCell
            let transaction = self.transactions[indexPath.row]
            
            cell.categoryIcon.text = transaction.category.icon
            cell.category.text = transaction.category.name
        
            curr = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
            
            let amount = NSAttributedString(string: " \(transaction.amount)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
            
            let str = NSMutableAttributedString()

            str.append(curr)
            str.append(amount)
            
            cell.amount.attributedText = str
            cell.imageView!.image = transaction.transactionBy.image != nil ? transaction.transactionBy.image : #imageLiteral(resourceName: "dp-male")
            
            cell.categoryIcon.textColor = transaction.category.color
            cell.categoryIcon.layer.borderColor = cell.categoryIcon.textColor.cgColor
            cell.categoryIcon.layer.borderWidth = 1
            cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
            
            cell.selectionStyle = .none
            
            return cell
            
        case "Budget Overview":
            let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetCell") as! BudgetTableViewCell
            cell.AssignMembersCollectionView.dataSource = self
            cell.AssignMembersCollectionView.delegate = self
            
            var amount = NSAttributedString(string: " \(budget!.allocAmount)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 11)])
            
            var str = NSMutableAttributedString()
            str.append(curr)
            str.append(amount)
            
            cell.BudgetTitle.text = budget!.title
            cell.Icon.text = budget!.categories.first?.icon ?? ""
            cell.TotalAmount.attributedText = str
            
            amount = NSAttributedString(string: "\(BudgetCalculation(budget!))", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 11)])
            
            str.setAttributedString(curr)
            str.append(amount)
            
            cell.usedAmount.attributedText = str
            cell.StartDate.text = dateformat.string(from: budget!.startDate)
            cell.EndDate.text = dateformat.string(from: budget!.startDate)
            cell.Icon.layer.cornerRadius = cell.Icon.frame.width / 2
            cell.Icon.layer.borderWidth = 1
            cell.Icon.layer.borderColor = budget!.categories.first?.color.cgColor
            cell.Icon.textColor = budget!.categories.first?.color
            
            amount = NSAttributedString(string: "\(budget!.allocAmount - BudgetCalculation(budget!))", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
            
            str.setAttributedString(curr)
            str.append(amount)
            
            cell.BalanceAmount.attributedText = str
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        case "NoTransaction":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionCell") as! TaskTitleTableViewCell
            cell.taskTitle.text = "No Transactions Available"
            cell.isUserInteractionEnabled = false
            cell.taskTitle.isEditable = false
            cell.selectionStyle = .none
            return cell
        
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            self.filterTransaction()
            if transactionAndCategorys.count != 0 {
                self.DrawPieChart(data: transactionAndCategorys, PieChart: cell.PieChartView)
            }
//            cell.PieChartView.noDataText = "No Transaction In This Budget"
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return budget!.members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
        let member = budget!.members[indexPath.item]
        cell.image.image = member.image != nil ? member.image : #imageLiteral(resourceName: "dp-male")
        cell.name.text = member.userName
        cell.selectedmember.isHidden = true
        return cell
        
    }
    
    func DeleteTask() {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to delete this Budget", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
        //        print("Kar de Delete")
        BudgetManager.sharedInstance().removeBudgetFromWallet(budget!)
        self.navigationController!.popViewController(animated: true)
    }
    
    func NoPressed(action : UIAlertAction) {
        //        print("Nhn Kr Delete")
    }
    
    func filterTransaction() {
        transactionAndCategorys = [:]
        for i in 0..<transactions.count {
            if transactionAndCategorys.keys.contains(transactions[i].categoryId) {
                transactionAndCategorys[transactions[i].categoryId] = transactionAndCategorys[transactions[i].categoryId]! + transactions[i].amount
            }
            else {
                transactionAndCategorys[transactions[i].categoryId] = transactions[i].amount
            }
        }
    }
    
    func DrawPieChart(data : [String : Double], PieChart : PieChartView) {
        
        var dataEntries : [PieChartDataEntry] = []
        for i in data.keys {
            let dataEntry = PieChartDataEntry(value: data[i]!, label: Resource.sharedInstance().categories[i]?.name, data: nil)
            dataEntries.append(dataEntry)
        }
        let ChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
        
        let chartData = PieChartData(dataSet: ChartDataSet)
        
        PieChart.data = chartData
        
        var colors: [UIColor] = []
        
        for i in data.keys {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        ChartDataSet.colors = colors
        PieChart.animate(xAxisDuration: 0.4)
        PieChart.holeRadiusPercent = 0.3
        PieChart.transparentCircleColor = UIColor.clear
        
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
