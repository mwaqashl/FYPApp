//
//  ChangePasswordViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas on 15/07/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textfield1: UITextField!
    @IBOutlet weak var textFieild2: UITextField!
    @IBOutlet weak var actionBtn: UIButton!

    @IBOutlet var viewsForShadow: [UIView]!
    
    var isLoginVerified = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in viewsForShadow {
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowOpacity = 0.6
            view.layer.shadowRadius = 2
            view.layer.shadowColor = darkThemeColor.cgColor
        }
        
        infoLabel.text = "Please login to continue"
        textfield1.placeholder = "Email Address"
        textFieild2.placeholder = "Password"
        textFieild2.isSecureTextEntry = true
        textfield1.isSecureTextEntry = false
        textfield1.keyboardType = .emailAddress
        textFieild2.keyboardType = .default
        actionBtn.setTitle("Login", for: .normal)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func action(_ sender: Any) {
        
        if !isLoginVerified {
            
            var error = ""
            
            if textfield1.text! == "" || !isValidEmail(testStr: textfield1.text!) {
                error = "Invalid Email Address"
            }
            else if textFieild2.text == "" {
                error = "Password Error"
            }
            
            if error == "" {
                Authentication.sharedInstance().reAuthenticateUser(with: textfield1.text!, password: textFieild2.text!, with: { (success) in
                    if success {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.infoLabel.alpha = 0
                            self.actionBtn.alpha = 0
                            self.textFieild2.alpha = 0
                            self.textfield1.alpha = 0
                            
                        }, completion: { (suc) in
                            
                            self.infoLabel.text = "Please Enter new Password"
                            self.textfield1.placeholder = "New Password"
                            self.textFieild2.placeholder = "Re Enter Password"
                            self.textFieild2.isSecureTextEntry = true
                            self.textfield1.isSecureTextEntry = true
                            self.textfield1.keyboardType = .default
                            self.textFieild2.keyboardType = .default
                            self.actionBtn.setTitle("Update", for: .normal)
                            self.isLoginVerified = true
                            
                            UIView.animate(withDuration: 0.2, animations: { 
                                self.infoLabel.alpha = 1
                                self.actionBtn.alpha = 1
                                self.textFieild2.alpha = 1
                                self.textfield1.alpha = 1
                            })
                            
                        })
                    }
                })
                
            }
            
        }
        else {
            
            if textfield1.text == textFieild2.text && textfield1.text != "" {
                
                Authentication.sharedInstance().updatePassword(newPassword: textFieild2.text!, callback: { (success) in
                    
                    if success {
                        
                        let alert = UIAlertController(title: "Success", message: "Password Successfully Changed", preferredStyle: .alert)
                        
                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                })
                
            }
            
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
