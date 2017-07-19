//
//  ViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 17/02/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    
    @IBOutlet var viewsForShadow: [UIView]!
    
    var isKeyboardOpen = false
    var tap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true
        emailAddress.autocorrectionType = .no
        emailAddress.delegate = self
        password.delegate = self
        backBtn.layer.borderWidth = 1
        backBtn.layer.borderColor = UIColor.white.cgColor
        tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        for view in viewsForShadow {
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowOpacity = 0.6
            view.layer.shadowRadius = 2
            view.layer.shadowColor = darkThemeColor.cgColor
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewTapped() {
        self.view.endEditing(true)
    }

    @IBAction func backBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        let activity = UIActivityIndicatorView(frame: self.view.frame)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        activity.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(activity)
        var error = ""
        var errorDis = ""
        
        if emailAddress.text == "" {
            error = "Email Address cannot be empty"
        }
        else if password.text == "" || password.text!.characters.count < 6 {
            error = "Password error"
            errorDis = "Password cannot be less than 6 characters"
        }
        
        if error == "" {
            
            Authentication.sharedInstance().signIn(email: emailAddress.text!, password: password.text!, callback: { (isNewUser, _error) in
                if _error != nil {
                    error = "Error"
                    errorDis = _error?.localizedDescription ?? "Some error Occured"
                    let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    activity.stopAnimating()
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    activity.stopAnimating()
                    
                    if isNewUser {
                        self.performSegue(withIdentifier: "setupWallet", sender: nil)
                    }
                    else {
                        
                        self.performSegue(withIdentifier: "main", sender: nil)
                    }
                    
                }
            })
        }
        else {
            
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            activity.stopAnimating()
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func forgetPasswordAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Forget Password", message: "Please Enter Your Email", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "Email Address"
            textfield.keyboardType = .emailAddress
        })
        let Save = UIAlertAction(title: "Reset Password", style: .destructive, handler: { (action) in
            let emailAddress = alert.textFields![0]
            var error = ""
            if emailAddress.text == "" || !isValidEmail(testStr: emailAddress.text!) {
                error = "Please provide valid email address"
            }
            if error == "" {
                Authentication.sharedInstance().sendPasswordResetEmail(email: emailAddress.text!, callback: { (success) in
                    
                    if success {
                        showAlertWithOkayBtn(title: "Success", desc: "Reset password email was successfully sent to your email")
                    }
                    
                })
            }
            else {
                let alert2 = UIAlertController(title: "", message: error, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler : { (action) in
                    self.present(alert, animated: true, completion: nil)
                })
                alert2.addAction(okAction)
                self.present(alert2, animated: true, completion: nil)
            }
        })
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(Save)
        alert.addAction(Cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        backBtn.isHidden = true
        
        if !isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height/2
                isKeyboardOpen = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        backBtn.isHidden = false
        
        if isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += keyboardSize.height/2
                isKeyboardOpen = false
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

}

