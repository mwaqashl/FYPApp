//
//  AddwalletViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 3/25/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class AddwalletViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var walletName: UITextField!

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
    
    
    var selectedindex = 0
    var currencypicker = UIPickerView()
    var wallet : UserWallet?
    var backView = UIView()
    var selectedIcon = ""
    var selectedColor : UIColor = .blue
    var pSelectedIcon = ""
    var pSelectedColor : UIColor = .blue
    var colors : [UIColor] = [.blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown, .blue, .green, .yellow, .red, .brown]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currencypicker.dataSource = self
        currencypicker.delegate = self
        currencyName.inputView = currencypicker
        currencyCode.inputView = currencypicker
        
        currencypicker.backgroundColor = .white
        backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        popoverView.isHidden = true
        popoverView.layer.cornerRadius = 10
        popoverView.layer.shadowColor = UIColor.gray.cgColor
        popoverView.layer.shadowRadius = 2
        
        doneBtn.layer.borderColor = UIColor(red: 26/255, green: 52/255, blue: 109/255, alpha: 1).cgColor
        doneBtn.layer.borderWidth = 1
        
        selectedIcon = "\u{A037}"
        for icon in walletIcons {
            icon.textColor = selectedColor
            icon.text = selectedIcon
        }
        
        
        wallet = UserWallet(id: "new", name: "", icon: "", currencyID: "", creatorID: Resource.sharedInstance().currentUserId!, balance: 0, totInc: 0, totExp: 0, creationDate: Date().timeIntervalSince1970, isPersonal: false, memberTypes: [:], isOpen: true, color: UIColor.blue.stringRepresentation)
        
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
    
    @IBAction func doneBtnAction(_ sender: Any) {
        
        hidePopUp()
        
        for icon in walletIcons {
            icon.textColor = selectedColor
            icon.text = selectedIcon
        }
        
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        
        
        hidePopUp()
        
        for icon in walletIcons {
            icon.textColor = selectedColor
            icon.text = selectedIcon
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
        
        return UICollectionViewCell()
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.tag == 1 ? CGSize(width: 50, height: 50) : CGSize(width: 24, height: 24)
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
