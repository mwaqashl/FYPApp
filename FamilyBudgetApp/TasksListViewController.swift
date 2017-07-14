//
//  TasksListViewController.swift
//  test
//
//  Created by mac on 3/27/17.
//  Copyright © 2017 UIT. All rights reserved.
//

import UIKit

class TasksListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource,TaskDelegate , WalletMemberDelegate, TaskMemberDelegate, WalletDelegate{
    
    @IBOutlet weak var SegmentBtn: UISegmentedControl!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var tableview: UITableView!
    
    var dateformat = DateFormatter()
    var selectedrow : IndexPath?
    
    var Tasks = [Task]()
    var filterTask = [Task]()
    
    var isDataAvailable = false
    
    var SettingsBtn = UIBarButtonItem()
    var allWalletsBtn = UIBarButtonItem()
    @IBOutlet weak var AddTaskBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateformat.dateFormat = "dd-MMM-yyyy"
        
        tableview.dataSource = self
        tableview.delegate = self
        
        Delegate.sharedInstance().addTaskDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        Delegate.sharedInstance().addTaskMemberDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        
        allWalletsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "allWallets"), style: .plain, target: self, action: #selector(self.allWalletsBtnTapped))
        allWalletsBtn.tintColor = darkThemeColor
        
        SettingsBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(self.SettingsBtnTapped))
        SettingsBtn.tintColor = darkThemeColor
        
        self.navigationItem.rightBarButtonItem = SettingsBtn
        self.navigationItem.leftBarButtonItem = allWalletsBtn
        self.tabBarController?.tabBar.barTintColor = .white
        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            
            if flag {
                self.tabBarController!.tabBar.backgroundColor!.withAlphaComponent(0.5)
                self.tabBarController!.tabBar.backgroundColor = darkThemeColor
                self.tabBarController!.tabBar.unselectedItemTintColor = .gray
                self.tabBarController!.tabBar.selectedImageTintColor = darkThemeColor
                self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
                self.isDataAvailable = true
                self.TaskExtraction()
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Resource.sharedInstance().currentWalletID == nil {
            isDataAvailable = false
        }
        
        if isDataAvailable {
            self.tabBarController!.tabBar.unselectedItemTintColor = .gray
            self.tabBarController!.tabBar.selectedImageTintColor = darkThemeColor
            self.navigationItem.title = Resource.sharedInstance().currentWallet!.name
            TaskExtraction()
            for key in Resource.sharedInstance().tasks.keys {
                let task = Resource.sharedInstance().tasks[key]
                if task!.walletID == Resource.sharedInstance().currentWalletID {
                    print(task!.id)
                    print(task!.amount)
                }
            }
            tableview.reloadData()
        }
    }
    
    func TaskExtraction() {
        TaskObserver.sharedInstance().startObserving(TasksOf: Resource.sharedInstance().currentWallet!)
        Tasks = []
        filterTask = []
        for key in Resource.sharedInstance().tasks.keys {
            let task = Resource.sharedInstance().tasks[key]
            if task!.walletID == Resource.sharedInstance().currentWalletID {
                self.Tasks.append(task!)
                if self.SegmentBtn.selectedSegmentIndex == 0 {
                    if task!.status == .open {
                        self.filterTask.append(task!)
                    }
                }
                else if self.SegmentBtn.selectedSegmentIndex == 1 {
                    if task!.status == .completed {
                        self.filterTask.append(task!)
                    }
                }
            }
        }
    }
    
    func SettingsBtnTapped() {
        let cont = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(cont, animated: true, completion: nil)
    }
    
    func allWalletsBtnTapped() {
        let storyboard = UIStoryboard(name: "HuzaifaStroyboard", bundle: nil)
        let cont = storyboard.instantiateViewController(withIdentifier: "allWallets") as! HomeViewController
        self.present(cont, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentBtnValueChanged(_ sender: Any) {
        
        if SegmentBtn.selectedSegmentIndex == 0 {
            filterTask = []
            for i in 0..<Tasks.count {
                if Tasks[i].status == .open {
                    filterTask.append(Tasks[i])
                }
            }
        }
        else if SegmentBtn.selectedSegmentIndex == 1 {
            filterTask = []
            for i in 0..<Tasks.count {
                if Tasks[i].status == .completed {
                    filterTask.append(Tasks[i])
                }
            }
        }
        
        tableview.reloadData()
    }
    
    @IBAction func AddTaskBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "addTask", sender: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let label = UILabel()
        let vieww = UIView(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 25))
        if filterTask.count == 0{
            label.text = "No Tasks to Show\nPress + Button to Add Task"
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.clipsToBounds = true
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = darkThemeColor
            label.sizeToFit()
            label.frame.size.width += 20
            label.frame.size.height += 10
            label.center = vieww.center
            vieww.addSubview(label)
            self.tableview.tableFooterView = vieww
            return 0
        }
        else{
            self.tableview.tableFooterView = nil
            return 1
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return filterTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasks") as! TaskTableViewCell
        let tasks = filterTask[indexPath.row]
        
        cell.Title.text = tasks.title
        cell.icon.text = tasks.category!.icon
        
        if tasks.status == .open {
            if tasks.doneByID == nil || tasks.doneByID == "" {
                cell.status.layer.backgroundColor = UIColor.green.cgColor
                cell.assignTotag.text = "Assign To : "
            }
            else if tasks.doneByID != "" {
                cell.status.layer.backgroundColor = UIColor.orange.cgColor
                cell.assignTotag.text = "In Progress By : "
            }
        }
        else {
            cell.assignTotag.text = "Completed By : "
            cell.status.layer.backgroundColor = UIColor.white.cgColor
        }
        
        cell.icon.textColor = tasks.category!.color
        cell.icon.layer.cornerRadius = cell.icon.layer.frame.width/2
        cell.icon.layer.borderWidth = 1
        cell.icon.layer.borderColor = cell.icon.textColor.cgColor
        
        cell.taskMembers.delegate = self
        cell.taskMembers.dataSource = self
        cell.taskMembers.tag = indexPath.row
        cell.taskMembers.reloadData()
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath
        performSegue(withIdentifier: "Description", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Description" {
            let destination = segue.destination as! AddTaskViewController
            destination.task = filterTask[selectedrow!.row]
            destination.isNew = false
        }
        else if segue.identifier == "addTask" {
            let destination = segue.destination as! AddTaskViewController
            destination.isNew = true
        }
    }
    
//    CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let a = filterTask[collectionView.tag]
        return a.status == .open && a.doneByID == nil ? a.members.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memberCell", for: indexPath) as! TaskMembersCollectionViewCell
        
        let task = filterTask[collectionView.tag]
        
        if task.status == .open {
            if task.doneByID == "" || task.doneByID == nil {
                cell.name.text = task.members[indexPath.item].userName
            }
            else if task.doneByID != "" {
                cell.name.text = task.doneBy!.userName
            }
        }
        else {
            cell.name.text = task.doneBy!.userName
        }
        
        cell.image.image = #imageLiteral(resourceName: "dp-male")
        
        return cell
    }

    func taskAdded(_ task: Task) {
        if Resource.sharedInstance().currentWalletID == task.walletID && isDataAvailable {
            Tasks.insert(task, at: 0)
            if task.status == .open && SegmentBtn.selectedSegmentIndex == 0 {
                filterTask.append(task)
            }
            if task.status == .completed && SegmentBtn.selectedSegmentIndex == 1 {
                filterTask.append(task)
            }
        }
        tableview.reloadData()
    }
    
    func taskDeleted(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            self.TaskExtraction()
            self.tableview.reloadData()
        }
    }
    
    func taskUpdated(_ task: Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            for i in 0..<filterTask.count {
                if task.id == filterTask[i].id {
                    filterTask[i] = task
                    tableview.reloadSections([0], with: .automatic)
                }
            }
            for i in 0..<Tasks.count {
                if task.id == Tasks[i].id {
                    Tasks[i] = task
                }
            }
        }
    }
    
    // Wallet member delegates
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        print("Member AA gaya")
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        
    }

    // Task Members Delegate
    
    func memberAdded(_ member : User, task : Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            for i in 0..<filterTask.count {
                if task.id == filterTask[i].id {
                    filterTask[i] = task
                    tableview.reloadSections([0], with: .automatic)
                }
            }
            for i in 0..<Tasks.count {
                if task.id == Tasks[i].id {
                    Tasks[i] = task
                }
            }
        }
    }
    
    func memberLeft(_ member : User, task : Task) {
        if task.walletID == Resource.sharedInstance().currentWalletID {
            for i in 0..<filterTask.count {
                if task.id == filterTask[i].id {
                    filterTask[i] = task
                    tableview.reloadSections([0], with: .automatic)
                }
            }
            for i in 0..<Tasks.count {
                if task.id == Tasks[i].id {
                    Tasks[i] = task
                }
            }
        }
    }
    
    
    //Wallet Delegatee
    func walletAdded(_ wallet: UserWallet) {
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            if wallet.isOpen {
                AddTaskBtn.isHidden = false
            }
            else if !wallet.isOpen {
                AddTaskBtn.isHidden = true
            }
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            TaskExtraction()
            self.tableview.reloadData()
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

