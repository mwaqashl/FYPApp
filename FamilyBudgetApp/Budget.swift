
import Foundation
import UIKit

class Budget {
    
    var id : String
    var allocAmount : Double
    var title : String
    var period : Int
    var startDate : Date
    var comments : String?
    var isOpen : Bool
    var categories : [Category] {
        var _categories : [Category] = []
        categoryIDs.forEach { (value) in
            if let category = Resource.sharedInstance().categories[value] {
                _categories.append(category)
            }
        }
        return _categories
    }
    fileprivate var categoryIDs: [String]
    var members : [User] {
        var _members : [User] = []
        Resource.sharedInstance().users.forEach { (key,value) in
            if memberIDs.contains(key) {
                _members.append(value)
            }
        }
        return _members
    }
    fileprivate var memberIDs: [String]
    var walletID: String
    var wallet : UserWallet {
        if let _wallet = Resource.sharedInstance().userWallets[walletID]{
            return _wallet
        }
        return UserWallet(id: walletID, name: "Wallet Name", icon: "ꁅ", currencyID: "", creatorID: "", balance: 0.0, totInc: 0.0, totExp: 0.0, creationDate: Date().timeIntervalSince1970, isPersonal: true, memberTypes: [:], isOpen: true, color: textColor.stringRepresentation)
    }
    
    
    init(budgetId : String, allocAmount : Double, title : String, period : Int, startDate : Double, comments : String?, isOpen : Bool, categoryIDs: [String], memberIDs: [String], walletID: String) {
        
        self.id = budgetId
        self.allocAmount = allocAmount
        self.title = title
        self.period = period
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.comments = comments
        self.isOpen = isOpen
        self.categoryIDs = categoryIDs
        self.memberIDs = memberIDs
        self.walletID = walletID
    }
    func daysInbudget() -> Int {
        let endDate = Calendar.current.date(byAdding: .day, value: {
            
            if self.period == 30 {
                return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: self.startDate), month: budgetHelper.getdate(required: "month", date: self.startDate))
            }
            else if self.period == 7 {
                return 7
            }
            else if self.period == 15 {
                return 15
            }
            else if self.period == 60 {
                return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: self.startDate), month: budgetHelper.getdate(required: "month", date: self.startDate)) + budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: self.startDate), month: (budgetHelper.getdate(required: "month", date: self.startDate) + 1))
            }
            else {
                return 365
            }
            }(), to: self.startDate)
        
        
        return daysBetween(date1: startDate, date2: endDate!)

    }
    func daysBetween(date1: Date, date2: Date) -> Int {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: date1)
        let date2 = calendar.startOfDay(for: date2)
        
        let components = calendar.dateComponents([Calendar.Component.day], from: date1, to: date2)
        
        return components.day ?? 0
    }
    func addMember(_ memberId : String){
        if !memberIDs.contains(memberId) {
            memberIDs.append(memberId)
        }
    }
    func removeMember(_ memberId : String){
        for i in 0..<memberIDs.count {
            if memberIDs[i] == memberId {
                memberIDs.remove(at: i)
                return
            }
        }
    }
    func getMemberIDs() -> [String] {
        return memberIDs
    }
    func addCategory(_ categoryId : String){
        if !categoryIDs.contains(categoryId) {
            categoryIDs.append(categoryId)
        }
    }
    func getCategoryIDs() -> [String] {
        return categoryIDs
    }
    func removeCategory(_ categoryId : String){
        for i in 0..<categoryIDs.count {
            if categoryIDs[i] == categoryId {
                categoryIDs.remove(at: i)
                return
            }
        }
    }
}

protocol BudgetDelegate {
    func budgetAdded(_ budget : Budget)
    func budgetUpdated(_ budget : Budget)
    func budgetDeleted(_ budget: Budget)
}
protocol BudgetCategoryDelegate {
    func categoryAdded(_ category: Category, budget : Budget)
    func categoryRemoved(_ category: Category, budget : Budget)
}
protocol BudgetMemberDelegate {
    func memberAdded(_ member : User, budget : Budget)
    func memberLeft(_ member : User, budget : Budget)
}

extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self) == self.compare(date2 as Date)
    }
}

class budgetHelper {
    
