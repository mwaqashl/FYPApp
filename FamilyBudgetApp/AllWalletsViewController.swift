//
//  AllWalletsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AllWalletsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, WalletDelegate, WalletMemberDelegate, UserDelegate, TransactionDelegate, TaskDelegate {

    //var array = ["Waqas","Huzaifa","Zeeshan"]
    var transactioncount = 0 , taskcount = 0
    var walletkey = [String]()
    var userwallets = [String:UserWallet]()
   // @IBOutlet weak var pagecontroller: UIPageControl!
    
    @IBOutlet weak var colltectionview: UICollectionView!
    @IBOutlet weak var UserName: UILabel!

    var activity = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userwallets = Resource.sharedInstance().userWallets
        //print(wallets)
        UserName.text = Auth.sharedInstance().authUser?.userName
        WalletObserver.sharedInstance().startObserving()
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addUserDelegate(self)
        Delegate.sharedInstance().addTransactionDelegate(self)
        Delegate.sharedInstance().addTaskDelegate(self)
        
        self.navigationController!.isToolbarHidden = true
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                self.activity.stopAnimating()
            }
            
        }
        
        if walletkey.count == 0 {
            activity = UIActivityIndicatorView(frame: self.view.frame)
            activity.hidesWhenStopped = true
            activity.startAnimating()
            activity.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.addSubview(activity)
        }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "timeline", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if walletkey.count > 0 {
//            activity.stopAnimating()
//            return walletkey.count
//        }
//        else {
            return walletkey.count
        //}
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let walletCell = collectionView.dequeueReusableCell(withReuseIdentifier: "wallets", for: indexPath) as? WalletsCollectionViewCell
        let wallet = userwallets[walletkey[indexPath.item]]
        walletCell?.OwnwrName.text = wallet!.creator.userName
        walletCell?.BalanceAmount.text = "\(wallet!.balance)"//String(describing: wallet?.balance)
        walletCell?.ExpenseTotal.text = "\(wallet!.totalExpense)"
        walletCell?.IncomeTotal.text = "\(wallet!.totalIncome)"
        walletCell?.WalletName.text = wallet!.name
        
        return walletCell!
    }
    
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
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        //print(wallet.id)
        //print(wallet.name)
        walletkey.append(wallet.id)
        userwallets[wallet.id] = wallet
        //print(userwallets[walletkey.first!]?.balance)
        //print(userwallets[wallet.id])
        //print(Resource.sharedInstance().userWallets)
        colltectionview.reloadData()
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        userwallets[wallet.id] = wallet
        colltectionview.reloadData()
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if userwallets[wallet.id] != nil {
            userwallets.removeValue(forKey: wallet.id)
            //walletkey[walletkey.index(of: wallet.id)!] = ""
            walletkey.remove(at: walletkey.index(of: wallet.id)!)
            colltectionview.reloadData()
        }
    }
    
    //member Delegate
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        colltectionview.reloadData()
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        colltectionview.reloadData()
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        colltectionview.reloadData()
    }
    
    // User Delegates
    
    func userAdded(_ user: User) {
        //print(user.)
        colltectionview.reloadData()
    }
    func userUpdated(_ user: User) {
        colltectionview.reloadData()
    }
    
    func userDetailsAdded(_ user: CurrentUser) {
        colltectionview.reloadData()
    }
    
    func userDetailsUpdated(_ user: CurrentUser) {
        colltectionview.reloadData()
    }
    
    //transaction Delegates
    
    func transactionAdded(_ transaction : Transaction) {
        
    }
    func transactionUpdated(_ transaction :  Transaction) {
        
    }
    func transactionDeleted(_ transaction :  Transaction) {
        
    }
    
    //task Delegates
    
    func taskAdded(_ task: Task) {
        
    }
    func taskUpdated(_ task: Task) {
        
    }
    func taskDeleted(_ task: Task) {
        
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
