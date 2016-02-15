//
//  LogInViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func loginToHome(sender: AnyObject) {
            PFUser.logInWithUsernameInBackground(username.text!, password:password.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("login successful")
                self.performSegueWithIdentifier("loginToHome", sender: self)
                
            } else {
                // The login failed. Check error to see why.
                print("Login failed")
            }
        }

    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        
        if(textField == username){
            password.becomeFirstResponder()
        }
        else if(textField == password){
            password.resignFirstResponder()
        }
        return true
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
