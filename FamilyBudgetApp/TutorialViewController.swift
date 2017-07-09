//
//  TutorialViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 30/03/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

var themeColorDark = UIColor(red: 98/255, green: 141/255, blue: 84/255, alpha: 1)


class TutorialViewController: UIViewController {
    
    @IBOutlet weak var alreadyUserBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        @IBAction func loginBtnAction(_ sender: Any) {
        
        let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "login") as! ViewController
        
        self.present(cont, animated: true, completion: nil)
    }
    
    
    @IBAction func newUserBtnAction(_ sender: Any) {
        
        
        let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "register") as! RegisterViewController
        
        self.present(cont, animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        alreadyUserBtn.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
//        registerBtn.layer.borderColor = themeColorDark.cgColor
//        registerBtn.layer.borderWidth = 1
//        registerBtn.layer.shadowRadius = 2
//        registerBtn.layer.shadowOpacity = 0.5
//        registerBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
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
