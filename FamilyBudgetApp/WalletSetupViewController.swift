//
//  WalletSetupViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/21/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class WalletSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //Currency
    var selectedindex = 0
    
    
    //For Wallet Setup
    @IBOutlet weak var walletIconHeader: UILabel!
    @IBOutlet weak var walletname: UITextField!
    @IBOutlet weak var initialamount: UITextField!
    @IBOutlet weak var currencyName: UITextField!
    @IBOutlet weak var currencyCode: UITextField!
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var iconsCollectionView: UICollectionView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBOutlet var viewsForShadow: [UIView]!
    @IBOutlet weak var currencyView: UIView!
    
    
    var isKeyboardOpen = false
    var tap = UITapGestureRecognizer()
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    var wallet : UserWallet?
    var backView = UIView()
    var selectedIcon = ""
    var selectedColor : UIColor = darkThemeColor
    var pSelectedIcon = ""
    var pSelectedColor : UIColor = darkThemeColor
    var colors : [UIColor] = [darkThemeColor,  .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Currency picker
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        
        currencyName.inputView = currencyView
        currencyCode.inputView = currencyView
        
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        popoverView.isHidden = true
        
        
        finishBtn.layer.cornerRadius = finishBtn.layer.frame.height/2
        
        selectedIcon = "\u{A037}"
        walletIconHeader.textColor = selectedColor
        walletIconHeader.text = selectedIcon
        
        
        for view in viewsForShadow {
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowOpacity = 0.6
            view.layer.shadowRadius = 2
            view.layer.shadowColor = darkThemeColor.cgColor
        }
        
        wallet = UserWallet(id: "new", name: "", icon: "", currencyID: "", creatorID: Resource.sharedInstance().currentUserId!, balance: 0, totInc: 0, totExp: 0, creationDate: Date().timeIntervalSince1970, isPersonal: false, memberTypes: [:], isOpen: true, color: UIColor.blue.stringRepresentation)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        walletIconHeader.layer.cornerRadius = walletIconHeader.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currencyView.frame.origin.y = self.view.frame.height
        self.currencyView.removeFromSuperview()
    }
    
    
    func viewTapped() {
        self.view.endEditing(true)
//        removeView()
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
    
    //currency view adding methods
//    func addView() {
//        self.backView.addGestureRecognizer(tap)
//        view.addSubview(backView)
//        currencyView.isHidden = false
//        currencyPicker.isHidden = false
//
//        self.view.bringSubview(toFront: currencyView)
//        UIView.animate(withDuration: 0.3, animations: {
//            self.currencyView.frame.origin.y -= self.currencyView.frame.height
//        })
//        
//    }
//    
//    func removeView() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.currencyView.frame.origin.y += self.currencyView.frame.height
//        }) { (Success) in
//            self.backView.removeFromSuperview()
//        }
//    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func FinshButton(_ sender: Any) {
        var error = ""
        var errorDis = ""
        
        if walletname.text == "" {
            error = "Wallet Name is Empty"
            errorDis = "Please Enter Wallet Name"
        }
        else if initialamount.text == "" {
            error = "Initial Amount is Empty"
            errorDis = "Please Enter initial amount for Wallet"
        }
        else if currencyName.text == "" {
            error = "No currency Selected"
            errorDis = "Please select currency"
        }
        
        if error == "" {
            
            let personalWallet = UserWallet(id: "", name: walletname!.text!, icon: selectedIcon, currencyID: wallet!.currencyID, creatorID: Authentication.sharedInstance().authUser!.getUserID(), balance: Double(initialamount.text!)!, totInc: Double(initialamount.text!)!, totExp: 0.0, creationDate: Date().timeIntervalSince1970, isPersonal: true, memberTypes: [(Authentication.sharedInstance().authUser?.getUserID())! : .owner], isOpen: true, color: selectedColor.stringRepresentation)
            
            let walletid = WalletManager.sharedInstance().addWallet(personalWallet)
            if walletid != "" {
                Resource.sharedInstance().currentWalletID = walletid
            self.performSegue(withIdentifier: "main", sender: nil)
            }
        }
        else {
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func findFirstVC(cont: UIViewController) -> UIViewController {
        
        if cont is ViewController {
            return cont
            
        }else {
            return findFirstVC(cont: cont.presentingViewController!)
        }
        
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        Authentication.sharedInstance().logOutUser(callback: {
            (err) in
            
            if err == nil {
                self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            }
            else {
                print(err?.localizedDescription)
            }
        })
        
        
    }
    
    @IBAction func doneBtnAction(_ sender: UIButton) {
        //tag 2 for currency buttons
        if sender.tag == 2 {
            let all = Array(Resource.sharedInstance().currencies.keys)
            let this = all[selectedindex]
            
            wallet?.currencyID = this
            currencyCode.text = wallet!.currency.code
            currencyName.text = wallet!.currency.name
            self.view.endEditing(true)
//            removeView()
        }
        else {
            hidePopUp()
        
            walletIconHeader.textColor = selectedColor
            walletIconHeader.text = selectedIcon
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        //tag 2 for currency buttons
        if sender.tag == 2 {
            if wallet!.currencyID != "" {
                currencyCode.text = wallet!.currency.code
                currencyName.text = wallet!.currency.name
            }
            self.view.endEditing(true)
//            removeView()
        }
        else {
            hidePopUp()
            walletIconHeader.textColor = pSelectedColor
            walletIconHeader.text = pSelectedIcon
        }
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
            
            prev.layer.borderColor = UIColor.clear.cgColor
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
                cell.layer.borderColor = UIColor.clear.cgColor
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
        
        return UICollectionViewCell()
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.tag == 1 ? CGSize(width: 40, height: 40) : CGSize(width: 20, height: 20)
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        
        if !isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height/2
                isKeyboardOpen = true
            }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
