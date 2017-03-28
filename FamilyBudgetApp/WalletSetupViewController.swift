//
//  WalletSetupViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class WalletSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //Currency
    var selectedindex = 0
    
    
    //For Wallet Setup
    @IBOutlet weak var walletname: UITextField!
    @IBOutlet weak var initialamount: UITextField!
    @IBOutlet weak var currencyName: UITextField!
    @IBOutlet weak var currencyCode: UITextField!
    @IBOutlet weak var currencyIcon: UILabel!
    
    var currencypicker = UIPickerView()
    var wallet : UserWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Currency picker
        currencypicker.dataSource = self
        currencypicker.delegate = self
        currencyName.inputView = currencypicker
        currencyCode.inputView = currencypicker
        
        currencypicker.backgroundColor = .white
        
        wallet = UserWallet(id: "new", name: "", icon: "", currencyID: "", creatorID: Resource.sharedInstance().currentUserId!, balance: 0, totInc: 0, totExp: 0, creationDate: Date().timeIntervalSince1970, isPersonal: false, memberTypes: [:], isOpen: true, color: UIColor.blue.stringRepresentation)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        currencyName.inputAccessoryView = toolbar
        currencyCode.inputAccessoryView = toolbar

        // Do any additional setup after loading the view.
    }
    
    func donepressed(){
        
        let all = Array(Resource.sharedInstance().currencies.keys)
        let this = all[selectedindex]
        
        wallet?.currencyID = this
        currencyIcon.text = wallet!.currency.icon
        currencyCode.text = wallet!.currency.code
        currencyName.text = wallet!.currency.name
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        if wallet!.currencyID != "" {
            currencyIcon.text = wallet!.currency.icon
            currencyCode.text = wallet!.currency.code
            currencyName.text = wallet!.currency.name
        }
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print(Resource.sharedInstance().currencies.count)
        return Resource.sharedInstance().currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        let all = Array(Resource.sharedInstance().currencies.keys)
        let this = all[row]
        
        let attString = NSAttributedString(string: Resource.sharedInstance().currencies[this]!.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
        
        let attString2 = NSAttributedString(string: " - \(Resource.sharedInstance().currencies[this]!.name) - \(Resource.sharedInstance().currencies[this]!.code)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
        
        let str = NSMutableAttributedString()
        str.append(attString)
        str.append(attString2)
        
        pickerLabel.attributedText = str
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedindex = row
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func FinshButton(_ sender: Any) {
        var error = ""
        var errorDis = ""
        
        if walletname.text == "" {
            error = "Wallet Name is Empty"
            errorDis = "Please Enter Wallet Name"
        }
        else if initialamount.text == "" {
            error = "Initial Amount is Empty"
            errorDis = "Please Enter initial amount for Wallet"
        }
        else if currencyName.text == "" {
            error = "No currency Selected"
            errorDis = "Please select currency"
        }
        
        if error == "" {
            
            let personalWallet = UserWallet(id: "", name: walletname!.text!, icon: "", currencyID: "", creatorID: Auth.sharedInstance().authUser!.getUserID(), balance: Double(initialamount.text!)!, totInc: 0.0, totExp: 0.0, creationDate: Date().timeIntervalSince1970*1000, isPersonal: true, memberTypes: [(Auth.sharedInstance().authUser?.getUserID())! : .owner], isOpen: true, color: "10:188:228:1")
            
            let walletid = WalletManager.sharedInstance().addWallet(personalWallet)
            if walletid != "" {
                Resource.sharedInstance().currentWalletID = walletid
            self.performSegue(withIdentifier: "main", sender: nil)
            }
        }
        else {
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func findFirstVC(cont: UIViewController) -> UIViewController {
        
        if cont is ViewController {
            return cont
            
        }else {
            return findFirstVC(cont: cont.presentingViewController!)
        }
        
        
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        Auth.sharedInstance().logOutUser(callback: {
            (err) in
            
            if err == nil {
                findFirstVC(cont: self).dismiss(animated: true, completion: nil)
            }
            else {
                print(err?.localizedDescription)
            }
        })
        
        
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
