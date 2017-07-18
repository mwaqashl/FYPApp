import UIKit

var cyanColor = UIColor.cyan
var textColor = UIColor(red: 88/255, green: 89/255, blue: 91/255, alpha: 1)
var placeholderColor = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
var blueColor = UIColor(red: 37/255, green: 80/255, blue: 96/255, alpha: 0.7)
var borderColor = UIColor(red: 146/255, green: 148/255, blue: 151/255, alpha: 1)
var colorChoices = [UIColor.black,
                    UIColor.blue,
                    UIColor.brown,
                    UIColor.cyan,
                    UIColor.darkGray,
                    UIColor.green, UIColor.orange, UIColor.yellow,
                    UIColor.purple]
var darkBlueColor = UIColor(red: 24/255, green: 57/255, blue: 31/255, alpha: 1)
var greenColor = UIColor.green
let defaultSettings = UserDefaults.standard
var redColor = UIColor.red
var yellowColor = UIColor.yellow
var menuBorderColor = UIColor(red: 61/255, green: 206/255, blue: 216/255, alpha: 1)

var lightThemeColor = UIColor(red: 205/255, green: 233/255, blue: 178/255, alpha: 1)
var darkThemeColor = UIColor(red: 98/255, green: 141/255, blue: 84/255, alpha: 1)
var midThemeColor = UIColor(red: 117/255, green: 171/255, blue: 87/255, alpha: 1)
var ThemeColor = UIColor(red: 149/255, green: 188/255, blue: 117/255, alpha: 1)
let apiKey = "DB7EGHF7348HD89234Y9834Y98F387934TR9"
let bundleID = "com.teamOfThree.FamilyBudgetAppios"
let notificationRequestURL = "http://penzyserver.herokuapp.com/sendNotification"


func showAlertWithOkayBtn(title: String, desc: String) {
    
    let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
    let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okay)
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    
}

func showAlertForConfirmation(title: String, desc: String, callback: @escaping (Bool) -> Void) {
    
    let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
    
    let okay = UIAlertAction(title: "Confirm", style: .destructive)  { (action) in
        
        callback(true)
        
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        
        callback(false)
        
    }
    alert.addAction(okay)
    alert.addAction(cancel)
    
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    
}


func isValidEmail(testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}
