//
//  ViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 17/02/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        password.isSecureTextEntry = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func signInBtnAction(_ sender: Any) {
        
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
            
            Auth.sharedInstance().signIn(email: emailAddress.text!, password: password.text!, callback: { (user) in
                
                if user != nil {
                    
                    self.performSegue(withIdentifier: "home", sender: nil)
                    
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
    
    
    
    
    
    
//    @IBAction func signupAction(_ sender: Any) {
//        
//        
//        let user = CurrentUser(id: "asd", email: "whlakhani@gmail.com", userName: "Waqas Hussain", imageURL: "Asd", birthdate: Date().timeIntervalSince1970*1000, deviceID: nil, gender: 1)
//        Auth.sharedInstance().createUser(email: "whlakhani@gmail.com", password: "imwaqas", user: user) { (success) in
//            
//            if success {
//                
//                self.lab1.text = Auth.sharedInstance().authUser?.userName
//                self.lab2.text = Auth.sharedInstance().authUser?.getUserID()
//                self.lab3.text = Auth.sharedInstance().authUser?.gender == 0 ? "Female":"Male"
//                
//                
////            }
////        }
////        
//        
//        Auth.sharedInstance().signIn(email: "whlakhani@gmail.com", password: "imwaqas") { (user) in
//            
//            if user != nil {
//                
////                self.lab1.text = "Login Success"
////                self.lab2.text = Auth.sharedInstance().authUser?.userName
////                self.lab3.text = Auth.sharedInstance().authUser?.gender == 0 ? "Female":"Male"
//                
//            }
//            
//        }
//        
//        
//        
//    }
    

}

