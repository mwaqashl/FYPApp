//
//  StatisticsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/24/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDelegate, WalletDelegate {
    
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
    var SettingsBtn = UIBarButtonItem()
    var cells = ["BalanceAmount","AvgIncomeExpense","Stats","IncomeExpense","AvgDailyExpenseIncome"]
    
    var selectedMonthIndex = Int()
    var Months = [Date]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextMonthBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        
        dateFormat.dateFormat = "MMMM-yyyy"
        MonthHeader.text = dateFormat.string(from: Date())
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        SettingsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(self.SettingsBtnTapped))
        SettingsBtn.tintColor = darkThemeColor
        
        self.navigationItem.rightBarButtonItem = SettingsBtn
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
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
            
            self.previousMonthBtn.isEnabled = true
            self.nextMonthBtn.isEnabled = true
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
            
            self.ExtractTransactions()
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
    
    func SettingsBtnTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(cont, animated: true, completion: nil)
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
        if Months.count == 0 {
            Months.append(Date())
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
        CategoryAndAmount = ["Income":0.0 , "Expense":0.0]
        
        guard let transaction = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])] else {
            CategoryAndAmount = [:]
            return
        }
        
        for i in 0..<transaction.count {
            if (transaction[i].isExpense) {
                CategoryAndAmount["Expense"] = CategoryAndAmount["Expense"]! + transaction[i].amount
            }
            else {
                CategoryAndAmount["Income"] = CategoryAndAmount["Income"]! + transaction[i].amount
            }
        }
    }
    
    func DrawPieChart(data : [String : Double], PieChart : PieChartView) {
        
        var dataEntries : [PieChartDataEntry] = []
        for i in data.keys {
            let dataEntry = PieChartDataEntry(value: data[i]!, label: i, data: nil)
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        
        for i in data.keys {
            let color = i == "Income" ? darkThemeColor : UIColor.red
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
    func getAmountwithCurrency(Amount : Double , of font : UIFont, withSize size: CGFloat) -> NSMutableAttributedString {
        
        let wallet = Resource.sharedInstance().currentWallet!.currency.icon
        
        let curfont = UIFont(name: "untitled-font-25", size: size*0.7)!
        
        let CurrIcon = NSAttributedString(string: wallet, attributes: [NSFontAttributeName : curfont])
        let amount = NSAttributedString(string: "\(Amount)", attributes: [NSFontAttributeName : font])
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
            
        case "BalanceAmount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") as! BalanceAmountTableViewCell
            cell.BalanceHeader.text = "Remaining Balance"
            cell.BalanceAmount.attributedText = getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, of: cell.BalanceAmount.font, withSize: 20)
            cell.BalanceAmount.textColor = .blue
            cell.selectionStyle = .none
            return cell
            
        case "AvgIncomeExpense":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            cell.ExpenseBtn.isHidden = true
            cell.IncomeExpandBtn.isHidden = true
            for view in cell.detailIndicators {
                view.isHidden = true
            }
            
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
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense/Double(Months.count), of: cell.ExpenseAmount.font, withSize: 17)
            cell.ExpenseAmount.textColor = .red
            cell.IncomeHeader.text = "Avg. Monthly Income"
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income/Double(Months.count), of: cell.ExpenseAmount.font, withSize: 17)
            cell.IncomeAmunt.textColor = darkThemeColor
            cell.backgroundColor? = .clear
            cell.selectionStyle = .none
            return cell
            
        case "IncomeExpense":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            cell.ExpenseBtn.tag = 2
            cell.IncomeExpandBtn.tag = 1
            
            cell.ExpenseBtn.addTarget(self, action: #selector(self.statsDetails), for: .touchUpInside)
            cell.IncomeExpandBtn.addTarget(self, action: #selector(self.statsDetails), for: .touchUpInside)
            
            var income = 0.0
            var expense = 0.0
            
            cell.ExpenseHeader.text = "Total Expense (This Month)"
            cell.IncomeHeader.text = "Total Income (This Month)"
            cell.selectionStyle = .none
            
            guard let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])] else {
                
                cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font, withSize: 17)
                cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, of: cell.ExpenseAmount.font, withSize: 17)
                cell.ExpenseBtn.isHidden = true
                cell.IncomeExpandBtn.isHidden = true
                
                return cell
            }
            
            cell.ExpenseBtn.isHidden = false
            cell.IncomeExpandBtn.isHidden = false
            for view in cell.detailIndicators {
                view.isHidden = false
                view.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
            }
            
            
            
            for i in 0..<transactions.count {
                if transactions[i].isExpense {
                    expense += transactions[i].amount
                }
                else {
                    income += transactions[i].amount
                }
            }
            
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font, withSize: 17)
            
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, of: cell.ExpenseAmount.font, withSize: 17)
            
            return cell
            
        case "AvgDailyExpenseIncome":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            
            cell.ExpenseBtn.isHidden = true
            cell.IncomeExpandBtn.isHidden = true
            for view in cell.detailIndicators {
                view.isHidden = true
            }
            
            var income = 0.0
            var expense = 0.0
            
            cell.ExpenseHeader.text = "Avg. Daily Expense"
            cell.IncomeHeader.text = "Avg. Daily Income"
            cell.selectionStyle = .none
            
            guard let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])] else {
                
                cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font, withSize: 17)
                cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, of: cell.ExpenseAmount.font, withSize: 17)
                return cell
            }
            
            for i in 0..<transactions.count {
                if transactions[i].isExpense {
                    expense += transactions[i].amount
                }
                else {
                    income += transactions[i].amount
                }
            }
            
            
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, of: cell.ExpenseAmount.font, withSize: 17)
            
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income , of: cell.ExpenseAmount.font, withSize: 17)
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            self.filterCategoriesAndAmount()
            cell.PieChartView.legend.resetCustom()
            if CategoryAndAmount.isEmpty {
                cell.PieChartView.data = nil
                cell.PieChartView.noDataText = "No transaction Available"
            }
            else {
                self.DrawPieChart(data: CategoryAndAmount, PieChart: cell.PieChartView)
            }
            cell.PieChartView.chartDescription?.text = ""
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
    
    func statsDetails(sender : UIButton){
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
            
            destination.selectedMonthTransactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]!
            destination.MonthRelatedTransaction = self.MonthRelatedTransaction
            destination.currentWalletTransactions = self.currentWalletTransactions
            destination.selectedMonthIndex = self.selectedMonthIndex
            destination.Months = self.Months
            destination.isIcomeTapped = self.isIncomeTapped
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
    
    //Wallet Delegates
    func walletUpdated(_ wallet: UserWallet) {
        
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if isDataAvailable {
            if wallet.id == Resource.sharedInstance().currentWalletID {
                
                Resource.sharedInstance().currentWalletID! = Resource.sharedInstance().currentUserId!
                
                self.previousMonthBtn.isEnabled = true
                self.nextMonthBtn.isEnabled = true
                
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
                
                self.ExtractTransactions()
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
    }
    
    func walletAdded(_ wallet: UserWallet) {
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
