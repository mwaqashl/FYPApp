//
//  StatisticsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/24/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate {

    var isDataAvailable = false
    var isIncomeTapped = false
    var CategoryAndAmount : [String:Double] = [:]
    
    var currentWalletTransactions = [Transaction]()
    var MonthRelatedTransaction = [String:[Transaction]]()
    var dateFormat = DateFormatter()
    
    @IBOutlet weak var nextMonthBtn: UIButton!
    @IBOutlet weak var previousMonthBtn: UIButton!
    @IBOutlet weak var MonthHeader: UILabel!
    var allWalletsBtn = UIBarButtonItem()

    var cells = ["BalanceAmount","AvgIncomeExpense","Stats","IncomeExpense","AvgDailyExpenseIncome"]
    
    var selectedMonthIndex = Int()
    var Months = [Date]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormat.dateFormat = "MMMM-yyyy"
        MonthHeader.text = dateFormat.string(from: Date())
        
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.previousMonthBtn.isEnabled = true
                self.nextMonthBtn.isEnabled = true
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
                self.isDataAvailable = true
                self.ExtractTransactions()
                self.filterCategoriesAndAmount()
                self.sortMonths()
                self.MonthHeader.text = self.dateFormat.string(from: self.Months[self.selectedMonthIndex])
                if self.selectedMonthIndex == 0 {
                    self.previousMonthBtn.isEnabled = false
                }
                else if self.selectedMonthIndex == self.Months.count-1 {
                    self.nextMonthBtn.isEnabled = false
                }
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            self.viewDidLoad()
            self.previousMonthBtn.isEnabled = true
            self.nextMonthBtn.isEnabled = true
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
            self.ExtractTransactions()
            self.filterCategoriesAndAmount()
            self.sortMonths()
            MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
            if self.selectedMonthIndex == 0 {
                self.previousMonthBtn.isEnabled = false
            }
            else if selectedMonthIndex == Months.count-1 {
                self.nextMonthBtn.isEnabled = false
            }
            self.tableView.reloadData()
        }
    }
    
    func allWalletsBtnTapped() {
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.present(cont, animated: true, completion: nil)
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
        selectedMonthIndex = selectedMonthIndex != 0 ? Months.count-1 : 0
    }
    //Categories and its amount
    func filterCategoriesAndAmount() {
        CategoryAndAmount = [:]
        let transaction = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]
        for i in 0..<transaction!.count {
            if CategoryAndAmount.keys.contains(transaction![i].categoryId) {
                CategoryAndAmount[transaction![i].categoryId] = CategoryAndAmount[transaction![i].categoryId]! + transaction![i].amount
            }
            else {
                CategoryAndAmount[transaction![i].categoryId] = transaction![i].amount
            }
        }
    }
    
    func DrawPieChart(data : [String : Double], PieChart : PieChartView) {
        
        var dataEntries : [PieChartDataEntry] = []
        for i in data.keys {
            let dataEntry = PieChartDataEntry(value: data[i]!, label: Resource.sharedInstance().categories[i]!.name, data: nil)
            dataEntries.append(dataEntry)
        }
        let ChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        
        let chartData = PieChartData(dataSet: ChartDataSet)
        
        PieChart.data = chartData
        
        var colors: [UIColor] = []
        
        for i in data.keys {
            let color = Resource.sharedInstance().categories[i]!.color
            colors.append(color)
        }
        
        ChartDataSet.colors = colors
        PieChart.animate(xAxisDuration: 0.4)
        PieChart.holeRadiusPercent = 0.3
        PieChart.transparentCircleColor = UIColor.clear
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row] == "Stats" ? 300 : 60
    }
