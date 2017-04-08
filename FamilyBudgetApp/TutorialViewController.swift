//
//  TutorialViewController.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 30/03/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

enum TutorialType {
    
    case startup, timeline, transaction, task, stats, chat, wallets
    
}

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alreadyUserBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var tutorialType : TutorialType! = .startup
    
    var startup : [UIImage] = [#imageLiteral(resourceName: "into-1"),#imageLiteral(resourceName: "into-2"),#imageLiteral(resourceName: "into-3")]
    var timeline = [#imageLiteral(resourceName: "timeline")]
    var wallets = [#imageLiteral(resourceName: "wallets 1"), #imageLiteral(resourceName: "addWallets")]
    var workingArray : [UIImage] = []
    var selected = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alreadyUserBtn.layer.cornerRadius = alreadyUserBtn.frame.height/2
        alreadyUserBtn.layer.borderColor = UIColor.white.cgColor
        alreadyUserBtn.layer.borderWidth = 1
        registerBtn.layer.cornerRadius = alreadyUserBtn.frame.height/2
        registerBtn.layer.borderColor = UIColor.white.cgColor
        registerBtn.layer.borderWidth = 1

        if tutorialType == .startup {
            
            closeBtn.isHidden = true
            alreadyUserBtn.isHidden = false
            registerBtn.isHidden = false
            workingArray = startup
        }
        else {
            
            if tutorialType == .wallets {
                workingArray = wallets
            }
            else if tutorialType == .timeline {
                workingArray = timeline
            }
            imageView.image = workingArray.first
            closeBtn.isHidden = false
            alreadyUserBtn.isHidden = true
            registerBtn.isHidden = true
        }
        
        pageControl.numberOfPages = workingArray.count
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtnAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "login") as! ViewController
        
        self.present(cont, animated: true, completion: nil)
    }
    
    
    @IBAction func newUserBtnAction(_ sender: Any) {
        
        
        let cont = UIStoryboard.init(name: "HuzaifaStroyboard", bundle: nil).instantiateViewController(withIdentifier: "register") as! RegisterViewController
        
        self.present(cont, animated: true, completion: nil)
        
    }
    
    @IBAction func swipedAction(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .left {
            
            if selected == workingArray.count-1 {
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.center.x -= self.imageView.frame.width/2
                self.imageView.alpha = 0
                self.alreadyUserBtn.alpha = 0
                self.registerBtn.alpha = 0
                self.pageControl.alpha = 0
            }, completion: { (flag) in
                if flag {
                    self.imageView.center.x += self.imageView.frame.width
                    self.selected += 1
                    self.imageView.image = self.workingArray[self.selected]
                    self.pageControl.currentPage = self.selected
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.center.x -= self.imageView.frame.width/2
                        self.imageView.alpha = 1
                        self.alreadyUserBtn.alpha = 1
                        self.registerBtn.alpha = 1
                        self.pageControl.alpha = 1
                    })
                }
            })
            
        }
        else if sender.direction == .right {
            
            if selected == 0 {
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.center.x += self.imageView.frame.width/2
                self.imageView.alpha = 0
                self.alreadyUserBtn.alpha = 0
                self.registerBtn.alpha = 0
                self.pageControl.alpha = 0
            }, completion: { (flag) in
                if flag {
                    self.imageView.center.x -= self.imageView.frame.width
                    self.selected -= 1
                    self.imageView.image = self.workingArray[self.selected]
                    self.pageControl.currentPage = self.selected
                    UIView.animate(withDuration: 0.3, animations: {
                        self.imageView.center.x += self.imageView.frame.width/2
                        self.imageView.alpha = 1
                        self.alreadyUserBtn.alpha = 1
                        self.registerBtn.alpha = 1
                        self.pageControl.alpha = 1
                    })
                }
            })
            
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
