//
//  HomeViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if Auth.sharedInstance().isAuthenticated {
            
            let user = Auth.sharedInstance().authUser
            
            label1.text = "Login Success"
            label2.text = "Welcome \(user!.userName)"
            
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func signoutAction(_ sender: Any) {
        
        
        guard let error = Auth.sharedInstance().logOutUser() else {
            
            let cont = self.storyboard?.instantiateViewController(withIdentifier: "login") as! ViewController
            
            self.present(cont, animated: true, completion: nil)
            self.navigationController?.viewControllers.removeAll()
            
            return
        }
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func addDataAction(_ sender: Any) {
        
        
        let wallet = UserWallet(id: "asd", name: "Waqas's Wallet", icon: "a", currencyID: "asd", creatorID: Auth.sharedInstance().authUser!.getUserID(), balance: 10000, totInc: 0, totExp: 0, creationDate: Date().timeIntervalSince1970*1000, isPersonal: true, memberTypes: [Auth.sharedInstance().authUser!.getUserID() : MemberType.owner], isOpen: true, color: "10:188:228:1")
        
        WalletManager.sharedInstance().addWallet(wallet)
        
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
