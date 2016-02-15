//
//  NewUserSignUpViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class NewUserSignUpViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameTaken: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmpassword: UITextField!
    @IBOutlet weak var passwordsdonotmatch: UILabel!
    @IBAction func SignUp(sender: AnyObject) {
        
        let user = PFUser()
        user.username = username.text
        user.password = password.text
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
            } else {
                print("Signed up!");
            }
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        
        if(textField == username){
            password.becomeFirstResponder()
            let query = PFQuery(className: "_User")
            let usernameField = username.text
            query.whereKey("username", equalTo: usernameField!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) in
                if error == nil {
                    if (objects!.count > 0){
                        self.usernameTaken.hidden = false
                        print("username is taken")
                        self.username.becomeFirstResponder()
                        
                    }
                    else {
                        self.usernameTaken.hidden = true
                        print("Username is available. ")
                    }
                }
                else {
                    print("error")
                }
            }
        }
        else if(textField == password){
            print("heldadadalo?")
            confirmpassword.becomeFirstResponder()
        }
        else if(textField == confirmpassword){
            confirmpassword.resignFirstResponder()
            print("hello?")
            if (confirmpassword.text != password.text){
                passwordsdonotmatch.hidden = false;
            }
            else{
                passwordsdonotmatch.hidden = true;
            }
        }
        else{
            print("error")
        }
        return true;
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
        password.delegate = self
        confirmpassword.delegate = self
        

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
