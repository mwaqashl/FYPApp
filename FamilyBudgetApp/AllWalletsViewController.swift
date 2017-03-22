//
//  AllWalletsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AllWalletsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var array = ["Waqas","Huzaifa","Zeeshan"]
    //var wallets = [String:UserWallet]()
    
    @IBOutlet weak var UserName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //wallets = Resource.sharedInstance().userWallets
        UserName.text = Auth.sharedInstance().authUser?.userName
        //WalletObserver.sharedInstance().startObserving()
        
        //print(wallets)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let wallets = collectionView.dequeueReusableCell(withReuseIdentifier: "wallets", for: indexPath) as? WalletsCollectionViewCell
        wallets?.OwnwrName.text = array[indexPath.item]
        return wallets!
    }
    
//    func walletAdded(_ wallet: UserWallet) {
//        print(wallet.id)
//    }
//    
//    func walletUpdated(_ wallet: UserWallet) {
//        
//    }
//    func WalletDeleted(_ wallet: UserWallet) {
//        
//    }
//    
//    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
//        
//    }
//    
//    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
//        
//    }
//    
//    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
//        
//    }
//    
    @IBAction func CloseWalletButton(_ sender: Any) {
    }
    
    @IBAction func SignoutButton(_ sender: Any) {
        let error = Auth.sharedInstance().logOutUser()
        if error != nil {
            let alert = UIAlertController(title: error?.localizedDescription, message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            
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
