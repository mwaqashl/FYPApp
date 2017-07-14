//
//  RegisterViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 2/23/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // For Signup
    var date : Double?
    var selectedrow = 0
    var previous : Int?
    var gend = ["Male","Female"]
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var dateofbirth: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var deleteImageBtn: UIButton!

    @IBOutlet var viewsForShadow: [UIView]!
    @IBOutlet weak var viewForDateAndGender: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var HeaderForDateAndGenderView: UILabel!
    
    let dateformat = DateFormatter()
    let imagePicker = UIImagePickerController()
    var selectedImage : UIImage?
    
    var isKeyboardOpen = false
    var tap = UITapGestureRecognizer()
    var isDateView = false
    var backView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView = UIView(frame: self.view.frame)
        tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        backView.backgroundColor = .lightGray
        backView.alpha = 0.5
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        imagePicker.delegate = self
        
//        viewForDateAndGender.isHidden = true
        gender.inputView = viewForDateAndGender
        dateofbirth.inputView = viewForDateAndGender
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        for view in viewsForShadow {
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowOpacity = 0.6
            view.layer.shadowRadius = 2
            view.layer.shadowColor = themeColorDark.cgColor
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tap)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.width/2
        cameraBtn.layer.cornerRadius = cameraBtn.frame.width/2
        deleteImageBtn.layer.cornerRadius = deleteImageBtn.frame.width/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewForDateAndGender.removeFromSuperview()
    }
    
    func viewTapped() {
        self.view.endEditing(true)
//        removeView()
    }
    
    
//    func addView() {
//        self.backView.addGestureRecognizer(tap)
//        view.addSubview(backView)
//        if isDateView {
//            datePicker.isHidden = false
//            genderPicker.isHidden = true
//        }
//        else {
//            datePicker.isHidden = true
//            genderPicker.isHidden = false
//        }
//        self.view.bringSubview(toFront: viewForDateAndGender)
//        UIView.animate(withDuration: 0.3, animations: {
//            self.viewForDateAndGender.frame.origin.y -= self.viewForDateAndGender.frame.height
//        })
//        
//    }
//    
//    func removeView() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.viewForDateAndGender.frame.origin.y += self.viewForDateAndGender.frame.height
//        }) { (Success) in
//            self.backView.removeFromSuperview()
//        }
//    }
    
    
    @IBAction func CancelButton(_ sender: Any) {
        if isDateView {
            dateofbirth.text = dateofbirth.text
        }
        else {
            gender.text = previous == nil ? "" : gend[previous!]
        }
        self.view.endEditing(true)
//        removeView()
    }
    
    @IBAction func DoneButton(_ sender: Any) {
        if isDateView {
            dateofbirth.text = dateformat.string(from: datePicker.date)
            date = datePicker.date.timeIntervalSince1970
        }
        else {
            gender.text = gend[selectedrow]
            previous = selectedrow
            if gend[selectedrow] == "Male" && userImage.image == #imageLiteral(resourceName: "dp-female") {
                userImage.image = #imageLiteral(resourceName: "dp-male")
            }
            else if gend[selectedrow] == "Female" && userImage.image == #imageLiteral(resourceName: "dp-male") {
                userImage.image = #imageLiteral(resourceName: "dp-female")
            }
        }
        self.view.endEditing(true)
//        removeView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gend.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gend[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //gender.text = gend[row]
        selectedrow = row
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerAction(_ sender: Any) {
        self.view.endEditing(true)
        var error = ""
        var errorDis = ""
        
        if userName.text == "" {
            error = "User Name cannot be empty"
        }
        else if email.text == "" {
            error = "Email cannot be empty"
        }
        else if password.text! == "" || password.text!.characters.count < 6 || repassword.text! == "" || (repassword.text?.characters.count)! < 6 {
            error = "Password error"
            errorDis = "Password cannot be less than 6 characters"
        }
        else if password.text != repassword.text{
            error = "Password error"
            errorDis = "Password and Re-type Password must be same"
        }
        else if gender.text == "" {
            error = "Gender cannot be empty"
        }
        else if dateofbirth.text == "" {
            error = "Date of Birth cannot be empty"
        }
        

        if error == "" {
            let User = CurrentUser.init(id: "", email: email.text!, userName: userName.text!, imageURL: "", birthdate: date! , deviceID: "", gender: previous!)
            
            Authentication.sharedInstance().createUser(email: email.text!, password: password.text!, user: User, callback: { (_error) in
                if _error != nil {
                    error = "Error"
                    errorDis = _error!.localizedDescription
                    let alert = UIAlertController(title: error ,message: errorDis, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.performSegue(withIdentifier: "walletsetup", sender: nil)
                }
            })
            
        }
        else {
            let alert = UIAlertController(title: error, message: errorDis, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpen {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardSize.height
                isKeyboardOpen = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if isKeyboardOpen {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += keyboardSize.height
                isKeyboardOpen = false
            }
        }
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
        }
        
        userImage.image = selectedImage != nil ? selectedImage : (gend[selectedrow] == "Male" ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))

        
        dismiss(animated: true, completion: nil)
    }
    
//    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            selectedImage = pickedImage
//        }
//        
//        userImage.image = selectedImage != nil ? selectedImage : #imageLiteral(resourceName: "persontemp")
//        
//        dismiss(animated: true, completion: nil)
//    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        userImage.image = selectedImage != nil ? selectedImage : (gend[selectedrow] == "Male" ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func GenderAndDateTextFieldEditingBegin(_ sender: UITextField) {
        gender.inputView = viewForDateAndGender
        dateofbirth.inputView = viewForDateAndGender
        if sender == dateofbirth {
            datePicker.isHidden = false
            gender.isHidden = true
        }
        else {
            genderPicker.isHidden = false
            datePicker.isHidden = true
        }
//        addView()
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
