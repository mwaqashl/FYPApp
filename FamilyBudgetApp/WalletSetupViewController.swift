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
    var cname = ["United State Dollar","Saudi Riyal","Euro","Pakistani Rupees","Pound"]
    var ccode = ["USD","SAR","EUR","Rs","PD"]
    var selectedindex = 0, previousindex = 0
    
    //For Wallet Setup
    @IBOutlet weak var walletname: UITextField!
    @IBOutlet weak var initialamount: UITextField!
    @IBOutlet weak var currencyName: UITextField!
    @IBOutlet weak var currencyIcon: UITextField!
    
    var currencypicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Currency picker
        currencypicker.dataSource = self
        currencypicker.delegate = self
        currencyName.inputView = currencypicker
        currencyIcon.inputView = currencypicker
        
        currencypicker.backgroundColor = .white
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        currencyName.inputAccessoryView = toolbar
        currencyIcon.inputAccessoryView = toolbar

        // Do any additional setup after loading the view.
    }
    
    func donepressed(){
        currencyName.text = cname[selectedindex]
        currencyIcon.text = ccode[selectedindex]
        previousindex = selectedindex
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        currencyName.text = cname[previousindex]
        currencyIcon.text = ccode[previousindex]
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cname.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(cname[row])\t\t\t\(ccode[row])"
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
            error = "Wallet Name is Epmty"
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
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
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
