//
//  LoginViewController.swift
//  try
//
//  Created by Zhenyang gong on 4/20/20.
//  Copyright © 2020 Junyi Zhang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    @IBOutlet weak var btn_sign_out: UIButton!
    @IBOutlet weak var signinBtn: GIDSignInButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func btnSignOutAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.btn_sign_out.isHidden = true
            self.confirmBtn.isHidden = true
            self.signinBtn.isHidden = false
            self.welcomeLabel.isHidden = true
            nameLabel.text = "Please login"
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // constants
    let userDefault = UserDefaults.standard
    func currentUserName() {
        if let currentUser = Auth.auth().currentUser {
            self.btn_sign_out.isHidden = false
            self.confirmBtn.isHidden = false
            self.signinBtn.isHidden = true
            self.welcomeLabel.isHidden = false
            nameLabel.text = currentUser.displayName ?? "DISPLAY NAME NOT FOUND"
        }
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                return
            } else {
                self.currentUserName()
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btn_sign_out.isHidden = true
        self.confirmBtn.isHidden = true
        self.signinBtn.isHidden = false
        self.welcomeLabel.isHidden = true
        nameLabel.text = "Please login"
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Do any additional setup after loading the view.
    }
    
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                print("user created!")
                self.signInUser(email: email, password: password)
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }
    
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                print("user signed in!")
                
                self.userDefault.set(true, forKey: "usersignedin")
                self.userDefault.synchronize()
                //self.performSegue(withIdentifier: "Segue_To_Sig", sender: <#T##Any?#>)
            } else if (error?._code == AuthErrorCode.userNotFound.rawValue) {
                self.createUser(email: email, password: password)
            } else {
                print(error?.localizedDescription)
            }
            
        }
    }


}
