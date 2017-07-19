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
    var stats : [statsModel] = []
    var CategoryAndAmount : [String:Double] = [:]
    var isIcomeTapped = Bool()
    var currentWalletTransactions = [Transaction]()
    var MonthRelatedTransaction = [String:[Transaction]]()
    var dateFormat = DateFormatter()
    var selectedMonthIndex = Int()
    var Months = [Date]()
    var calander = NSCalendar.current
    var selectedMonthTransactions = [Transaction]()
    var expenseTransaction = [Transaction]()
    var incomeTransaction = [Transaction]()
    var walletid = String()
    var cells = ["Statistical view","Transactions"]
    var isDataAvailable = false
    var selectedMonth : Date?
    
    var foreCastExpences = [String : Double]()
    var foreCastIncome = [String : Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextMonthBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        tableView.delegate = self
        tableView.dataSource = self
        
        dateFormat.dateFormat = "MMMM-yyyy"
        
        MonthHeader.text = selectedMonthIndex == Months.count-1 ? ("ForeCast Data \(dateFormat.string(from: Months[selectedMonthIndex]))") : dateFormat.string(from: Months[selectedMonthIndex])
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        segmentBtn.selectedSegmentIndex = isIcomeTapped ? 1 : 0
        
        if selectedMonthIndex == Months.count-1 {
            statsIncomeExpense()
        }
        else {
            for i in 0..<selectedMonthTransactions.count {
                if selectedMonthTransactions[i].isExpense {
                    expenseTransaction.append(selectedMonthTransactions[i])
                }
                else {
                    incomeTransaction.append(selectedMonthTransactions[i])
                }
            }
        }
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.walletid = Resource.sharedInstance().currentWalletID!
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
    
    func statsIncomeExpense() {
        for forecast in stats {
            if Resource.sharedInstance().categories[forecast.CategoryID]!.isExpense {
                foreCastExpences[forecast.CategoryID] = forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
            } else {
                foreCastIncome[forecast.CategoryID] = forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            if walletid != Resource.sharedInstance().currentWalletID! {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                if selectedMonthIndex == Months.count-1 {
                    
                }
                else{
                    ExtractMonths()
                    ExtractTransactions()
                    ExtractIncomeExpense()
                    sortMonths()
                    self.Months.append(self.calander.date(byAdding: .month, value: 1, to: self.Months.last!)!)
                    self.MonthHeader.text = self.dateFormat.string(from: self.Months[self.selectedMonthIndex])
                }
                tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ExtractIncomeExpense() {
        expenseTransaction = []
        incomeTransaction = []
        guard let selectedMonthTransactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])] else {
            return
        }
        
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
        
        for i in 0..<currentWalletTransactions.count {
            
            let date = dateFormat.string(from: currentWalletTransactions[i].date)
            if MonthRelatedTransaction.keys.contains(date) {
                MonthRelatedTransaction[date]!.append(currentWalletTransactions[i])
            }
            else {
                MonthRelatedTransaction[date] = [currentWalletTransactions[i]]
            }
        }
    }
    
    func sortMonths() {
        Months.sort { (a, b) -> Bool in
            a.compare(b) == .orderedAscending
        }
    }
    
    func ExtractMonths(){
        guard let transactions = Resource.sharedInstance().currentWallet?.transactions
            else {
                return
        }
        var dates = [Date]()
        for i in 0..<transactions.count {
            dates.append(transactions[i].date)
        }
        
        dates.sort { (a, b) -> Bool in
            a.compare(b) == .orderedAscending
        }
        
        guard var date = dates.first else {
            self.Months.append(Date())
            return
        }
        
        Months = []
        
        while date <= Date() {
            print(self.dateFormat.string(from: date))
            Months.append(date)
            date = self.calander.date(byAdding: .month, value: 1, to: date)!
        }
        
        
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
    
    
    func getAmountwithCurrency(Amount : Double , withSize size: CGFloat) -> NSMutableAttributedString {
        
        let wallet = Resource.sharedInstance().currentWallet!.currency.icon
        
        let curfont = UIFont(name: "untitled-font-25", size: size*0.8)!
        let font = UIFont.init(name: "Roboto-Medium", size: size)!
        let CurrIcon = NSAttributedString(string: wallet, attributes: [NSFontAttributeName : curfont])
        let amount = NSAttributedString(string: "\(Amount)", attributes: [NSFontAttributeName : font])
        
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
            return cells[section] == "Transactions" ? expenseTransaction.count == 0 ? 1 : expenseTransaction.count : 1
        }
        else {
            return cells[section] == "Transactions" ? incomeTransaction.count == 0 ? 1 : incomeTransaction.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.section] == "Statistical view" ? 300 : 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch cells[indexPath.section] {
            
        case "Transactions":
            
            if segmentBtn.selectedSegmentIndex == 0 {
                if expenseTransaction.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionCell") as! TaskTitleTableViewCell
                    cell.selectionStyle = .none
                    return cell
                }
            }
            else {
                if incomeTransaction.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NoTransactionCell") as! TaskTitleTableViewCell
                    cell.selectionStyle = .none
                    return cell
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell") as!     TimelineTableViewCell
            let transaction = segmentBtn.selectedSegmentIndex == 0 ? expenseTransaction[indexPath.row] : incomeTransaction[indexPath.row]
            
            cell.categoryIcon.text = transaction.category.icon
            cell.category.text = transaction.category.name
            
            cell.amount.attributedText = getAmountwithCurrency(Amount: transaction.amount , withSize: 20)

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
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            cell.selectionStyle = .none
            self.filterCategoriesAndAmount()
            cell.PieChartView.legend.resetCustom()
            if selectedMonthIndex == Months.count-1 {
                cell.PieChartView.isHidden = false
                cell.noDataLabel.isHidden = true
                if segmentBtn.selectedSegmentIndex == 0 {
                    DrawPieChart(data: foreCastExpences, PieChart: cell.PieChartView)
                }
                else {
                    DrawPieChart(data: foreCastIncome, PieChart: cell.PieChartView)
                }
                cell.PieChartView.chartDescription?.text = ""
                return cell
            }
            
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
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cells[section]
    }
    
    @IBAction func segmentBtnAction(_ sender: Any) {
        tableView.reloadData()
    }
    
    // tag 1 for previous  tag 2 for next
    @IBAction func changeMonth(_ sender: UIButton) {
        if sender.tag == 1 {
            if selectedMonthIndex != 0 {
                selectedMonthIndex-=1
                MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
                ExtractIncomeExpense()
                tableView.reloadData()
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
        }
        else if sender.tag == 2 {
            if selectedMonthIndex != Months.count-1 {
                selectedMonthIndex+=1
                MonthHeader.text = selectedMonthIndex == Months.count-1 ? ("ForeCast Data \(dateFormat.string(from: Months[selectedMonthIndex]))") : dateFormat.string(from: Months[selectedMonthIndex])
                ExtractIncomeExpense()
                tableView.reloadData()
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
        }
    }
    
    //Transaction Delegates
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                
                let date = dateFormat.string(from: transaction.date)
                
                if MonthRelatedTransaction.keys.contains(date){
                    MonthRelatedTransaction[date]!.append(transaction)
                }
                else {
                    MonthRelatedTransaction[date] = [transaction]
                }
                
                if !Months.contains(where: { (dates) -> Bool in
                    return dateFormat.string(from: dates) == date
                }){
                    selectedMonth = Months[selectedMonthIndex]
                    Months.append(transaction.date)
                    sortMonths()
                    selectedMonthIndex = Months.index(of: selectedMonth!)!
                }
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
                
                let date = dateFormat.string(from: transaction.date)
                
                guard let transactions = MonthRelatedTransaction[date] else {
                    return
                }
                
                for i in 0..<transactions.count {
                    if transactions[i].id == transaction.id {
                        MonthRelatedTransaction[date]!.remove(at: i)
                        if MonthRelatedTransaction[date]?.count == 0 {
                            MonthRelatedTransaction.removeValue(forKey: date)
                        }
                        break
                    }
                }
                
                if dateFormat.string(from: Months[selectedMonthIndex]) == date {
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
                selectedMonth = Months[selectedMonthIndex]
                ExtractMonths()
                sortMonths()
                selectedMonthIndex = Months.index(of: (selectedMonth!)) == nil ? Months.count-1 : Months.index(of: selectedMonth!)!
                self.Months.append(self.calander.date(byAdding: .month, value: 1, to: self.Months.last!)!)
                ExtractTransactions()
                ExtractIncomeExpense()
                tableView.reloadData()
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
