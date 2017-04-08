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
    @IBOutlet weak var nextBtn: UIButton!

    var datepicker = UIDatePicker()
    var genderpicker = UIPickerView()
    let dateformat = DateFormatter()
    let imagePicker = UIImagePickerController()
    var selectedImage : UIImage?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Resource.sharedInstance().currencies.count)
        genderpicker.delegate = self
        genderpicker.dataSource = self
        imagePicker.delegate = self
        userImage.layer.cornerRadius = userImage.frame.width/2
        
        gender.inputView = genderpicker
        dateofbirth.inputView = datepicker
        
        datepicker.datePickerMode = .date
        dateformat.dateFormat = "dd-MMM-yyyy"
//        
        genderpicker.backgroundColor = .white
        datepicker.backgroundColor = .white
        
        registerBtn.layer.borderColor = UIColor(red: 26/255, green: 52/255, blue: 109/255, alpha: 1).cgColor
        registerBtn.layer.borderWidth = 1
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donepressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelpressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel,spaceButton,done], animated: false)
        
        gender.inputAccessoryView = toolbar
        dateofbirth.inputAccessoryView = toolbar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func viewTapped() {
        
        self.view.endEditing(true)
    }
    
    func donepressed(){
        if dateofbirth.isEditing {
            date = datepicker.date.timeIntervalSince1970
            dateofbirth.text = dateformat.string(from: datepicker.date)
            //date = datepicker.date as? Double
            print("\(date))")
        }
        if gender.isEditing {
            gender.text = gend[selectedrow]
            previous = selectedrow
        }
        
        if gend[selectedrow] == "Male" && userImage.image == #imageLiteral(resourceName: "dp-female") {
            userImage.image = #imageLiteral(resourceName: "dp-male")
        }
        else if gend[selectedrow] == "Female" && userImage.image == #imageLiteral(resourceName: "dp-male") {
            userImage.image = #imageLiteral(resourceName: "dp-female")
        }
        
        self.view.endEditing(true)
    }
    
    func cancelpressed(){
        if gender.isEditing {
            gender.text = previous == nil ? "" : gend[previous!]
        }
        self.view.endEditing(true)
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
            
            Auth.sharedInstance().createUser(email: email.text!, password: password.text!, user: User, callback: { (_error) in
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
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
