//
//  StatisticsDetailViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 7/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class StatisticsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , TransactionDelegate, WalletDelegate {
    
    
    @IBOutlet weak var MonthHeader: UILabel!
    @IBOutlet weak var segmentBtn: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nextMonthBtn: UIButton!
    @IBOutlet weak var previousMonthBtn: UIButton!
    
    var CategoryAndAmount : [String:Double] = [:]
    var isIcomeTapped = Bool()
    var currentWalletTransactions = [Transaction]()
    var MonthRelatedTransaction = [String:[Transaction]]()
    var dateFormat = DateFormatter()
    var selectedMonthIndex = Int()
    var Months = [Date]()
    
    var selectedMonthTransactions = [Transaction]()
    var expenseTransaction = [Transaction]()
    var incomeTransaction = [Transaction]()
    
    var cells = ["Statistical view","Transactions"]
    var isDataAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextMonthBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        tableView.delegate = self
        tableView.dataSource = self
        
        dateFormat.dateFormat = "MMMM-yyyy"
        
        MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        segmentBtn.selectedSegmentIndex = isIcomeTapped ? 1 : 0
        
        for i in 0..<selectedMonthTransactions.count {
            if selectedMonthTransactions[i].isExpense {
                expenseTransaction.append(selectedMonthTransactions[i])
            }
            else {
                incomeTransaction.append(selectedMonthTransactions[i])
            }
        }
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                if self.selectedMonthIndex == 0 {
                    self.previousMonthBtn.isEnabled = false
                }
                else if self.selectedMonthIndex == self.Months.count-1 {
                    self.nextMonthBtn.isEnabled = false
                }
                self.isDataAvailable = true
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            ExtractTransactions()
            ExtractIncomeExpense()
            sortMonths()
            tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ExtractIncomeExpense() {
        selectedMonthTransactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]!
        expenseTransaction = []
        incomeTransaction = []
        
        for i in 0..<selectedMonthTransactions.count {
            if selectedMonthTransactions[i].isExpense {
                expenseTransaction.append(selectedMonthTransactions[i])
            }
            else {
                incomeTransaction.append(selectedMonthTransactions[i])
            }
        }
    }
    
    func ExtractTransactions() {
        currentWalletTransactions = Resource.sharedInstance().currentWallet!.transactions
        MonthRelatedTransaction = [:]
        Months = []
        
        for i in 0..<currentWalletTransactions.count {
            
            let date = dateFormat.string(from: currentWalletTransactions[i].date)
            if MonthRelatedTransaction.keys.contains(date) {
                MonthRelatedTransaction[date]!.append(currentWalletTransactions[i])
            }
            else {
                MonthRelatedTransaction[date] = [currentWalletTransactions[i]]
                Months.append(currentWalletTransactions[i].date)
            }
        }
        sortMonths()
        tableView.reloadData()
    }
    
    func sortMonths() {
        Months.sort { (a, b) -> Bool in
            a.compare(b) == .orderedAscending
        }
        selectedMonthIndex = Months.count > 0 ? Months.count-1 : 0
        nextMonthBtn.isEnabled = Months.count > 0
        previousMonthBtn.isEnabled = selectedMonthIndex > 0
    }
    
    //Categories and its amount
    func filterCategoriesAndAmount() {
        
        CategoryAndAmount = [:]
        let transaction = segmentBtn.selectedSegmentIndex == 0 ? expenseTransaction : incomeTransaction
        
        for i in 0..<transaction.count {
            if CategoryAndAmount.keys.contains(transaction[i].categoryId) {
                CategoryAndAmount[transaction[i].categoryId] = CategoryAndAmount[transaction[i].categoryId]! + transaction[i].amount
            }
            else {
                CategoryAndAmount[transaction[i].categoryId] = transaction[i].amount
            }
        }
    }
    
    func DrawPieChart(data : [String : Double], PieChart : PieChartView) {
        
        var dataEntries : [PieChartDataEntry] = []
        for i in data.keys {
            let dataEntry = PieChartDataEntry(value: data[i]!, label: Resource.sharedInstance().categories[i]!.name, data: nil)
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        
        for i in data.keys {
            let color = Resource.sharedInstance().categories[i]!.color
            colors.append(color)
        }
        
        PieChart.animate(xAxisDuration: 0.4)
        PieChart.holeRadiusPercent = 0.3
//        PieChart.transparentCircleColor = UIColor.clear
        
        let ChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        ChartDataSet.colors = colors
        ChartDataSet.sliceSpace = 1.0
        ChartDataSet.drawValuesEnabled = false
        
        let chartData = PieChartData(dataSet: ChartDataSet)
        
        PieChart.data = chartData
        PieChart.drawEntryLabelsEnabled = false
        
    }
    
    func getAmountwithCurrency(Amount : Double , of size : CGFloat) -> NSMutableAttributedString {
        
        let font = UIFont(name: "untitled-font-25", size: size)!
        
        let wallet = Resource.sharedInstance().currentWallet!.currency.icon
        
        
        let CurrIcon = NSAttributedString(string: wallet, attributes: [NSFontAttributeName : font])
        let amount = NSAttributedString(string: "\(Amount)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: size)])
        
        let str = NSMutableAttributedString()
        str.append(CurrIcon)
        str.append(amount)
        
        return str
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentBtn.selectedSegmentIndex == 0 {
            return cells[section] == "Transactions" ? expenseTransaction.count : 1
        }
        else {
            return cells[section] == "Transactions" ? incomeTransaction.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.section] == "Statistical view" ? 300 : 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.section] {
            
        case "Transactions":
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as!     TimelineTableViewCell
            let transaction = self.selectedMonthTransactions[indexPath.row]
            
            cell.categoryIcon.text = transaction.category.icon
            cell.category.text = transaction.category.name
            
            cell.amount.attributedText = getAmountwithCurrency(Amount: transaction.amount, of: cell.amount.font.pointSize)

            cell.personImage.image = transaction.transactionBy.image
            
            transaction.transactionBy.imageCallback = {
                image in
                cell.personImage.image = image
            }
            
            cell.categoryIcon.textColor = transaction.category.color
            cell.categoryIcon.layer.borderColor = cell.categoryIcon.textColor.cgColor
            cell.categoryIcon.layer.borderWidth = 1
            cell.categoryIcon.layer.cornerRadius = cell.categoryIcon.frame.width/2
            
            cell.selectionStyle = .none
            
            return cell
            
        case "NoTransaction":
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionCell") as! TaskTitleTableViewCell
            cell.selectionStyle = .none
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            self.filterCategoriesAndAmount()
            cell.PieChartView.legend.resetCustom()
            if CategoryAndAmount.isEmpty {
                cell.PieChartView.data?.clearValues()
                cell.PieChartView.noDataText = "No transaction Available"
                cell.PieChartView.isHidden = true
                cell.noDataLabel.isHidden = false
            }
            else {
                cell.PieChartView.isHidden = false
                cell.noDataLabel.isHidden = true
                self.DrawPieChart(data: CategoryAndAmount, PieChart: cell.PieChartView)
            }
            cell.PieChartView.chartDescription?.text = ""
            cell.PieChartView.noDataText = "No transaction Available"
            
            cell.selectionStyle = .none
            return cell        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cells[section]
    }
    
    @IBAction func segmentBtnAction(_ sender: Any) {
        if segmentBtn.selectedSegmentIndex == 0 {
            if expenseTransaction.count == 0 {
                if !cells.contains("NoTransaction") {
                    cells.append("NoTransaction")
                }
            }
            else {
                if cells.contains("NoTransaction") {
                    cells.remove(at: cells.index(of: "NoTransaction")!)
                }
            }
        }
        else if segmentBtn.selectedSegmentIndex == 1 {
            if incomeTransaction.count == 0 {
                if !cells.contains("NoTransaction") {
                    cells.append("NoTransaction")
                }
            }
            else {
                if cells.contains("NoTransaction") {
                    cells.remove(at: cells.index(of: "NoTransaction")!)
                }
            }
        }
        tableView.reloadData()
    }
    
    // tag 1 for previous  tag 2 for next
    @IBAction func changeMonth(_ sender: UIButton) {
        if sender.tag == 1 {
            if selectedMonthIndex != 0 {
                selectedMonthIndex-=1
                MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
            }
            if selectedMonthIndex == 0 {
                previousMonthBtn.isEnabled = false
            }
            if selectedMonthIndex == Months.count-1 {
                nextMonthBtn.isEnabled = false
            }
            else {
                nextMonthBtn.isEnabled = true
            }
            ExtractIncomeExpense()
            tableView.reloadData()
        }
        else if sender.tag == 2 {
            if selectedMonthIndex != Months.count-1 {
                selectedMonthIndex+=1
                MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
            }
            if selectedMonthIndex == Months.count-1 {
                nextMonthBtn.isEnabled = false
            }
            if selectedMonthIndex == 0 {
                previousMonthBtn.isEnabled = false
            }
            else {
                previousMonthBtn.isEnabled = true
            }
            ExtractIncomeExpense()
            tableView.reloadData()
        }
    }
    
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                ExtractTransactions()
                if transaction.date == Months[selectedMonthIndex] {
                    ExtractIncomeExpense()
                    if transaction.isExpense && segmentBtn.selectedSegmentIndex == 0 {
                        tableView.reloadData()
                    }
                    else if !transaction.isExpense && segmentBtn.selectedSegmentIndex == 1 {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                ExtractTransactions()
                if transaction.date == Months[selectedMonthIndex] {
                    ExtractIncomeExpense()
                    if transaction.isExpense && segmentBtn.selectedSegmentIndex == 0 {
                        tableView.reloadData()
                    }
                    else if !transaction.isExpense && segmentBtn.selectedSegmentIndex == 1 {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                ExtractTransactions()
                if transaction.date == Months[selectedMonthIndex] {
                    ExtractIncomeExpense()
                    if transaction.isExpense && segmentBtn.selectedSegmentIndex == 0 {
                        tableView.reloadData()
                    }
                    else if !transaction.isExpense && segmentBtn.selectedSegmentIndex == 1 {
                        tableView.reloadData()
                    }
                }
            }
        }
    }
    
    //    Wallet Delegates
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        // close wallet view
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID! {
            Resource.sharedInstance().currentWalletID! = Resource.sharedInstance().currentUserId!
            self.navigationController?.popViewController(animated: true)
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
