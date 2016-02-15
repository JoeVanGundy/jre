//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfilePictureViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBAction func submitProfilePicture(sender: AnyObject) {
        let imageData = UIImagePNGRepresentation(userImage.image!)
        let imageFile = PFFile(name:"image.png", data:imageData!)
        PFUser.currentUser()?["image"] = imageFile
        
        PFUser.currentUser()?.saveInBackgroundWithBlock{(success, error) -> Void in
            if success == true{
                print("successful")
            }
            else{
                print("failed")
            }
            
        }

        performSegueWithIdentifier("showHomeScreen", sender: self)
    }
    @IBAction func uploadPhoto(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.Camera
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        print("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        userImage.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name"])
        graphRequest.startWithCompletionHandler({
            (connection, result, error) -> Void in
            
            if error != nil{
                print(error)
            }
            else if let result = result {
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?.saveInBackgroundWithBlock{(success, error) -> Void in
                    if success == true{
                        print("successful")
                    }
                    else{
                        print("failed")
                    }
                }

                let userID = result["id"] as! String
                let facebookProfilePictureURL = "https://graph.facebook.com/" + userID + "/picture?type=large"
            
                if let fbPicUrl = NSURL(string: facebookProfilePictureURL){
                    if let data = NSData(contentsOfURL: fbPicUrl){
                        self.userImage.image = UIImage(data: data)
                        
                        let imageFile:PFFile = PFFile(data: data)
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.saveInBackgroundWithBlock{(success, error) -> Void in
                            if success == true{
                                print("successful")
                            }
                            else{
                                print("failed")
                            }
                        }
                        
                        
                    }
                }
            }
        })
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
