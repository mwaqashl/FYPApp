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

func forecastNextMonth() {
    
    guard let transactions = Resource.sharedInstance().currentWallet?.transactions else {
        print("No Data Available")
        return
        
    }
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "mmm-yyyy"
    
    var monthlyTransactions : MonthlyTransactions = [:]
    var categoryBasedMonthly : CategoryBasedMonthlyTransactions = [:]
    
    
    for trans in transactions {
        
        let date = dateFormat.string(from: trans.date)
        
        if var transes = monthlyTransactions[date] {
            transes.append(trans)
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
        
        let MonthlyTransaction = categoryBasedMonthly[category]
        
        for i in 0..<Months.count {
            
            guard var PerMonthTrans = MonthlyTransaction?[dateFormat.string(from: Months[i])] else {
                continue
            }
            
            for trans in PerMonthTrans {
                
            }
            
            
        }
        
    }
    
    
}


//var CategoryWeights = [String:]


var Months = [Date]()
var dateFormat = DateFormatter()
var calander = NSCalendar.current

func ExtractMonths(){
    dateFormat.dateFormat = "MMM-yyyy"
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
        Months.append(Date())
        return
    }
    
    Months = []
    
    while date <= Date() {
        print(dateFormat.string(from: date))
        Months.append(date)
        date = calander.date(byAdding: .month, value: 1, to: date)!
    }
}


func sortMonths() {
    Months.sort { (date1, date2) -> Bool in
        date1.compare(date2) == .orderedAscending
    }
}