//    var cells = ["BalanceAmount","AvgIncomeExpense","Stats","IncomeExpense","AvgDailyExpenseIncome"]

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
            
        case "BalanceAmount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") as! BalanceAmountTableViewCell
            cell.BalanceHeader.text = "Remaining Balance"
            cell.BalanceAmount.attributedText = getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: cell.BalanceAmount.font.pointSize)
            cell.BalanceAmount.textColor = .blue
            cell.backgroundColor? = .white
            cell.selectionStyle = .none
            return cell
        
        case "AvgIncomeExpense":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            cell.ExpenseBtn.isHidden = true
            cell.IncomeExpandBtn.isHidden = true
            var income = 0.0
            var expense = 0.0
            
            for i in 0..<currentWalletTransactions.count {
                if currentWalletTransactions[i].isExpense {
                    expense += currentWalletTransactions[i].amount
                }
                else {
                    income += currentWalletTransactions[i].amount
                }
            }
            
            cell.ExpenseHeader.text = "Avg. Monthly Expense"
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense/Double(Months.count), of: cell.ExpenseAmount.font.pointSize)
            cell.ExpenseAmount.textColor = .red
            cell.IncomeHeader.text = "Avg. Monthly Income"
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income/Double(Months.count), of: cell.ExpenseAmount.font.pointSize)
            cell.IncomeAmunt.textColor = .green
            cell.backgroundColor? = .clear
            cell.selectionStyle = .none
            return cell
            
        case "IncomeExpense":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            cell.ExpenseBtn.tag = 2
            cell.IncomeExpandBtn.tag = 1
            
            cell.ExpenseBtn.addTarget(self, action: #selector(self.statsDetails(_:)), for: .touchUpInside)
            cell.IncomeExpandBtn.addTarget(self, action: #selector(self.statsDetails(_:)), for: .touchUpInside)
            
            var income = 0.0
            var expense = 0.0
            let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]
            for i in 0..<transactions!.count {
                if transactions![i].isExpense {
                    expense += transactions![i].amount
                }
                else {
                    income += transactions![i].amount
                }
            }
            
            cell.ExpenseHeader.text = "Total Expense (This Month)"
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font.pointSize)
            
            cell.IncomeHeader.text = "Total Income (This Month)"
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, of: cell.ExpenseAmount.font.pointSize)
            cell.selectionStyle = .none
            return cell
            
        case "AvgDailyExpenseIncome":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            
            cell.ExpenseBtn.isHidden = true
            cell.IncomeExpandBtn.isHidden = true
            
            var income = 0.0
            var expense = 0.0
            let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]
            for i in 0..<transactions!.count {
                if transactions![i].isExpense {
                    expense += transactions![i].amount
                }
                else {
                    income += transactions![i].amount
                }
            }

            cell.ExpenseHeader.text = "Avg. Daily Expense"
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font.pointSize)
            
            cell.IncomeHeader.text = "Avg. Daily Income"
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income , of: cell.ExpenseAmount.font.pointSize)
            cell.selectionStyle = .none
            cell.backgroundColor? = .lightGray
            cell.backgroundColor?.withAlphaComponent(0.3)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            self.filterCategoriesAndAmount()
            cell.PieChartView.legend.resetCustom()
            if CategoryAndAmount.count != 0 {
                self.DrawPieChart(data: CategoryAndAmount, PieChart: cell.PieChartView)
            }
            else {
                cell.PieChartView.data = nil
            }
            cell.PieChartView.chartDescription?.text = ""
            cell.PieChartView.noDataText = "No Transaction In This Budget"
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @IBAction func ChangeMonth(_ sender: UIButton) {
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
            tableView.reloadData()
        }
    }
    
    func statsDetails(_ sender : UIButton){
        if sender.tag == 1 {
            isIncomeTapped = true
        }
        else if sender.tag == 2 {
            isIncomeTapped = false
        }
        performSegue(withIdentifier: "StatsDescription", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StatsDescription" {
            let destination = segue.destination as! StatisticsDetailViewController
            destination.CategoryAndAmount = self.CategoryAndAmount
            destination.selectedMonthTransactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]!
            destination.MonthRelatedTransaction = self.MonthRelatedTransaction
            destination.currentWalletTransactions = self.currentWalletTransactions
            destination.selectedMonthIndex = self.selectedMonthIndex
            destination.Months = self.Months
            
            
        }
    }
    
    func transactionAdded(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                let date = dateFormat.string(from: transaction.date)
                currentWalletTransactions.append(transaction)
                if Months[selectedMonthIndex] == transaction.date {
                    MonthRelatedTransaction[date]?.append(transaction)
                    tableView.reloadData()
                }
            }
        }
    }
    
    func transactionDeleted(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                currentWalletTransactions  = Resource.sharedInstance().currentWallet!.transactions
                let date = dateFormat.string(from: transaction.date)
                if Months[selectedMonthIndex] == transaction.date {
                    let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]
                    for i in 0..<transactions!.count {
                        if transactions![i].id == transaction.id {
                            MonthRelatedTransaction[date]!.remove(at: i)
                            break
                        }
                    }
                    tableView.reloadData()
                }
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                ExtractTransactions()
                filterCategoriesAndAmount()
                tableView.reloadData()
            }
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
