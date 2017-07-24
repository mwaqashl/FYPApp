//  SettingsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 6/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
import ALCameraViewController

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UserDelegate, WalletDelegate, WalletMemberDelegate {
    
    @IBOutlet weak var SearchMemberViewTitle: UILabel!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var SearchMemberView: UIView!
    @IBOutlet weak var SettingsTableView: UITableView!
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    var backView = UIView()
    var searchedUsers = [User]()
    var walletMembers : [User] {
        
        var users :[User] = []
        
        for member in memberTypes {
            users.append(Resource.sharedInstance().users[member.key]!)
        }
        
        return users
    }
    var memberTypes = [String:MemberType]()
    var selectedWallet : UserWallet?
    var selectedIcon = ""
    var selectedColor : UIColor = darkThemeColor
    var pSelectedIcon = ""
    var pSelectedColor : UIColor = .brown
    var colors : [UIColor] = [darkThemeColor, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown]
    
    var isKeyboardOpen = false
    var isUserSearch = false
    var tap = UITapGestureRecognizer()
    
    var sections = ["Wallet","Wallet Settings","Members","leaveBtn"]
    var settingsSetionCells = ["Add Member","Assign Admin","Transfer OwnerShip","Close Wallet"]
    
    var searchtableSection = [String]()
    
    var userSettingsOptions = ["Change Password","Edit Name", "Edit Display Picture"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popoverView.isHidden = true
        backView = UIView(frame: self.view.frame)
        backView.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        backView.addGestureRecognizer(tap)
        backView.backgroundColor = .lightGray
        backView.alpha = 0.5
        backView.isUserInteractionEnabled = true
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        SettingsTableView.dataSource = self
        SettingsTableView.delegate = self
        
        iconsCollectionView.dataSource = self
        iconsCollectionView.delegate = self
        
        colorsCollectionView.dataSource = self
        colorsCollectionView.delegate = self
        
        SearchMemberView.isHidden = true
        SearchMemberView.frame.origin.y += self.SearchMemberView.frame.height
        searchBar.autocapitalizationType = .none

        selectedColor = Resource.sharedInstance().currentWallet!.color
        selectedIcon = Resource.sharedInstance().currentWallet!.icon
        
        searchBar.delegate = self
        Delegate.sharedInstance().addUserDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                if Resource.sharedInstance().currentUserId == Resource.sharedInstance().currentWalletID {
                    self.sections = ["Wallet","Wallet Settings","User","User Settings","SignOut"]
                    self.settingsSetionCells = ["Change Wallet Name", "Change Wallet Icon"]
                }
                else {
                    self.sections = ["Wallet","Wallet Settings", "Members"]
                    
                    let thisWallet = Resource.sharedInstance().currentWallet!
                    self.selectedWallet = UserWallet(id: thisWallet.id, name: thisWallet.name, icon: thisWallet.icon, currencyID: thisWallet.currencyID, creatorID: thisWallet.creatorID, balance: thisWallet.balance, totInc: thisWallet.totalIncome, totExp: thisWallet.totalExpense, creationDate: thisWallet.creationDate.timeIntervalSince1970, isPersonal: thisWallet.isPersonal, memberTypes: thisWallet.memberTypes, isOpen: thisWallet.isOpen, color: thisWallet.color.stringRepresentation)
                    
                    self.memberTypes = self.selectedWallet!.memberTypes

                    if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
                        self.settingsSetionCells = ["Add Member","Change Wallet Name", "Change Wallet Icon"]
                        self.sections.append("leaveBtn")
                    }
                    else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
                        self.sections.remove(at: 1)
                        self.sections.append("leaveBtn")
                    }
                    else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
                        self.settingsSetionCells += ["Change Wallet Name", "Change Wallet Icon", "Delete Wallet"]
                    }
                    self.sections += ["User","User Settings","SignOut"]
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func ViewTap() {
        self.view.endEditing(true)
    }
    
    func updateSettingCells(){
        
         sections = ["Wallet","Wallet Settings","Members","leaveBtn"]
         settingsSetionCells = ["Add Member","Assign Admin","Transfer OwnerShip","Notification","Close Wallet"]
        
        if Resource.sharedInstance().currentUserId == Resource.sharedInstance().currentWalletID {
            self.sections = ["Wallet","Wallet Settings","User","User Settings","SignOut"]
            self.settingsSetionCells = ["Change Wallet Name", "Change Wallet Icon"]
        }
        else {
            self.sections = ["Wallet","Wallet Settings", "Members"]
            self.memberTypes = self.selectedWallet!.memberTypes
            
            if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
                self.settingsSetionCells = ["Add Member","Change Name", "Change Icon"]
                self.sections.append("leaveBtn")
            }
            else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
                self.sections.remove(at: 1)
                self.sections.append("leaveBtn")
            }
            else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
                self.settingsSetionCells += ["Change Name", "Change Icon", "Delete Wallet"]
            }
            self.sections += ["User","User Settings","SignOut"]
        }
        self.SettingsTableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func BackBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SearchMemberView.frame.origin.y -= keyboardSize.height/2
                isKeyboardOpen = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
    
        if isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SearchMemberView.frame.origin.y += keyboardSize.height/2
                isKeyboardOpen = false
            }
            else {
                print("keyboard size not found")
            }
        }
        else {
            print("masla ho gya ")
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == SettingsTableView ? sections.count : searchtableSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == SettingsTableView {
            
            switch sections[indexPath.section] {
            case "Wallet":
                return 100
            case "Members":
                return 200
            case "User":
                return 100
            default:
                return 50
            }
        }
        else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == SettingsTableView {
            return sections[section] == "Wallet Settings" ? settingsSetionCells.count : sections[section] == "User Settings" ? userSettingsOptions.count : 1
        }
        else {
            return searchtableSection[section] == "searchUsers" ? searchedUsers.count : walletMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == SettingsTableView {
            
            switch sections[section] {
            case "Wallet":
                return "WALLET Settings"
            case "Members":
                return "Wallet Members"
            case "User":
                return "User Settings"
            default:
                return nil
            }
            
        }
        else {
            return searchtableSection[section] == "searchUsers" ? "Search Results" : "Wallet Members"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == SettingsTableView {
            return 30
        }
        else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == searchTableView {
            if section == 0 && SearchMemberViewTitle.text == "Add Members" {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
                let label = UILabel(frame: view.frame)
                label.text = searchedUsers.count == 0 ? "No users to show." : ""
                label.textAlignment = .center
                view.addSubview(label)
                
                return view
            }
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == SettingsTableView {
            
            switch sections[indexPath.section] {
            case "Wallet":
                let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell") as! WalletInfoCell
                cell.icon.text = Resource.sharedInstance().currentWallet!.icon
                cell.icon.textColor = Resource.sharedInstance().currentWallet!.color
                cell.settingName.text = Resource.sharedInstance().currentWallet!.name
                cell.icon.layer.cornerRadius = cell.icon.layer.frame.height/2
                cell.icon.layer.borderWidth = 1
                cell.icon.layer.borderColor = cell.icon.textColor.cgColor
                for view in cell.borderLine {
                    view.backgroundColor = cell.icon.textColor
                }
                cell.selectionStyle = .none
                return cell
                
            case "User":
                let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! UserInfoTableViewCell
                cell.userdp.image = Resource.sharedInstance().currentUser?.image ?? (Resource.sharedInstance().currentUser!.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                Resource.sharedInstance().currentUser?.imageCallback = {
                    image in
                    cell.userdp.image = image
                }
                cell.userName.text = Resource.sharedInstance().currentUser?.userName
                cell.userEmail.text = Resource.sharedInstance().currentUser?.getUserEmail()
                cell.selectionStyle = .none
                return cell
                
            case "Wallet Settings":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.settingName.text = settingsSetionCells[indexPath.row]
                if settingsSetionCells[indexPath.row] == "Close Wallet" {
                    cell.settingName.text = Resource.sharedInstance().currentWallet!.isOpen ? "Close Wallet" : "Open Wallet"
                }
                cell.selectionStyle = .none
                return cell
                
            case "User Settings":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.settingName.text = userSettingsOptions[indexPath.row]
                cell.selectionStyle = .none
                return cell
                
            case "Members":
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! SettingMembersTableViewCell
                cell.membersCollectionView.dataSource = self
                cell.membersCollectionView.delegate = self
                cell.membersCollectionView.tag = 10
                cell.membersCollectionView.reloadData()
                cell.selectionStyle = .none
                return cell
            
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveCell") as! DeleteTableViewCell
                cell.selectionStyle = .none
                
                cell.DeleteBtn.setTitle(sections[indexPath.section] == "leaveBtn" ? "Leave Wallet" : "Sign Out", for: .normal)
                
                return cell
            }
            
        }
        else {
            if searchtableSection[indexPath.section] == "searchUsers" {
                
                if searchedUsers.count != 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                    cell.selectionStyle = .none
                    let this = searchedUsers[indexPath.row]
                    
                    cell.userImage.image = this.image ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                    
                    this.imageCallback = {
                        image in
                        cell.userImage.image = image
                    }
                    cell.memberType.isHidden = true
                    cell.actionsStackView.isHidden = true
                    cell.accessoryType = .none
                    cell.userName.text = this.userName
                    cell.userEmail.text = this.getUserEmail()
                    
                    return cell
                    
                }
                
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                cell.selectionStyle = .none
                let this = walletMembers[indexPath.row]
                
                cell.userImage.image = this.image ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                
                this.imageCallback = {
                    image in
                    cell.userImage.image = image
                }
                
                cell.userName.text = this.userName
                cell.userEmail.text = this.getUserEmail()
                
                cell.actionsStackView.isHidden = false
                let type = self.memberTypes[this.getUserID()]
                
                if type == .owner {
                    cell.memberType.text = "Owner"
                    cell.actionsStackView.isHidden = true
                }
                else if type == .admin {
                    cell.memberType.text = "Admin"
                    cell.adminBtn.setImage(#imageLiteral(resourceName: "removeAdmin"), for: .normal)
                }
                else {
                    cell.memberType.text = "Member"
                    cell.adminBtn.setImage(#imageLiteral(resourceName: "makeAdmin"), for: .normal)
                }
                
                if SearchMemberViewTitle.text == "Transfer OwnerShip" {
                    cell.actionsStackView.isHidden = true
                }
                
                cell.adminBtnAction = {
                    
                    self.memberTypes[this.getUserID()] = self.memberTypes[this.getUserID()] == .admin ? .member : .admin
                    
                    cell.memberType.text = self.memberTypes[this.getUserID()] == .admin ? "Admin" : "Member"
                }
                cell.removeMemberAction = {
                    self.memberTypes[this.getUserID()] = nil
                    tableView.reloadSections([1], with: .fade)
                }
                
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableView == searchTableView {
            
            if searchtableSection[indexPath.section] == "searchUsers" {
                memberTypes[searchedUsers[indexPath.row].getUserID()] = .member
                searchedUsers.remove(at: indexPath.row)
                searchTableView.reloadSections([0,1], with: .fade)
            }
            
            if SearchMemberViewTitle.text == "Transfer OwnerShip" {
                
                let alert = UIAlertController(title: "Confirm", message: "Please confirm, you want to leave ownership of this wallet", preferredStyle: .actionSheet)
                
                let confirm = UIAlertAction(title: "Transfer Ownership", style: .destructive, handler: { (action) in
                    
                    self.memberTypes[Resource.sharedInstance().currentUserId!] = .member
                    self.memberTypes[self.walletMembers[indexPath.row].getUserID()] = .owner
                    
                    self.closeSearchView(self.doneBtn)
                    
                    self.SettingsTableView.reloadData()
                    
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(confirm)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        else {
            switch sections[indexPath.section] {
                
            case "Wallet Settings":
                
                switch settingsSetionCells[indexPath.row] {
                    
                    case "Change Wallet Icon":
                    showPopUp()
                    
                    
                case "Add Member":
                    searchtableSection = ["searchUsers","Members"]
                    isUserSearch = true
                    AddView(showView: SearchMemberView)
                    SearchMemberViewTitle.text = "Add Members"
                    
                case "Assign Admin":
                    searchtableSection = ["Members"]
                    isUserSearch = false
                    AddView(showView: SearchMemberView)
                    SearchMemberViewTitle.text = "Assign Admin"
                    
                    
                case "Transfer OwnerShip":
                    searchtableSection = ["Members"]
                    isUserSearch = false
                    AddView(showView: SearchMemberView)
                    SearchMemberViewTitle.text = "Transfer OwnerShip"
                    
                case "Close Wallet":
                    let message = selectedWallet!.isOpen ? "Do you want to close this Wallet" : "Do you want to open this Wallet"
                    let alert = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                        self.selectedWallet!.isOpen = !self.selectedWallet!.isOpen
                        WalletManager.sharedInstance().updateWallet(self.selectedWallet!)
                        for member in Resource.sharedInstance().currentWallet!.members {
                            print("Loop")
                            if member.getUserID() != Resource.sharedInstance().currentUserId {
                                guard let notifUser = Resource.sharedInstance().users[member.getUserID()] as? CurrentUser else {
                                    continue
                                }
                                if let deviceID = notifUser.deviceID {
                                    NotificationManager.sharedInstance().sendNotification(toDevicewith: deviceID, of: self.selectedWallet!.isOpen ? .walletOpen : .walletClosed, for: Resource.sharedInstance().currentWalletID!, withCallback: { (flag) in
                                        print("Notification sent", flag ? "Success" : "Failed")
                                    })
                                }
                            }
                        }
                        self.updateSettingCells()
                    })
                    let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(yes)
                    alert.addAction(no)
                    self.present(alert, animated: true, completion: nil)
                    
                case "Delete Wallet":
                    let alert = UIAlertController(title: "", message: "Do you want to delete this wallet", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                        WalletManager.sharedInstance().removeWallet(Resource.sharedInstance().currentWallet!)
                        Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                        self.dismiss(animated: true, completion: nil)
                    })
                    let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                    alert.addAction(yes)
                    alert.addAction(no)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                case "Change Wallet Name":
                    let alert = UIAlertController(title: "Edit Name", message: "Please Enter New Wallet Name", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "Wallet Name"
                    })
                    let Save = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                        let walletName = alert.textFields![0]
                        var error = ""
                        if walletName.text == "" {
                            error = "Wallet Name cannot be empty"
                        }
                        if error == "" {
                            let wallet = Resource.sharedInstance().currentWallet!
                            let update = UserWallet(id: wallet.id, name: walletName.text!, icon: wallet.icon, currencyID: wallet.currencyID, creatorID: wallet.creatorID, balance: wallet.balance, totInc: wallet.totalIncome, totExp: wallet.totalExpense, creationDate: wallet.creationDate.timeIntervalSince1970, isPersonal: wallet.isPersonal, memberTypes: wallet.memberTypes, isOpen: wallet.isOpen, color: wallet.color.stringRepresentation)
                            
                            WalletManager.sharedInstance().updateWallet(update)
                            
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
                    
                default:
                    print(settingsSetionCells[indexPath.section])
                }
                
                
            case "SignOut":
                Authentication.sharedInstance().logOutUser(callback: { (err) in
                    if err == nil {
                        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                })
                
            case "leaveBtn":
                let alert = UIAlertController(title: "Confirm", message: "Do you want to leave this wallet", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    WalletManager.sharedInstance().removeMemberFromWallet(self.selectedWallet!.id, memberID: Resource.sharedInstance().currentUserId!)
                    Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                    self.dismiss(animated: true, completion: nil)
                })
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
                
                
            case "User Settings":

                switch userSettingsOptions[indexPath.row] {
                case "Change Password":
                    self.performSegue(withIdentifier: "changePassword", sender: nil)
                    
                case "Edit Name":
                    let alert = UIAlertController(title: "Edit Name", message: "Please Enter Your Name", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "Enter User Name"
                    })
                    let Save = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                        let userName = alert.textFields![0]
                        var error = ""
                        if userName.text == "" {
                            error = "User Name cannot be empty"
                        }
                        if error == "" {
                            let user = Resource.sharedInstance().currentUser!
                            let update = User(id: user.getUserID(), email: user.getUserEmail(), userName: userName.text!, imageURL: user.imageURL, gender: user.gender)
                            UserManager.sharedInstance().updateUserState(update)
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
                    
                case "Edit Display Picture" :
                    let croppingEnabled = true
                    let cameraViewController = CameraViewController(croppingEnabled: croppingEnabled) { [weak self] image, asset in
                        
                        if image != nil {
                            
                            Resource.sharedInstance().currentUser!.uploadImage(image: image!, with: { (success) in
                                
                                print(success ? "Success" : "Failed")
                                
                            })
                            
                        }
                        
                        self?.dismiss(animated: true, completion: nil)
                    }
                    
                    present(cameraViewController, animated: true, completion: nil)
                    
                default:
                    print(userSettingsOptions[indexPath.section])
                }
                
                
            default:
                break
                
                
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 1 {
            return 29
        }
        else if collectionView.tag == 2 {
            return colors.count
        }
        
        return SearchMemberViewTitle.text! == "Transfer OwnerShip" ? Resource.sharedInstance().currentWallet!.members.count-1 : Resource.sharedInstance().currentWallet!.members.count
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "members", for: indexPath) as! MembersCollectionViewCell
        
        var members : [String] = []
        
        if SearchMemberViewTitle.text! == "Transfer OwnerShip" {
            members = (Resource.sharedInstance().currentWallet?.memberTypes.filter({ (member) -> Bool in
                return member.value != .owner
            }).map({ (member) -> String in
                member.key
            }))!
        }
        else {
            members = Array(Resource.sharedInstance().currentWallet!.memberTypes.keys)
        }
        
        let member = Resource.sharedInstance().users[members[indexPath.item]]!
        cell.memberImage.image = member.image ?? (member.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
        member.imageCallback = {
            image in
            cell.memberImage.image = image
        }
        cell.memberName.text = member.userName
        cell.memberType.layer.cornerRadius = cell.memberType.layer.frame.height/2
        if Resource.sharedInstance().currentWallet!.memberTypes[member.getUserID()] == .admin {
            cell.memberType.isHidden = false
            cell.memberType.text = "Admin"
            cell.memberType.backgroundColor = darkThemeColor
        }
        else if Resource.sharedInstance().currentWallet!.memberTypes[member.getUserID()] == .owner{
            cell.memberType.isHidden = false
            cell.memberType.text = "Owner"
            cell.memberType.backgroundColor = .black
        }
        else {
            cell.memberType.isHidden = true
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 10 {
            return CGSize(width: 50, height: 70)
        }
        else {
            return collectionView.tag == 1 ? CGSize(width: Int(collectionView.frame.height/2)-20, height: Int(collectionView.frame.height/2)-20) : CGSize(width: 24, height: 24)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView.tag == 1 {
            
            let index = selectedIcon.unicodeScalars.first!.value - 41011
            
            if let prev = collectionView.cellForItem(at: IndexPath.init(item: Int(index), section: 0)) as? DefaultCollectionViewCell {
                
                prev.layer.borderColor = UIColor.lightGray.cgColor
                prev.icon.textColor = UIColor.lightGray
            }
            
            
            let cell = collectionView.cellForItem(at: indexPath) as! DefaultCollectionViewCell
            //            pSelectedIcon = selectedIcon
            selectedIcon = "\(UnicodeScalar(indexPath.item + 41011)!)"
            cell.layer.borderColor = selectedColor.cgColor
            cell.icon.textColor = selectedColor
            
            
            
        }
        else if collectionView.tag == 2 {
            
            let index = selectedIcon.unicodeScalars.first!.value - 41011
            
            if let prev = collectionView.cellForItem(at: IndexPath.init(item: colors.index(of: selectedColor)!, section: 0)) {
                prev.layer.borderColor = UIColor.white.cgColor
                //            pSelectedColor = selectedColor
                selectedColor = colors[indexPath.item]
            }
            
            let new = collectionView.cellForItem(at: indexPath)
            new?.layer.borderColor = selectedColor.cgColor
            
            let iconCell = iconsCollectionView.cellForItem(at: IndexPath.init(item: Int(index), section: 0)) as! DefaultCollectionViewCell
            
            iconCell.layer.borderColor = selectedColor.cgColor
            iconCell.icon.textColor = selectedColor
            
        }
        
    }
    
    func AddView(showView : UIView) {
        self.view.addSubview(backView)
        showView.isHidden = false
        showView.alpha = 0
        self.view.bringSubview(toFront: showView)

        UIView.animate(withDuration: 0.4) { 
            showView.frame.origin.y -= showView.frame.height
            showView.alpha = 1
        }
        
        searchedUsers = Resource.sharedInstance().currentWallet!.members.filter({ (_user) -> Bool in
            return _user.getUserID() != Resource.sharedInstance().currentUserId!
        })
        
        
        
        searchTableView.reloadData()
    }
    
    func removeView() {
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.SearchMemberView.frame.origin.y += self.SearchMemberView.frame.height
            self.SearchMemberView.alpha = 0
            
        }) { (flag) in
            self.SearchMemberView.isHidden = true
            self.backView.removeFromSuperview()
        }
        
        
    }
    
    func showPopUp() {
//        self.view.removeGestureRecognizer(tap)
//        backView.addGestureRecognizer(tap)
        self.view.addSubview(backView)
        
        backView.alpha = 1
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
            
//            self.backView.removeGestureRecognizer(self.tap)
//            self.view.addGestureRecognizer(self.tap)
            
        })
        
    }
    
    @IBAction func closePopupView(_ sender: UIButton) {
        
        if sender.tag == 0 || (selectedIcon == Resource.sharedInstance().currentWallet!.icon && selectedColor == Resource.sharedInstance().currentWallet!.color) {
            hidePopUp()
        }
        else {
            
            let wallet = Resource.sharedInstance().currentWallet!
            wallet.icon = selectedIcon
            wallet.color = selectedColor
            
            WalletManager.sharedInstance().updateWallet(wallet)
            hidePopUp()
        }
    }
    
    
    // Search Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedUsers = []
        
        if SearchMemberViewTitle.text == "Add Members" {
            let results = Resource.sharedInstance().users.filter { (user) -> Bool in
                
                return user.value.getUserEmail().contains(searchText) && !(memberTypes.contains(where: { (_user) -> Bool in
                    return _user.key == user.key
                }))
            }
            
            print("search results = ", results.count)
            for i in 0..<results.count {
                searchedUsers.append(results[i].value)
            }
        }
        else {
            let results = Resource.sharedInstance().currentWallet!.members.filter { (user) -> Bool in
                
                if SearchMemberViewTitle.text! == "Transfer OwnerShip" && Resource.sharedInstance().currentWallet?.memberTypes[user.getUserID()] == .owner {
                    return false
                }
                
                return user.getUserEmail().contains(searchText)
            }
            
            memberTypes = [:]
            
            for result in results {
                memberTypes[result.getUserID()] = Resource.sharedInstance().currentWallet!.memberTypes[result.getUserID()]
            }
        
        }
//        searchTableView.reloadData()
        searchTableView.reloadSections([0], with: .left)
    }
    
    @IBAction func closeSearchView(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            
            let alert = UIAlertController(title: "Discard Changes", message: "Do you want to discard your recent changes?", preferredStyle: .alert)
            
            let Confirm = UIAlertAction(title: "Confirm", style: .destructive, handler: { (ac) in
                self.memberTypes = Resource.sharedInstance().currentWallet!.memberTypes
                self.removeView()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(Confirm)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            
            let wallet = Resource.sharedInstance().currentWallet!
            wallet.memberTypes = self.memberTypes
            
            WalletManager.sharedInstance().updateWallet(wallet)
            
            self.removeView()
            
            
        }
        
    }
    
// Wallet Delegate
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        
        if wallet.id == Resource.sharedInstance().currentWalletID {
            updateSettingCells()
            self.SettingsTableView.reloadData()
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userAdded(_ user: User) {
        
    }
    
    func userUpdated(_ user: User) {
        if user.getUserID() == Resource.sharedInstance().currentUserId {
            self.SettingsTableView.reloadSections([sections.index(of: "User") ?? 0], with: .fade)
        }
    }
    
    func userDetailsAdded(_ user: CurrentUser) {
        
    }
    
    func userDetailsUpdated(_ user: CurrentUser) {
        if user.getUserID() == Resource.sharedInstance().currentUserId {
            self.SettingsTableView.reloadSections([sections.index(of: "User") ?? 0], with: .fade)
        }
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if member.getUserID() == Resource.sharedInstance().currentUserId && wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.dismiss(animated: true, completion: nil)
        }
        else if Resource.sharedInstance().currentWalletID == wallet.id {
            self.SettingsTableView.reloadSections([sections.index(of: "Members") ?? 0], with: .fade)
        }
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            self.SettingsTableView.reloadSections([sections.index(of: "Members") ?? 0], with: .fade)
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            self.sections = []
            self.settingsSetionCells = []
            
            if Resource.sharedInstance().currentUserId == Resource.sharedInstance().currentWalletID {
                self.sections = ["Wallet","Wallet Settings","User","User Settings","SignOut"]
                self.settingsSetionCells = ["Change Name", "Change Icon", "Notification"]
            }
            else {
                self.sections = ["Wallet","Wallet Settings", "Members"]
                
                self.memberTypes = self.selectedWallet!.memberTypes
                
                if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
                    if Resource.sharedInstance().currentWallet!.isOpen {
                        self.settingsSetionCells = ["Add Member"]
                    }
                    self.settingsSetionCells += ["Change Name", "Change Icon","Notification"]
                    self.sections.append("leaveBtn")
                }
                else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
                    self.settingsSetionCells = ["Notification"]
                    self.sections.append("leaveBtn")
                }
                else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
                    self.settingsSetionCells += ["Change Name", "Change Icon", "Delete Wallet"]
                }
                self.sections += ["User","User Settings","SignOut"]
            }

            self.SettingsTableView.reloadSections([sections.index(of: "Members") ?? 0], with: .fade)
        }
    }
    
}
