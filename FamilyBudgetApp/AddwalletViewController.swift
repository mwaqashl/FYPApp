//
//  AddwalletViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/25/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddwalletViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var walletName: UITextField!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var balance: UITextField!
    @IBOutlet weak var editIconBtn: UIButton!
    @IBOutlet weak var currencyName: UITextField!
    @IBOutlet weak var currencyCode: UITextField!
    @IBOutlet weak var currencyIcon: UILabel!
    @IBOutlet var walletIcons: [UILabel]!
    @IBOutlet weak var membersCollectionView: UICollectionView!
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var doneBtn: UIButton!
    
    var searchedUsers : [User] = []
    var selectedindex = 0
    var currencypicker = UIPickerView()
    var wallet : UserWallet?
    var backView = UIView()
    var selectedIcon = ""
    var selectedColor : UIColor = .brown
    var pSelectedIcon = ""
    var pSelectedColor : UIColor = .brown
    var colors : [UIColor] = [.blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown]
    
    var walletMembers = [String:MemberType]()
    var members = [User]()
    var label = UILabel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Delegate.sharedInstance().addWalletDelegate(self)
        searchBar.autocapitalizationType = .none
        currencypicker.dataSource = self
        currencypicker.delegate = self
        currencyName.inputView = currencypicker
        currencyCode.inputView = currencypicker
        searchBar.delegate = self
        currencypicker.backgroundColor = .white
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        popoverView.isHidden = true
        popoverView.layer.cornerRadius = 10
        popoverView.layer.shadowColor = UIColor.gray.cgColor
        popoverView.layer.shadowRadius = 2
        searchView.isHidden = true
        
        doneBtn.layer.borderColor = UIColor(red: 26/255, green: 52/255, blue: 109/255, alpha: 1).cgColor
        doneBtn.layer.borderWidth = 1
        
        selectedIcon = "\u{A037}"
        for icon in walletIcons {
            icon.textColor = selectedColor
            icon.text = selectedIcon
        }
        walletName.textColor = selectedColor
        
        
        wallet = UserWallet(id: "new", name: "", icon: "", currencyID: "", creatorID: Resource.sharedInstance().currentUserId!, balance: 0, totInc: 0, totExp: 0, creationDate: Date().timeIntervalSince1970, isPersonal: false, memberTypes: [Resource.sharedInstance().currentUserId! : .owner], isOpen: true, color: UIColor.blue.stringRepresentation)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        currencyName.inputAccessoryView = toolbar
        currencyCode.inputAccessoryView = toolbar

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddwalletBtn(_ sender: Any) {
        
        var error = ""
        var errorDis = ""
        
        wallet?.balance = Double(balance.text!) ?? 0
        wallet?.totalIncome = wallet!.balance
        wallet?.icon = walletIcons.first!.text!
        wallet?.color = walletIcons.first!.textColor
        wallet?.name = walletName.text!

        if wallet!.name.characters.count < 6 {
            error = "Error"
            errorDis = "Wallet Name"
        }
        if wallet!.currencyID == "" {
            error = "Currency Error"
            errorDis = "Select any default currency for your wallet."
        }
        if error == "" {
            self.wallet!.id = WalletManager.sharedInstance().addWallet(wallet!)
        }
        else {
            
            let alert = UIAlertController(title: error , message: errorDis, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
            })
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func showPopUp() {
        
        self.view.addSubview(backView)
        
        backView.alpha = 0
        popoverView.isHidden = false
        self.view.bringSubview(toFront: popoverView)
        popoverView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {() -> Void in
            self.popoverView.transform = CGAffineTransform.identity
            self.backView.alpha = 1
        },completion: { _ in })
        
    }
    
    func hidePopUp() {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {() -> Void in
            self.popoverView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.backView.alpha = 0
        },completion: { _ in
            
            self.popoverView.isHidden = true
            self.backView.removeFromSuperview()
            
        })
        
    }
    
    func showSearchView() {
        self.view.addSubview(backView)
        
        backView.alpha = 0
        searchView.frame.origin.y += searchView.frame.height
        searchView.isHidden = false
        self.view.bringSubview(toFront: searchView)
        
        walletMembers = wallet!.memberTypes
        members = wallet!.members
        if searchTable.delegate == nil {
            searchTable.delegate = self
            searchTable.dataSource = self
        }
        else {
            searchTable.reloadData()
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.searchView.frame.origin.y -= self.searchView.frame.height
            self.backView.alpha = 1
        }
        
    }
    
    func hideSearchView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchView.frame.origin.y += self.searchView.frame.height
        }) { (flag) in
            
            if flag {
                self.searchView.isHidden = true
                self.backView.alpha = 0
                self.backView.removeFromSuperview()
            }
        }
        
    }
    
    func donepressed(){
        
        let all = Array(Resource.sharedInstance().currencies.keys)
        let this = all[selectedindex]
        
        wallet?.currencyID = this
        currencyIcon.text = wallet!.currency.icon
        currencyCode.text = wallet!.currency.code
        currencyName.text = wallet!.currency.name
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        if wallet!.currencyID != "" {
            currencyIcon.text = wallet!.currency.icon
            currencyCode.text = wallet!.currency.code
            currencyName.text = wallet!.currency.name
        }
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print(Resource.sharedInstance().currencies.count)
        return Resource.sharedInstance().currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        let all = Array(Resource.sharedInstance().currencies.keys)
        let this = all[row]
        
        let attString = NSAttributedString(string: Resource.sharedInstance().currencies[this]!.icon, attributes: [NSFontAttributeName : UIFont(name: "untitled-font-25", size: 17)!])
        
        let attString2 = NSAttributedString(string: " - \(Resource.sharedInstance().currencies[this]!.name) - \(Resource.sharedInstance().currencies[this]!.code)", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
        
        let str = NSMutableAttributedString()
        str.append(attString)
        str.append(attString2)
        
        pickerLabel.attributedText = str
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedindex = row
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            hidePopUp()
            
            for icon in walletIcons {
                icon.textColor = selectedColor
                icon.text = selectedIcon
            }
            walletName.textColor = selectedColor
        }
        else if sender.tag == 1 {
            
            hideSearchView()
            
            wallet?.memberTypes = walletMembers
            
            if membersCollectionView.delegate == nil {
                membersCollectionView.delegate = self
                membersCollectionView.dataSource = self
            }
            else {
                membersCollectionView.reloadData()
            }
            
            if walletMembers.count > 0 {
                membersCollectionView.backgroundView = nil
            }
            else {
                membersCollectionView.backgroundView = label
            }
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            hidePopUp()
            
            for icon in walletIcons {
                icon.textColor = pSelectedColor
                icon.text = pSelectedIcon
            }
            walletName.textColor = pSelectedColor
        }
        else if sender.tag == 1 {
            
            hideSearchView()
            
            
        }
    }
    
    @IBAction func addMemberBtnAction(_ sender: Any) {
        
        showSearchView()
        
    }
    
    @IBAction func changeIconAction(_ sender: Any) {
        
        showPopUp()
        
        pSelectedColor = selectedColor
        pSelectedIcon = selectedIcon
    }
    
    
    // CollectionView Delegate and Datasources
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView.tag == 1 {
            
            let index = selectedIcon.unicodeScalars.first!.value - 41011
            
            let prev = collectionView.cellForItem(at: IndexPath.init(item: Int(index), section: 0)) as! DefaultCollectionViewCell
            
            prev.layer.borderColor = UIColor.lightGray.cgColor
            prev.icon.textColor = UIColor.lightGray
            
            let cell = collectionView.cellForItem(at: indexPath) as! DefaultCollectionViewCell
            //            pSelectedIcon = selectedIcon
            selectedIcon = "\(UnicodeScalar(indexPath.item + 41011)!)"
            cell.layer.borderColor = selectedColor.cgColor
            cell.icon.textColor = selectedColor
            
            
            
        }
        else if collectionView.tag == 2 {
            
            let index = selectedIcon.unicodeScalars.first!.value - 41011
            
            let prev = collectionView.cellForItem(at: IndexPath.init(item: colors.index(of: selectedColor)!, section: 0))
            
            prev?.layer.borderColor = UIColor.white.cgColor
            //            pSelectedColor = selectedColor
            selectedColor = colors[indexPath.item]
            
            let new = collectionView.cellForItem(at: indexPath)
            new?.layer.borderColor = selectedColor.cgColor
            
            let iconCell = iconsCollectionView.cellForItem(at: IndexPath.init(item: Int(index), section: 0)) as! DefaultCollectionViewCell
            
            iconCell.layer.borderColor = selectedColor.cgColor
            iconCell.icon.textColor = selectedColor
            
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 100 {
            return wallet?.memberTypes.count ?? 0
        }
        
        return collectionView.tag == 1 ? 29 : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "icon", for: indexPath) as! DefaultCollectionViewCell
            
            cell.icon.text = "\(UnicodeScalar(indexPath.item + 41011)!)"
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = cell.frame.width/2
            
            if "\(UnicodeScalar(indexPath.item + 41011)!)" == selectedIcon {
                cell.layer.borderColor = selectedColor.cgColor
                cell.icon.textColor = selectedColor
            }
            else {
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.icon.textColor = UIColor.lightGray
            }
            
            return cell
        }
        else if collectionView.tag == 2 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath)
            
            cell.layer.cornerRadius = 12
            cell.backgroundColor = colors[indexPath.item]
            
            if cell.backgroundColor == selectedColor {
                
                cell.layer.borderColor = selectedColor.cgColor
                cell.layer.borderWidth = 1
                
            }
            else {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.white.cgColor
            }
            
            return cell
        }
        else if collectionView.tag == 100 {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "members", for: indexPath) as! MembersCollectionViewCell
            
            let this = wallet?.members[indexPath.item]
            
            this?.getImage({ (data) in
                cell.memberImage.image = UIImage(data: data) ?? (this!.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
            })
            
            cell.memberName.text = this?.userName.components(separatedBy: " ").first
            cell.memberType.text = wallet?.memberTypes[this!.getUserID()] == .owner ? "Owner" : (wallet?.memberTypes[this!.getUserID()] == .admin ? "Admin" : "Member")
            cell.memberType.layer.cornerRadius = cell.memberType.frame.height/2
            cell.memberType.clipsToBounds = true
            cell.memberImage.layer.cornerRadius = cell.memberImage.frame.height/2
            cell.memberImage.clipsToBounds = true
            
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 100 {
            return CGSize(width: 50, height: 70)
        }
        
        return collectionView.tag == 1 ? CGSize(width: 50, height: 50) : CGSize(width: 24, height: 24)
    }


    // TableView Delegate and Data Sources
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? searchedUsers.count == 0 ? "No users to show." : "" : nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel(frame: view.frame)
            label.text = searchedUsers.count == 0 ? "No users to show." : ""
            label.textAlignment = .center
            view.addSubview(label)
            
            return view
        }
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Search Results" : "Wallet Members"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            walletMembers[searchedUsers[indexPath.row].getUserID()] = .member
            members.append(searchedUsers[indexPath.row])
            searchedUsers.remove(at: indexPath.row)
            tableView.reloadSections([0,1], with: .top)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? searchedUsers.count : walletMembers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if searchedUsers.count != 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                cell.selectionStyle = .none
                let this = searchedUsers[indexPath.row]
                
                this.getImage({ (data) in
                    cell.userImage.image = UIImage(data: data) ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                })
                cell.accessoryType = .none
                cell.userName.text = this.userName
                cell.userEmail.text = this.getUserEmail()
                
                cell.memberTypeBtn.isHidden = true
                
                return cell
                
            }
            
            
        }
        else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
            cell.selectionStyle = .none
            let this = members[indexPath.row]
            
            this.getImage({ (data) in
                cell.userImage.image = UIImage(data: data) ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
            })
            cell.memberTypeBtn.isEnabled = true
            if walletMembers[this.getUserID()] == .owner {
                cell.accessoryType = .none
                cell.memberTypeBtn.setTitle("Owner", for: UIControlState.normal)
                cell.memberTypeBtn.isEnabled = false
            }
            else if walletMembers[this.getUserID()] == .admin {
                cell.accessoryType = .checkmark
                cell.memberTypeBtn.setTitle("Remove from Admin", for: UIControlState.normal)
            }
            else {
                cell.accessoryType = .checkmark
                cell.memberTypeBtn.setTitle("Make Admin", for: UIControlState.normal)
            }
            
            cell.userName.text = this.userName
            cell.userEmail.text = this.getUserEmail()
            cell.memberTypeBtn.isHidden = false
            cell.memberTypeBtn.addTarget(self, action: #selector(self.memberTypeChanged), for: .touchUpInside)
            cell.memberTypeBtn.tag = indexPath.row
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func memberTypeChanged(sender: UIButton) {
        
        print("member type changed")
        let thisUser = members[sender.tag]
        
        if sender.currentTitle == "Make Admin" {
            
            walletMembers[thisUser.getUserID()] = .admin
            sender.setTitle("Remove from Admin", for: .normal)
        }
        else if sender.currentTitle == "Remove from Admin" {
            
            walletMembers[thisUser.getUserID()] = .member
            sender.setTitle("Make Admin", for: .normal)
        }
        
        
    }
    
    /// Search Bar delegate Functions 
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedUsers = []
        
        let results = Resource.sharedInstance().users.filter { (user) -> Bool in
            
            return user.value.getUserEmail().contains(searchText) && !(walletMembers.contains(where: { (_user) -> Bool in
                return _user.key == user.key
            }))
            
        }
        var indexes = [IndexPath]()
        print("search results = ", results.count)
        for i in 0..<results.count {
            searchedUsers.append(results[i].value)
        }
        searchTable.reloadSections([0], with: .left)
    }

}

extension AddwalletViewController: WalletDelegate {
    
    func walletAdded(_ wallet: UserWallet) {
        if wallet.id == self.wallet!.id {
            
            let alert = UIAlertController(title: "Success", message: "Wallet Successfully created", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(ok)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        
    }
    
    
}

