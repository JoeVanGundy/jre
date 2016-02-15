//
//  RecordReviewViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 11/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import Parse
import GoogleMaps
import CoreLocation

class RecordReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    var placePicker: GMSPlacePicker!
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let saveFileName = "1test.mp4"
    var videoData = NSData()
    var locationManager = CLLocationManager()
    
    struct Restaurant {
        var name: String
        var phone: String
        var longitude: CLLocationDegrees
        var latitude: CLLocationDegrees
    }
    
    var restaurant = Restaurant.init(name: "", phone: "0", longitude: 0, latitude: 0)
    
    @IBOutlet weak var restaurantName: UITextField!
    @IBAction func submitReview(sender: AnyObject) {
        let file = PFFile(name: "test.mp4", data: videoData)
        file.saveInBackground()
        let review = PFObject(className:"Reviews")
        review["name"] = PFUser.currentUser()?.username
        review["reviewFile"] = file
        review["placeName"] = restaurant.name
        review["latitude"] = restaurant.latitude
        review["longitude"] = restaurant.longitude
        review.saveInBackground()
        performSegueWithIdentifier("reviewToHome", sender: self)
        
    }
    
    
    
    @IBAction func recordVideo(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            imagePicker.sourceType = .Camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            imagePicker.videoMaximumDuration = 30
            imagePicker.cameraCaptureMode = .Video
            imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeMedium
            
            presentViewController(imagePicker, animated: true, completion: {})
            
        }
        else {
            print("Camera inaccessable")
        }
    }
    
    @IBOutlet weak var enterNameManually: UILabel!
    
    @IBAction func googleNearby(sender: AnyObject) {
        let center = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)!
            ,(locationManager.location?.coordinate.longitude)!
        )
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        placePicker = GMSPlacePicker(config: config)
        
        
        placePicker?.pickPlaceWithCallback({ (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                
                print("Place name \(place.name)")
                if(place.formattedAddress != nil){
                    self.restaurantName.text = place.name
                    self.enterNameManually.hidden = true
                    self.restaurant = Restaurant(
                        name: place.name,
                        phone: place.phoneNumber,
                        longitude: (self.locationManager.location?.coordinate.longitude)!,
                        latitude: (self.locationManager.location?.coordinate.latitude)!
                    )

                }
                else{
                    self.enterNameManually.hidden = false
                }

            } else {
                print("No place selected")
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        
        textField.resignFirstResponder()
        self.restaurant.name = restaurantName.text!
        self.enterNameManually.hidden = true
        return true
    }
    
    
    // Finished recording a video
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got a video")
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            // Save video to the main photo album
            let selectorToCall = Selector("videoWasSavedSuccessfully:didFinishSavingWithError:context:")
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            
            videoData = NSData(contentsOfURL: pickedVideo)!
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an video
        })
    }
    
    
    // Called when the user selects cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    // Any tasks you want to perform after recording a video
    func videoWasSavedSuccessfully(video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Video saved")
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // What you want to happen
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
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
