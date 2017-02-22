//
//  ViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 17/02/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var lab3: UILabel!
    @IBOutlet weak var lab1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func signupAction(_ sender: Any) {
        
        
        let user = CurrentUser(id: "asd", email: "whlakhani@gmail.com", userName: "Waqas Hussain", imageURL: "Asd", birthdate: nil, deviceID: nil, gender: 1)
        Auth.sharedInstance().createUser(email: "whlakhani@gmail.com", password: "imwaqas", user: user) { (success) in
            
            if success {
                
                self.lab1.text = Auth.sharedInstance().authUser?.userName
                self.lab2.text = Auth.sharedInstance().authUser?.getUserID()
                self.lab3.text = Auth.sharedInstance().authUser?.gender == 0 ? "Female":"Male"
                
                
            }
        }
        
    }
    

}

