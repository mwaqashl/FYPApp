//
//  ForecastManager.swift
//  FamilyBudgetApp
//
//  Created by mac on 7/18/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import Foundation
import UIKit

typealias MonthlyTransactions = [String:[Transaction]]
typealias CategoryBasedMonthlyTransactions = [String:MonthlyTransactions]

class statsModel {
    var CategoryID : String = ""
    
    var weight : Double {
        
        var previous = transactionAmount.first
        
        var tempRatio = [Double]()
        
        for amount in transactionAmount {
            tempRatio.append(amount/previous!)
            previous = amount
        }
        
        var sum : Double = 0.0

        for ratios in tempRatio {
            sum+=ratios
        }
        
        return Double(sum/Double(tempRatio.count))
        
    }
    
    var transactionAmount = [Double]()
    
    var avgTransactionAmount : Double {
        
        var sum : Double = 0.0
        for trans in self.transactionAmount {
            sum += trans
        }
        
        return sum/Double(self.transactionAmount.count)
        
    }
    
    var noOfTransaction = [Double]()
    
    var avgNoOfTrans :Double {
        
        var sum : Double = 0.0
        for trans in self.noOfTransaction {
            sum += trans
        }
        return Double(sum/Double(self.noOfTransaction.count))
    }
}


func forecastNextMonth() -> [statsModel] {
    
    var forecast : [statsModel] = []

    guard let transactions = Resource.sharedInstance().currentWallet?.transactions else {
        print("No Data Available")
        return []
    }
    
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM-yyyy"
    
    var monthlyTransactions : MonthlyTransactions = [:]
    var categoryBasedMonthly : CategoryBasedMonthlyTransactions = [:]
    
    
    for trans in transactions {
        
        let date = dateFormat.string(from: trans.date)
        
        if var transes = monthlyTransactions[date] {
            transes.append(trans)
            monthlyTransactions[date] = transes
        }
        else {
            monthlyTransactions[date] = [trans]
        }
        
    }
    
    for monthTransactions in monthlyTransactions {
        
        for transaction in monthTransactions.value {
            
            let cat = transaction.categoryId
            
            if var transes = categoryBasedMonthly[cat] {
                let month = dateFormat.string(from: transaction.date)
                guard var monthTs = transes[month] else {
                    let monthTranses = [month:[transaction]]
                    categoryBasedMonthly[cat] = monthTranses
                    continue
                }
                monthTs.append(transaction)
                transes[month] = monthTs
                categoryBasedMonthly[cat] = transes
                
            }
            else {
                let monthTrans : MonthlyTransactions = [dateFormat.string(from: transaction.date):[transaction]]
                categoryBasedMonthly[cat] = monthTrans
            }
            
        }
        
    }
    
    
    
    for category in categoryBasedMonthly.keys {
        
        let currentStats = statsModel()
        currentStats.CategoryID = category
        let MonthlyTransaction = categoryBasedMonthly[category]
        
        var AmountPerMonth = [Double]()
        
        for i in MonthlyTransaction!.keys {
            
            guard var PerMonthTrans = MonthlyTransaction?[i] else {
                currentStats.transactionAmount.append(0)
                continue
            }
            var totalAmount = 0.0
            for trans in PerMonthTrans {
                totalAmount += trans.amount
            }
            currentStats.transactionAmount.append(Double(totalAmount))
            currentStats.noOfTransaction.append(Double(PerMonthTrans.count))
            
        }
        
        forecast.append(currentStats)
    }
    
    return forecast
    
}


//var CategoryWeights = [String:]


//var Months = [Date]()
//var dateFormat = DateFormatter()
//var calander = NSCalendar.current

//func ExtractMonths(){
//    dateFormat.dateFormat = "MMM-yyyy"
//    guard let transactions = Resource.sharedInstance().currentWallet?.transactions
//        else {
//            return
//    }
//    var dates = [Date]()
//    for i in 0..<transactions.count {
//        dates.append(transactions[i].date)
//    }
//    
//    dates.sort { (a, b) -> Bool in
//        a.compare(b) == .orderedAscending
//    }
//    
//    guard var date = dates.first else {
//        Months.append(Date())
//        return
//    }
//    
//    Months = []
//    
//    while date <= Date() {
//        print(dateFormat.string(from: date))
//        Months.append(date)
//        date = calander.date(byAdding: .month, value: 1, to: date)!
//    }
//}


//func sortMonths() {
//    Months = []
//    for keys in MonthlyTransactions.Key {
//        Months.append(dateFormat.date(from: key))
//    }
//    Months.sort { (date1, date2) -> Bool in
//        date1.compare(date2) == .orderedAscending
//    }
//}












