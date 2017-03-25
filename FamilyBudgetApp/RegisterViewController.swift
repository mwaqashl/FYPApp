//
//  RegisterViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // For Signup
    var date : Double?
    var selectedrow = 0 , previous = 0
    var gend = ["Male","Female"]
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dateofbirth: UITextField!

    var datepicker = UIDatePicker()
    var genderpicker = UIPickerView()
    let dateformat = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderpicker.delegate = self
        genderpicker.dataSource = self
        gender.inputView = genderpicker
        dateofbirth.inputView = datepicker
        
        datepicker.datePickerMode = .date
        dateformat.dateFormat = "dd-MMM-yyyy"
//        
        genderpicker.backgroundColor = .white
        datepicker.backgroundColor = .white
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        gender.inputAccessoryView = toolbar
        dateofbirth.inputAccessoryView = toolbar
        
        // Do any additional setup after loading the view.
    }
    
    func donepressed(){
        if dateofbirth.isEditing {
            date = datepicker.date.timeIntervalSince1970
            dateofbirth.text = dateformat.string(from: datepicker.date)
            //date = datepicker.date as? Double
            print("\(date))")
        }
        if gender.isEditing {
            gender.text = gend[selectedrow]
            previous = selectedrow
        }
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        if gender.isEditing {
            gender.text = gend[previous]
        }
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gend.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gend[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //gender.text = gend[row]
        selectedrow = row
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        var error = ""
        var errorDis = ""
        
        if userName.text == "" {
            error = "User Name cannot be empty"
        }
        else if email.text == "" {
            error = "Email cannot be empty"
        }
        else if password.text! == "" || password.text!.characters.count < 6 || repassword.text! == "" || (repassword.text?.characters.count)! < 6 {
            error = "Password error"
            errorDis = "Password cannot be less than 6 characters"
        }
        else if password.text != repassword.text{
            error = "Password error"
            errorDis = "Password and Re-type Password must be same"
        }
        else if gender.text == "" {
            error = "Gender cannot be empty"
        }
        else if dateofbirth.text == "" {
            error = "Date of Birth cannot be empty"
        }
        

        if error == "" {
            let User = CurrentUser.init(id: "", email: email.text!, userName: userName.text!, imageURL: "", birthdate: date! , deviceID: "", gender: previous)
            
            Auth.sharedInstance().createUser(email: email.text!, password: password.text!, user: User, callback: { (_error) in
                if _error != nil {
                    error = "Error"
                    errorDis = _error!.localizedDescription
                    let alert = UIAlertController(title: error ,message: errorDis, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.performSegue(withIdentifier: "walletsetup", sender: nil)
                }
            })
            
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
