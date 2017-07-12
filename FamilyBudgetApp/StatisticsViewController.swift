//
//  StatisticsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 5/24/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController {

    @IBOutlet weak var PieChart: PieChartView!
    var curr = NSAttributedString()
    var isDataAvailable = false
    
    var transactions = [String:Double]()
    var currentWalletTransactions = [Transaction]()
    
    var allWalletsBtn = UIBarButtonItem()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
                self.tabBarController?.tabBar.selectedImageTintColor = Resource.sharedInstance().currentWallet!.color
                self.isDataAvailable = true
                self.filterTransaction()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            curr = NSAttributedString(string: Resource.sharedInstance().currentWallet!.currency.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
            
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            self.tabBarController?.tabBar.unselectedItemTintColor = .lightGray
            self.tabBarController?.tabBar.selectedImageTintColor = Resource.sharedInstance().currentWallet!.color
            self.filterTransaction()
        }
    }
    
    func allWalletsBtnTapped() {
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.present(cont, animated: true, completion: nil)
    }

    
    func ExtractTransactions() {
        currentWalletTransactions = []
        for key in Resource.sharedInstance().transactions.keys {
            let transaction = Resource.sharedInstance().transactions[key]
            if transaction!.walletID == Resource.sharedInstance().currentWalletID {
                currentWalletTransactions.append(transaction!)
            }
        }
    }
    
    func filterTransaction() {
        transactions = [:]
        self.ExtractTransactions()
        for i in 0..<currentWalletTransactions.count {
            if transactions.keys.contains(currentWalletTransactions[i].categoryId) {
                transactions[currentWalletTransactions[i].categoryId] = transactions[currentWalletTransactions[i].categoryId]! + currentWalletTransactions[i].amount
            }
            else {
                transactions[currentWalletTransactions[i].categoryId] = currentWalletTransactions[i].amount
            }
        }
        print(transactions.keys)
        setCharts(data: transactions)
    }
    
    func setCharts(data : [String : Double]) {
        
        var dataEntries : [PieChartDataEntry] = []
        for i in data.keys {
            let dataEntry = PieChartDataEntry(value: data[i]!, label: Resource.sharedInstance().categories[i]?.name, data: nil)
            dataEntries.append(dataEntry)
        }
        let ChartDataSet = PieChartDataSet(values: dataEntries, label: "Units")
        
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
    
    func DrawLineChart(data :[String:Double]){
        
        var dataEntries : [ChartDataEntry] = []
        for i in data.keys {
            let dataEntry = ChartDataEntry(x: data[i]!, y: 0.0)
            dataEntries.append(dataEntry)
        }
        var colors: [UIColor] = []
        
        for i in data.keys {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Units Sold")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeCharts(_ sender: UIButton) {
        
        if sender.tag == 0 {
            filterTransaction()
            self.DrawLineChart(data: transactions)
            PieChart.isHidden = true
            sender.tag = 1
        }
        else {
            filterTransaction()
            self.setCharts(data: transactions)
            PieChart.isHidden = false
            sender.tag = 0
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
