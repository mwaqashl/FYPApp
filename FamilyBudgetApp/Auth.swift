 //
//  Authentication.swift
//  AccBook
//
//  Created by Waqas Hussain on 24/08/2016.
//  Copyright © 2016 Collage. All rights reserved.
//

import Foundation
import Firebase
import Google
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

class Auth : NSObject, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var authUser : CurrentUser?
    var isAuthenticated = false
    private static var singleTonInstance : Auth?
    private var fbloginMgr : FBSDKLoginManager?
    private let defaultSettings = NSUserDefaults.standardUserDefaults()
    var callback: ((isNewUser: Bool) -> Void)?
    
    func logOutUser() -> NSError? {
        do{
            try FIRAuth.auth()?.signOut()
            isAuthenticated = false
            Resource.sharedInstance().reset()
            FIRDatabase.database().reference().removeAllObservers()
            return nil
        }catch let error as NSError{
            print(error.localizedDescription)
            return error
        }
    }
    
    class func sharedInstance() -> Auth {
        guard let instance = singleTonInstance else{
            singleTonInstance = Auth()
            singleTonInstance?.configureGoogleAuth()
            singleTonInstance?.fbloginMgr = FBSDKLoginManager()
            singleTonInstance?.configureFacebookAuth()
            return singleTonInstance!
        }
        return instance
    }
    func authUsingGoogle(silently: Bool, callBack: (isNewUser: Bool) -> Void) {
        
        if silently {
            GIDSignIn.sharedInstance().signInSilently()
        }
        else {
            GIDSignIn.sharedInstance().signIn()
        }
        self.callback = callBack
    }
    func authUsingFaceBook(silently : Bool, controller :  UIViewController, callBack: (isNewUser: Bool) -> Void) {
        self.callback = callBack
        if !silently {
            fbloginMgr?.logInWithReadPermissions(["public_profile", "email"], fromViewController: controller, handler: { (result, error) in
                self.loginButton(didCompleteWithResult: result, error: error)
            })
        }else{
            if let accessToken = FBSDKAccessToken.currentAccessToken() {
                signInWithFacebook(withAccessToken: accessToken)
            }
        }
    }
    func authUsingTwitter(callBack: (isNewUser: Bool) -> Void) {
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                print("signed in as \(session!.userName)");
                self.twitterSignIn(session!)
            } else {
                print("error: \(error!.localizedDescription)");
            }
        }
        self.callback = callBack
    }
    
    private func configureGoogleAuth() {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().scopes = ["profile", "email"]
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
    private func configureFacebookAuth() {
        fbloginMgr!.loginBehavior = .Native
    }
    private func configureTwitterAuth() {
        
        let twitter = Twitter.sharedInstance()
        twitter.startWithConsumerKey("Hyu4neGc5QTApInoFfofZ6gZC", consumerSecret: "J6DRW2kNHcqp7ngZMF0RbQJ2biaYFc8Ul1afHZ5zAdnNS6fRg9")
        
        let oauthSigning = TWTROAuthSigning(authConfig:twitter.authConfig, authSession:twitter.sessionStore.session() as! TWTRSession)
        let authHeaders = oauthSigning.OAuthEchoHeadersToVerifyCredentials() as? [String:String]
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.yourbackend.com/check_credentials")!)
        request.allHTTPHeaderFields = authHeaders
        
        
    }
    
    // FSDKLoginKit Delegate Functions
    private func loginButton(didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        guard let resultConfirm = result else {
            return
        }
        guard !resultConfirm.isCancelled else {
            return
        }
        if let error = error {
            print(error.localizedDescription)
            return
        }
        self.defaultSettings.setValue("f", forKey: "authProvider")
        signInWithFacebook(withAccessToken: FBSDKAccessToken.currentAccessToken())
    }
    private func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do{
            try FIRAuth.auth()?.signOut()
            Resource.sharedInstance().reset()
        }catch let error as NSError {
            print(error)
        }
        
    }
    private func signInWithFacebook(withAccessToken accessToken : FBSDKAccessToken){
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken.tokenString)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            //..
            
            if error != nil {
                
                print(error?.localizedDescription)
                return
            }
            var newUser = CurrentUser(id: user!.uid, email: user!.email!, userName: user!.displayName!, imageURL: "https://graph.facebook.com/\(accessToken.userID)/picture?type=large", birthdate: nil, deviceIDs: nil, subscriptionType: .None, lastSubscription: nil)
            
            UserManager.sharedInstance().userLoggedIn(newUser.getUserID())
            
            if (self.defaultSettings.valueForKey("lastUserIDs") as! [String]).contains(newUser.getUserID()){
                Resource.sharedInstance().currentUserId = user!.uid
                self.callback?(isNewUser: false)
            }else{
                FIRDatabase.database().reference().child("UserInfo").child(newUser.getUserID()).observeSingleEventOfType(.Value, withBlock: { (snap) in
                    
                    self.isAuthenticated = true
                    Resource.sharedInstance().currentUserId = user!.uid
                    if let data = snap.value as? NSDictionary {
                        newUser = CurrentUser(id: user!.uid, email: data["email"] as! String, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceIDs: nil, subscriptionType: .None, lastSubscription: data["lastSubscription"] as? Double)
                        Resource.sharedInstance().users[newUser.getUserID()] = newUser
                        
                        //did for quick logging in; refer to DefaultKeys for detail;
                        var users = (self.defaultSettings.valueForKey("lastUserIDs") as! [String])
                        users.append(newUser.getUserID())
                        self.defaultSettings.setValue(users, forKey: "lastUserIDs")
                        
                        self.callback?(isNewUser: false)
                    }
                    else {
                        self.authUser = newUser
                        self.callback?(isNewUser: true)
                    }
                    
                    
                })
            }
        }
    }
    
    
    // GoolgeSignIn Delegate Functions
    internal func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        do{
            try FIRAuth.auth()?.signOut()
            Resource.sharedInstance().reset()
        }catch let error as NSError {
            print(error)
        }
    }
    internal func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        // sign in to firebase using credentials
        if error != nil {
            print(error.localizedDescription)
            return
        }
        self.defaultSettings.setValue("g", forKey: "authProvider")
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (firuser, error) in
            self.isAuthenticated = true
            if error != nil {
                
                print(error?.localizedDescription)
                return
            }
            var newUser = CurrentUser(id: firuser!.uid, email: user.profile.email!, userName: firuser!.displayName!, imageURL: user.profile.imageURLWithDimension(UInt.max).absoluteString, birthdate: nil, deviceIDs: nil, subscriptionType: .None, lastSubscription: nil)
            UserManager.sharedInstance().userLoggedIn(newUser.getUserID())
            
            if (self.defaultSettings.valueForKey("lastUserIDs") as! [String]).contains(newUser.getUserID()){
                Resource.sharedInstance().currentUserId = firuser!.uid
                self.callback?(isNewUser: false)
            }else{
                FIRDatabase.database().reference().child("UserInfo").child(newUser.getUserID()).observeSingleEventOfType(.Value, withBlock: { (snap) in
                    Resource.sharedInstance().currentUserId = firuser!.uid
                    if let data = snap.value as? NSDictionary {
                        newUser = CurrentUser(id: firuser!.uid, email: data["email"] as! String, userName: data["userName"] as! String, imageURL: data["image"] as! String, birthdate: data["birthDate"] as? Double, deviceIDs: nil, subscriptionType: .None, lastSubscription: data["lastSubscription"] as? Double)
                        
                        Resource.sharedInstance().users[newUser.getUserID()] = newUser
                        //did for quick logging in; refer to DefaultKeys for detail;
                        var users = (self.defaultSettings.valueForKey("lastUserIDs") as! [String])
                        users.append(newUser.getUserID())
                        self.defaultSettings.setValue(users, forKey: "lastUserIDs")
                        
                        self.callback?(isNewUser: false)
                    }
                    else {
                        self.authUser = newUser
                        self.callback?(isNewUser: true)
                    }
                })
            }
            
            
        })
        
    }
    
    // TwitterSignIn Delegate Functions
    private func twitterSignIn(session : TWTRSession) {
        
    }
    
    
    
}
