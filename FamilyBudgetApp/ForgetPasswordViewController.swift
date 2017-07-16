//
//  ForgetPasswordViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas on 15/07/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController {

    @IBOutlet var codeTextFields: [UITextField]!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var verifyCodeView: UIView!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet var viewsForShadow: [UIView]!

    var tap = UITapGestureRecognizer()
    var isKeyboardOpen = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi) + CGFloat(Double.pi/2))
        nextBtn.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        
        for view in viewsForShadow {
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowOpacity = 0.6
            view.layer.shadowRadius = 2
            view.layer.shadowColor = darkThemeColor.cgColor
        }
        
        self.codeTextFields.sort { (t1, t2) -> Bool in
            return t1.tag < t2.tag
        }
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func viewTapped() {
        self.view.endEditing(true)
    }
    
    @IBAction func getCodeAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Request Code", message: "Please Enter Your Email", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "Email Address"
        })
        let Save = UIAlertAction(title: "Get Code", style: .destructive, handler: { (action) in
            let emailAddress = alert.textFields![0]
            var error = ""
            if emailAddress.text == "" || !isValidEmail(testStr: emailAddress.text!) {
                error = "Please provide valid email address"
            }
            if error == "" {
                Authentication.sharedInstance().sendPasswordResetEmail(email: emailAddress.text!, callback: { (success) in
                    
                    if success {
                        showAlertWithOkayBtn(title: "Success", desc: "Verification Code sent to your email successfuly")
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
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        self.view.endEditing(true)

        var code = ""
        
        for codes in codeTextFields {
            code += codes.text!
        }
        
        if code.lengthOfBytes(using: String.Encoding.utf8) == 6 {
            
            if password.text! == repassword.text! {
                Authentication.sharedInstance().resetPasswordofEmail(withVerificationCode: code, newPassword: password.text!, withcallback: { (success) in
                    
                    if success {
                        
                        Authentication.sharedInstance().signInSiliently(callback: { (flag, newUser) in
                            
                            if success {
                                if newUser {
                                    let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "walletsetup")
                                    
                                    self.present(cont, animated: true, completion: nil)
                                }
                                else {
                                    
                                    let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "main")
                                    
                                    self.present(cont, animated: true, completion: nil)
                                }
                            }
                            else {
                                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
            else {
                showAlertWithOkayBtn(title: "Error", desc: "Password did not match.")
            }
        }
        else {
            showAlertWithOkayBtn(title: "Error", desc: "Please provide verification code.")
        }

    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpen {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height/2
                isKeyboardOpen = true
            }
        }
        
    }
    @IBAction func codeChanged(_ sender: UITextField) {
        if sender.tag < 5 {
            print(sender.tag)
            codeTextFields[sender.tag+1].becomeFirstResponder()
        }
        else if sender.tag == 5 {
            sender.resignFirstResponder()
        }
    }
    func keyboardWillHide(notification: NSNotification) {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
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