    class func getEndDate(budget: Budget) -> Date {
        let endDate = Calendar.current.date(byAdding: .day, value: {
            
            if budget.period == 30 {
                return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: budget.startDate), month: budgetHelper.getdate(required: "month", date: budget.startDate))
            }
            else if budget.period == 7 {
                return 7
            }
            else if budget.period == 15 {
                return 15
            }
            else if budget.period == 60 {
                return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: budget.startDate), month: budgetHelper.getdate(required: "month", date: budget.startDate)) + budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: budget.startDate), month: (budgetHelper.getdate(required: "month", date: budget.startDate) + 1))
            }
            else {
                return 365
            }
        }(), to: budget.startDate)
        return endDate!
    }
    class func budgetTillDate(date: Date, budget: Budget) -> Double {
        let oneDayBudget = budget.allocAmount/Double(budget.daysInbudget())
        let budgetTillDate = oneDayBudget * Double(getdate(required: "day", date: date))
        
        return budgetTillDate
    }
    class func getDaysBetweenDates(firstDate: Date, secondDate: Date) -> Int {
        let cal = Calendar.current
        let diff = cal.dateComponents([.day], from: firstDate, to: secondDate)
        return diff.day!
    }
    
    class func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView, callback: ()->Void ) {
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
        
        let pathAnimat : CABasicAnimation = CABasicAnimation()
        
        pathAnimat.duration = 0.2
        pathAnimat.fromValue = Float(0.0)
        pathAnimat.toValue = Float(1.0)
        //Animation will happen right away
        shapeLayer.add(pathAnimat, forKey: "strokeEnd")
        
        callback()
    }
    
    class func getdate(required: String, date: Date) -> Int {
        let date = date
        
        // *** create calendar object ***
        let calendar = NSCalendar.current
        
        let dateComp = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date as Date)
        
        if required == "month" {
            return dateComp.month!
        }
        else if required == "year" {
            return dateComp.year!
        }
        else if required == "day" {
            return dateComp.day!
        }
        return 0
    }
    
    class func getDaysInMonth(year: Int, month: Int) -> Int{
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    class func percentage(neu:Double, deno:Double) -> Double{
        return (neu/deno)*100
    }
    class func getBudgetPeriod(period: Int) -> String {
        if period == 7 {
            return NSLocalizedString("WEEKLY", comment: "EN: Weekly")
        }
        else if period == 15 {
            return NSLocalizedString("FORNIGHTLY", comment: "EN: Fortnightly")
        }
        else if period == 30 {
            return NSLocalizedString("MONTHLY", comment: "EN: Monthly")
        }
        else if period == 60 {
            return NSLocalizedString("BI_MONTHLY", comment: "EN: Bi-Monthly")
        }
        else {
            return NSLocalizedString("YEARLY", comment: "EN: Yearly")
        }
    }
    class func makeBazierPath(p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint, ofColor: UIColor, view: UIView){
        
        let myBezier = UIBezierPath()
        myBezier.move(to: p1)
        myBezier.addLine(to: p2)
        myBezier.addLine(to: p3)
        myBezier.addLine(to: p4)
        myBezier.close()
        
        let color = ofColor
        color.setStroke()
        myBezier.stroke()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = myBezier.cgPath
        shapeLayer.fillColor = color.cgColor
        
        view.layer.addSublayer(shapeLayer)
    }
    class func getMemberSpendingInBudget(budgetID : String, memberID : String) -> Double {
        var spendings : Double = 0.0
        
        Resource.sharedInstance().transactions.filter { (id, transaction) -> Bool in
            
            return transaction.walletID == Resource.sharedInstance().currentWalletID!
            }.filter { (id, transaction) -> Bool in
                
                return memberID == transaction.transactionById
            }.filter { (id, trans) -> Bool in
                
                return Resource.sharedInstance().budgets[budgetID]!.getCategoryIDs().contains(trans.categoryId)
            }.filter { (id, transaction) -> Bool in
                let endDate = Calendar.current.date(byAdding: .day, value: {
                    
                    if Resource.sharedInstance().budgets[budgetID]?.period == 30 {
                        return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!))
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 7 {
                        return 7
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 15 {
                        return 15
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 60 {
                        return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!)) + budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: (budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!) + 1))
                    }
                    else {
                        return 365
                    }
                }(), to: Resource.sharedInstance().budgets[budgetID]!.startDate)
                
                return transaction.date.isBetween(date: Resource.sharedInstance().budgets[budgetID]!.startDate, andDate: endDate!)
            }.forEach { (id, transaction) in
                print(transaction.id)
                spendings = spendings + transaction.amount
        }
        return spendings
    }
    class func getBudgetSpendings(budgetID : String) -> Double {
        
        var spendings : Double = 0.0
        
        Resource.sharedInstance().transactions.filter { (id, transaction) -> Bool in
            
            return transaction.walletID == Resource.sharedInstance().currentWalletID!
            }.filter { (id, transaction) -> Bool in
                
                return Resource.sharedInstance().budgets[budgetID]!.getMemberIDs().contains(transaction.transactionById)
            }.filter { (id, trans) -> Bool in
                
                return Resource.sharedInstance().budgets[budgetID]!.getCategoryIDs().contains(trans.categoryId)
            }.filter { (id, transaction) -> Bool in
                let endDate = Calendar.current.date(byAdding: .day, value: {
                    
                    if Resource.sharedInstance().budgets[budgetID]?.period == 30 {
                        return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!))
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 7 {
                        return 7
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 15 {
                        return 15
                    }
                    else if Resource.sharedInstance().budgets[budgetID]?.period == 60 {
                        return budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!)) + budgetHelper.getDaysInMonth(year: budgetHelper.getdate(required: "year", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!), month: (budgetHelper.getdate(required: "month", date: (Resource.sharedInstance().budgets[budgetID]?.startDate)!) + 1))
                    }
                    else {
                        return 365
                    }
                }(), to: Resource.sharedInstance().budgets[budgetID]!.startDate)
                
                return transaction.date.isBetween(date: Resource.sharedInstance().budgets[budgetID]!.startDate, andDate: endDate!)
            }.forEach { (id, transaction) in
                print(transaction.id)
                spendings = spendings + transaction.amount
        }
        return spendings
    }
}
