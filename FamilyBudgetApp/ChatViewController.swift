//
//  ChatViewController.swift
//  FamilyBudgetApp
//
//  Created by PLEASE on 27/05/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDelegate, UITextViewDelegate {
    
    @IBAction func SendMessage(_ sender: Any) {
        if MessageTextField.text != ""{
        ChatManager.sharedInstance().addNewMessage(msg: Message.init(id: "", message: MessageTextField.text!, date: Date().timeIntervalSince1970, senderID: Resource.sharedInstance().currentUserId! , walletID: Resource.sharedInstance().currentWalletID!))
            self.view.endEditing(true)
            MessageTextField.text = "Write Message Here"
        }
        
    }
    @IBOutlet weak var MessageTextField: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    var isKeyboardOpen = false
    var tap = UITapGestureRecognizer()
    
    var dates = [Date]()
    var dateFormat = DateFormatter()
    var timeFormat = DateFormatter()
    var sortedMessages = [String : [Message]]()
    var messages = [Message]()
    var isDataAvailable = false
    
    var lightThemeColor = UIColor(red: 205/255, green: 233/255, blue: 178/255, alpha: 1)
    var darkThemeColor = UIColor(red: 98/255, green: 141/255, blue: 84/255, alpha: 1)
    var midThemeColor = UIColor(red: 117/255, green: 171/255, blue: 87/255, alpha: 1)
    var ThemeColor = UIColor(red: 149/255, green: 188/255, blue: 117/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //keyboard gestures
        tap = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        self.view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        
        Delegate.sharedInstance().addChatDelegate(self)
        
        tableView.backgroundColor = UIColor.clear
        
        dateFormat.dateFormat = "dd-MMM-yyyy"
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag{
                self.isDataAvailable = true
                ChatObserver.sharedInstance().startObserving(wallet: Resource.sharedInstance().currentWallet!)
                self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
                self.extractMessage()
                
                
                self.tableView.reloadData()
            }
        }


        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if isDataAvailable {
            ChatObserver.sharedInstance().startObserving(wallet: Resource.sharedInstance().currentWallet!)
            self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
            extractMessage()
        }
        tableView.reloadData()
    }
    
    func viewTapped() {
        self.view.endEditing(true)
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        if MessageTextField.text! == "Write Message Here"{
            MessageTextField.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if MessageTextField.text! == ""{
            MessageTextField.text = "Write Message Here"
        }
    }
    
    func extractMessage(){
        
        dates = []
        sortedMessages = [:]
        messages = []
        
        print("wallet id",Resource.sharedInstance().currentWalletID!)
        for key in Resource.sharedInstance().walletChat.keys{
            if key == Resource.sharedInstance().currentWalletID{
                print(key)
                messages = Resource.sharedInstance().walletChat[key]!
                print(messages.count)
                print("time is: \(timeFormat.string(from: messages.first!.timestamp))")
            }
        }
        
        for i in 0..<messages.count{
            let date = dateFormat.string(from: messages[i].timestamp)
            if sortedMessages.keys.contains(date){
                sortedMessages[date]!.append(messages[i])
            }
            else{
                sortedMessages[date] = [messages[i]]
                dates.append(messages[i].timestamp)
                print("timestamp: ",messages[i].timestamp)
            }
        }
        
            }
        
    func sortDates(){
        var dt = [String]()
        for i in 0..<dates.count{
            dt = [dateFormat.string(from: dates[i])]
            }
        var dts = [Date]()
        for i in 0..<dt.count{
            dts = [dateFormat.date(from: dt[i])!]
        }
        dts.sort { (a, b) -> Bool in
            a.compare(b) == .orderedAscending
        }
        dates = dts
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if isDataAvailable {
            ChatObserver.sharedInstance().startObserving(wallet: Resource.sharedInstance().currentWallet!)
            self.navigationItem.title = Resource.sharedInstance().currentWallet?.name
            extractMessage()
        }
        tableView.reloadData()

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let label = UILabel()
        let vieww = UIView(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 25))
        if dates.count == 0{
            label.text = "No messages"
            label.textAlignment = .center
            label.clipsToBounds = true
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = darkThemeColor
            label.sizeToFit()
           // label.layer.cornerRadius = label.frame.width/2
            label.frame.size.width += 10
            label.frame.size.height += 10
            label.center = vieww.center
            vieww.addSubview(label)
            self.tableView.tableFooterView = vieww
            return 0
        }
        else{
            self.tableView.tableFooterView = nil
            return dates.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        dateFormat.dateFormat = "dd-MMM-yyyy"
        
        if dates[section] == Date(){
            return "Today"
        }
        else if dates[section] == Date(timeIntervalSinceNow : Double(-24*3600)){
            return "Yesterday"
        }
        else{
            return dateFormat.string(from: dates[section])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let views = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        views.backgroundColor = UIColor.clear
        let label : UILabel = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 11)
        label.text = dateFormat.string(from: dates[section])
        label.backgroundColor =  lightThemeColor
        label.textColor = darkThemeColor
        label.textAlignment = .center
        label.clipsToBounds = true
        label.sizeToFit()
        label.layer.cornerRadius = label.frame.height/2
        label.frame.size.width += 10
        label.frame.size.height += 6
        label.center = views.center
        views.addSubview(label)
        return views
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return sortedMessages[dateFormat.string(from: dates[section])]?.count  ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        timeFormat.amSymbol = "AM"
        timeFormat.pmSymbol = "PM"
        timeFormat.dateFormat = "hh:mm a"

        var msg = sortedMessages[dateFormat.string(from: dates[indexPath.section])]
        let sortTime = timeFormat.string(from: msg![indexPath.row].timestamp)
 
        if msg![indexPath.row].sender != Resource.sharedInstance().currentUserId {
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "Received") as! ReceiverTableViewCell
            
            cell1.ReceivedMessage.text = ("\(msg![indexPath.row].message)")
            //cell1.ReceivedMessage.sizeToFit()
            cell1.ReceivedTime.text = sortTime
            cell1.ReceivedTime.textColor = UIColor.lightGray
            cell1.ReceivedDP.image = Resource.sharedInstance().users[msg![indexPath.row].sender]?.image ?? #imageLiteral(resourceName: "dp-male")
            cell1.ReceivedName.textColor = UIColor.lightGray
            cell1.ReceivedName.text = Resource.sharedInstance().users[msg![indexPath.row].sender]?.userName
            cell1.ReceivedName.sizeToFit()
            return cell1
            
            
        }
            
        else {
            
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Sent") as! SenderTableViewCell
            cell2.SenderMessage.text = ("\(msg![indexPath.row].message)")
            cell2.SenderMessage.sizeToFit()
            cell2.SendTime.textColor = UIColor.lightGray
            cell2.SenderName.textColor = UIColor.lightGray
            cell2.SendTime.text = sortTime
            cell2.SenderName.text = Resource.sharedInstance().currentUser?.userName
            cell2.SenderName.sizeToFit()
            cell2.SenderDP.image = Resource.sharedInstance().currentUser?.image ?? #imageLiteral(resourceName: "dp-male")
            return cell2
        }
    }
    //Chat Delegate
    func newMessageArrived(message: Message) {
        dateFormat.dateFormat = "dd-MMM-yyyy"
        if message.walletID == Resource.sharedInstance().currentWalletID{
            if isDataAvailable {
                let strdate = dateFormat.string(from: message.timestamp)
                print("strdate ",message.timestamp)
                if sortedMessages.keys.contains(strdate){
                    let msgs = sortedMessages[strdate]
                    if !msgs!.contains(where: { (msg) -> Bool in
                        return msg.id == message.id
                    }){
                        sortedMessages[strdate]?.append(message)
                        }
                    }
                else{
                    sortedMessages[strdate] = [message]
                    dates.append(message.timestamp)
                    sortDates()
                }
                
                tableView.reloadData()
                
                let lastSection = tableView.numberOfSections - 1
                if lastSection<0 {return}
                let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
                if lastRow<0  { return}
                
                let ip: NSIndexPath = IndexPath(row: lastRow , section: lastSection) as NSIndexPath
                tableView.scrollToRow(at: ip as IndexPath, at: .bottom, animated: true)
                
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
