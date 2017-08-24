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
    var foreCast = [statsModel]()
    var ForeCastIncome = Double()
    var ForeCastExpense = Double()
    
    var currentWalletTransactions = [Transaction]()
    var MonthRelatedTransaction = [String:[Transaction]]()
    var dateFormat = DateFormatter()
    
    @IBOutlet weak var nextMonthBtn: UIButton!
    @IBOutlet weak var previousMonthBtn: UIButton!
    @IBOutlet weak var MonthHeader: UILabel!
    
    var allWalletsBtn = UIBarButtonItem()
    var SettingsBtn = UIBarButtonItem()
    var cells = ["BalanceAmount","AvgIncomeExpense","Stats","IncomeExpense","AvgDailyExpenseIncome"]
    var foreCastCells = ["BalanceAmount","AvgIncomeExpense","Stats","IncomeExpense"]
    var selectedMonth : Date?
    var selectedMonthIndex = Int()
    var Months = [Date]()
    var calander = NSCalendar.current

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextMonthBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        
        dateFormat.dateFormat = "MMMM-yyyy"
        MonthHeader.text = dateFormat.string(from: Date())
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: darkThemeColor]
        
        SettingsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(self.SettingsBtnTapped))
        SettingsBtn.tintColor = darkThemeColor
        
        self.navigationItem.rightBarButtonItem = SettingsBtn
        
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
                
                self.isDataAvailable = true
                
                self.ExtractTransactions()
                self.ExtractMonths()
                
                self.MonthHeader.text = self.dateFormat.string(from: self.Months[self.selectedMonthIndex])
                
                if self.selectedMonthIndex == 0  {
                    self.previousMonthBtn.isEnabled = false
                }
                self.foreCast = forecastNextMonth()
                self.ForeCastExpense = 0.0
                self.ForeCastIncome = 0.0
                for forecast in self.foreCast {
                    if Resource.sharedInstance().categories[forecast.CategoryID]!.isExpense {
                        self.self.ForeCastExpense += forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
                    } else {
                        self.ForeCastIncome += forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
                    }
                }
    
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Resource.sharedInstance().currentWalletID != nil {
            
            self.previousMonthBtn.isEnabled = true
            self.nextMonthBtn.isEnabled = true
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = darkThemeColor
            foreCast = forecastNextMonth()

            ForeCastExpense = 0.0
            ForeCastIncome = 0.0
            for forecast in foreCast {
                if Resource.sharedInstance().categories[forecast.CategoryID]!.isExpense {
                    ForeCastExpense += forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
                } else {
                    ForeCastIncome += forecast.weight*forecast.avgTransactionAmount*forecast.avgNoOfTrans
                }
            }
            
            Months = []
            
            self.ExtractMonths()
            self.ExtractTransactions()

            MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
            
            if self.selectedMonthIndex == 0  {
                self.previousMonthBtn.isEnabled = false
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
        
        let cont = HomeViewController.shared
        self.present(cont, animated: true, completion: nil)
    }
    
    func ExtractMonths(){
        guard let transactions = Resource.sharedInstance().currentWallet?.transactions
            else {
            Months = []
            Months.append(Date())
            Months.append(calander.date(byAdding: .month, value: 1, to: Date())!)
            selectedMonthIndex = Months.count-2
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
            Months = []
            Months.append(Date())
            Months.append(calander.date(byAdding: .month, value: 1, to: Date())!)
            selectedMonthIndex = Months.count-2
            return
        }
        
        Months = []
        var endDate = calander.date(byAdding: .month, value: 1, to: Date())
        while date <= endDate! {
            print(self.dateFormat.string(from: date))
            Months.append(date)
            date = self.calander.date(byAdding: .month, value: 1, to: date)!
        }
        selectedMonthIndex = Months.count-2
        
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
    
    //Categories and its amount
    func filterCategoriesAndAmount() {
        CategoryAndAmount = ["Income" : 0.0 , "Expense" : 0.0]
        
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
    
    func getAmountwithCurrency(Amount : Double , withSize size: CGFloat) -> NSMutableAttributedString {
        
        let wallet = Resource.sharedInstance().currentWallet!.currency.icon
        
        let curfont = UIFont(name: "untitled-font-25", size: size*0.8)!
        let font = UIFont.init(name: "Roboto-Medium", size: size)!
        let CurrIcon = NSAttributedString(string: wallet, attributes: [NSFontAttributeName : curfont])
        let amount = NSAttributedString(string: String(format : "%.2f", Amount), attributes: [NSFontAttributeName : font])
        
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
        return selectedMonthIndex == Months.count-1 ? foreCastCells.count : cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row] == "Stats" ? 300 : 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cells[indexPath.row] {
            
        case "BalanceAmount":
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") as! BalanceAmountTableViewCell
            cell.BalanceHeader.text = "Remaining Balance"
            cell.BalanceAmount.attributedText = getAmountwithCurrency(Amount: Resource.sharedInstance().currentWallet!.balance, withSize: 20)
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
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense/Double(Months.count), withSize: 17)
            cell.ExpenseAmount.textColor = .red
            cell.IncomeHeader.text = "Avg. Monthly Income"
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income/Double(Months.count), withSize: 17)
            cell.IncomeAmunt.textColor = darkThemeColor
            cell.backgroundColor? = .clear
            cell.selectionStyle = .none
            return cell
            
        case "IncomeExpense":
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomeExpenceCell") as! ExpenseAndIncomeTableViewCell
            cell.ExpenseBtn.tag = 2
            cell.IncomeExpandBtn.tag = 1
            
            cell.selectionStyle = .none
            
            cell.IncomeExpandBtn.isHidden = false
            cell.ExpenseBtn.isHidden = false
           
            for view in cell.detailIndicators {
                view.isHidden = false
                view.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
            }
            
            cell.ExpenseBtn.addTarget(self, action: #selector(self.statsDetails), for: .touchUpInside)
            cell.IncomeExpandBtn.addTarget(self, action: #selector(self.statsDetails), for: .touchUpInside)
            
            if Months.count-1 == selectedMonthIndex {
                cell.ExpenseHeader.text = "Expected Total Expense"
                cell.IncomeHeader.text = "Expected Total Income"
                
            
                cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: ForeCastExpense, withSize: 17)
                
                cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: ForeCastIncome, withSize: 17)
                
                return cell
            }
            
            cell.ExpenseHeader.text = "Total Expense (This Month)"
            cell.IncomeHeader.text = "Total Income (This Month)"
            
            var income = 0.0
            var expense = 0.0
            
            
            guard let transactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])] else {
                
                cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, withSize: 17)
                cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, withSize: 17)
                for view in cell.detailIndicators {
                    view.isHidden = true
                }
                cell.IncomeExpandBtn.isHidden = true
                cell.ExpenseBtn.isHidden = true
                
                return cell
            }
            
            cell.ExpenseBtn.isHidden = false
            cell.IncomeExpandBtn.isHidden = false
            
            
            
            for i in 0..<transactions.count {
                if transactions[i].isExpense {
                    expense += transactions[i].amount
                }
                else {
                    income += transactions[i].amount
                }
            }
            
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, withSize: 17)
            
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, withSize: 17)
            
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
                
                cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, withSize: 17)
                cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income, withSize: 17)
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
            
            cell.ExpenseAmount.attributedText = getAmountwithCurrency(Amount: expense, withSize: 17)
            
            cell.IncomeAmunt.attributedText = getAmountwithCurrency(Amount: income , withSize: 17)
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell") as! BudgetStatsTableViewCell
            self.filterCategoriesAndAmount()
            cell.PieChartView.legend.resetCustom()
            
            cell.selectionStyle = .none
            
            if selectedMonthIndex == Months.count-1 {
                let dic = ["Income":ForeCastIncome,"Expense":ForeCastExpense]
                cell.noDataLabel.isHidden = ForeCastIncome != 0 || ForeCastExpense != 0
                cell.PieChartView.isHidden = ForeCastIncome == 0 && ForeCastExpense == 0
                DrawPieChart(data: dic, PieChart: cell.PieChartView)
                cell.PieChartView.chartDescription?.text = ""
                return cell
            }
            else {
                if CategoryAndAmount.isEmpty {
                    cell.PieChartView.data = nil
//                    cell.PieChartView.noDataText = "No transaction Available"
                    cell.noDataLabel.isHidden = false
                    cell.PieChartView.isHidden = true
                }
                else {
                    cell.noDataLabel.isHidden = true
                    cell.PieChartView.isHidden = false
                    self.DrawPieChart(data: CategoryAndAmount, PieChart: cell.PieChartView)
                }
            }
            cell.PieChartView.chartDescription?.text = ""
            return cell
        }
    }
    
    @IBAction func ChangeMonth(_ sender: UIButton) {
        if sender.tag == 1 {
            if selectedMonthIndex != 0 {
                selectedMonthIndex-=1
                MonthHeader.text = dateFormat.string(from: Months[selectedMonthIndex])
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
            if selectedMonthIndex == Months.count-1 {
                destination.stats = foreCast
            }
            else {
                destination.selectedMonthTransactions = MonthRelatedTransaction[dateFormat.string(from: Months[selectedMonthIndex])]!
            }
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
                
                if dateFormat.string(from: Months[selectedMonthIndex]) == date {
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
                    tableView.reloadData()
                }
            }
        }
    }
    
    func transactionUpdated(_ transaction: Transaction) {
        if isDataAvailable {
            if transaction.walletID == Resource.sharedInstance().currentWalletID! {
                ExtractMonths()
                ExtractTransactions()
                sortMonths()
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
