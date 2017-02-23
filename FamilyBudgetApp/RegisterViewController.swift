//
//  RegisterViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        
        let user = CurrentUser(id: "asd", email: email.text!, userName: userName.text!, imageURL: "asd", birthdate: Date().timeIntervalSince1970*1000, deviceID: nil, gender: 1)
        
        Auth.sharedInstance().createUser(email: email.text!, password: password.text!, user: user) { (err) in
            
            if err != nil {
                
                print(err?.localizedDescription)
                
            }
            else {
                
                self.performSegue(withIdentifier: "home", sender: nil)
                
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
