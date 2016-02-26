//
//  LoginViewController.swift
//  jre
//
//  Created by Joey Van Gundy on 2/24/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {

    // Create outlet for both the button
    @IBOutlet weak var logInToFacebook: UIButton!
    @IBOutlet weak var logOut: UIButton!
    
    
    @IBAction func loginToFacebook(sender: UIButton) {
        let ref = Firebase(url: "https://jrecse.firebaseio.com")
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController:self,handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            }
            else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            }
            else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                ref.authWithOAuthProvider("facebook", token: accessToken,withCompletionBlock: { error, authData in
                        if (error != nil) {
                            print("Login failed. \(error)")
                            
                            //Facebook login fail
                            if let errorCode = FAuthenticationError(rawValue: error.code) {
                                switch (errorCode) {
                                case .UserDoesNotExist:
                                    print("Handle invalid user")
                                case .InvalidEmail:
                                    print("Handle invalid email")
                                case .InvalidPassword:
                                    print("Handle invalid password")
                                default:
                                    print("Handle default situation")
                                }
                            }
                        }
                        else {
                            print("Logged in! \(authData)")
                            // Create a new user dictionary accessing the user's info
                            // provided by the authData parameter
                            self.logInToFacebook.hidden = true
                            self.logOut.hidden = false
                            let newUser = [
                                "provider": authData.provider,
                                "displayName": authData.providerData["displayName"] as? NSString as? String
                            ]
                            
                            // Create a child path with a key set to the uid underneath the "users" node
                            // This creates a URL path like the following:
                            //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                            ref.childByAppendingPath("users")
                                .childByAppendingPath(authData.uid).setValue(newUser)
                        }
                })
            }
        })
    }
    
    @IBAction func logOut(sender: AnyObject) {
        let ref = Firebase(url: "https://jrecse.firebaseio.com")
        if ref.authData != nil {
            // user authenticated
            ref.unauth()
            print("Logged out")
            self.logInToFacebook.hidden = false
            self.logOut.hidden = true
        } else {
            print("Not signed in")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
