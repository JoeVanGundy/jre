//
//  NewPostViewController.swift
//  jre
//
//  Created by Joey Van Gundy on 3/9/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import AWSS3
import AVKit
import AVFoundation

class NewPostViewController: UIViewController,UITextFieldDelegate{
    let ref = Firebase(url: "https://jrecse.firebaseio.com")
    var placePicker: GMSPlacePicker!
    var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var uploadFileURL: NSURL?
    var myImage = UIImage.init()
    var myVideo = NSURL.init()
    var isVideo = false
    let S3BucketName: String = "jrecse"
    var imageExt = "png"
    var videoExt = "mov"
    var S3UploadKeyName: String = NSProcessInfo.processInfo().globallyUniqueString
    var postPlaceName = ""
    var postPlaceID = ""
    
    @IBOutlet weak var myImageView: UIImageView!
    
    @IBOutlet weak var userCoordinatesLabel: UILabel!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var myVideoView: UIView!
    
    @IBOutlet weak var mediaContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    
    @IBAction func submitPostButton(sender: AnyObject) {
        var mediaExtension = ""
        if(isVideo){
            uploadVideo()
            mediaExtension = videoExt
        }
        else{
            uploadImage()
            mediaExtension = imageExt
        }
        let postRef = ref.childByAppendingPath("posts")
        print(uploadFileURL?.path)
        let newPost = [
            "username": ref.authData.uid,
            "post_place_name": self.postPlaceName,
            "post_placeID": self.postPlaceID,
            "post_longitude": locationManager.location!.coordinate.longitude,
            "post_latitude": locationManager.location!.coordinate.latitude,
            "post_description": "",
            "post_up_votes": 0,
            "post_down_votes": 0,
            "post_flag_count": 0,
            "post_creation_date": getCurrentDate(),
            "post_user_voted": "",
            "post_user_reported": "",
            "post_media_url": self.uploadFileURL!.absoluteString+mediaExtension
        ]
        
        
        
        let newPostRef = postRef.childByAutoId()
        newPostRef.setValue(newPost)
        self.performSegueWithIdentifier("newPostToMap", sender: nil)
    }
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if(isVideo){
            playVideo()
        }
        S3UploadKeyName = S3UploadKeyName + "."
        self.uploadFileURL = NSURL(string: "http://s3.amazonaws.com/\(self.S3BucketName)/\(self.S3UploadKeyName)")!
        
        myImageView.image = myImage
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        // 2
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        // 3
        mediaContainerView.addSubview(blurView)
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        self.resignFirstResponder()
        return true
    }
    
    
    func getCurrentDate() ->Double{
        var timestamp = NSDate().timeIntervalSince1970
        return timestamp
        
    }
    
    func uploadVideo(){
        let videoName = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName + videoExt).lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        
        // getting local path
        let localPath = (documentDirectory as NSString).stringByAppendingPathComponent(videoName!)
        
        
        //getting actual image
        var videoData = NSData(contentsOfURL: myVideo)
        
        //let videoData = NSData(contentsOfFile: localPath)!
        let videoURL = NSURL(fileURLWithPath: localPath)
        
        
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                // self.statusLabel.text = "Uploading..."
                NSLog("Progress is: %f",progress)
            })
        }
        
        uploadCompletionHandler = { (task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    NSLog("Failed with error")
                    NSLog("Error: %@",error!);
                    //    self.statusLabel.text = "Failed"
                }
                else{
                    //    self.statusLabel.text = "Success"
                    NSLog("Sucess")
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility?.uploadFile(myVideo, bucket: S3BucketName, key: S3UploadKeyName+videoExt, contentType: "video/mov", expression: expression, completionHander: uploadCompletionHandler).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                //  self.statusLabel.text = "Failed"
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
                //   self.statusLabel.text = "Failed"
            }
            if let _ = task.result {
                // self.statusLabel.text = "Generating Upload File"
                NSLog("Upload Starting!")
                // Do something with uploadTask.
            }
            
            return nil;
        }
        
    }
    
    func uploadImage(){
        
        
        let imageName = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName + imageExt).lastPathComponent
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        
        
        // getting local path
        let localPath = (documentDirectory as NSString).stringByAppendingPathComponent(imageName!)
        
        //getting actual image
        var image = myImageView.image
        let data = UIImageJPEGRepresentation(image!, 0.5)
        data!.writeToFile(localPath, atomically: true)
        
        let imageData = NSData(contentsOfFile: localPath)!
        let photoURL = NSURL(fileURLWithPath: localPath)
        
        
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.uploadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                // self.statusLabel.text = "Uploading..."
                NSLog("Progress is: %f",progress)
            })
        }
        
        uploadCompletionHandler = { (task, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    NSLog("Failed with error")
                    NSLog("Error: %@",error!);
                    //    self.statusLabel.text = "Failed"
                }
                else{
                    //    self.statusLabel.text = "Success"
                    NSLog("Sucess")
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility?.uploadFile(photoURL, bucket: S3BucketName, key: S3UploadKeyName+imageExt, contentType: "image/png", expression: expression, completionHander: uploadCompletionHandler).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                //  self.statusLabel.text = "Failed"
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
                //   self.statusLabel.text = "Failed"
            }
            if let _ = task.result {
                // self.statusLabel.text = "Generating Upload File"
                NSLog("Upload Starting!")
                // Do something with uploadTask.
                print(photoURL)
            }
            
            return nil;
        }
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func playVideo(){
        
        self.myVideoView.hidden = false
        
        let player = AVPlayer(URL: myVideo)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.myVideoView.layer.addSublayer(playerLayer)
        player.play()
        // Add notification block
        NSNotificationCenter.defaultCenter().addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem, queue: nil)
        { notification in
            let t1 = CMTimeMake(0, 100);
            player.seekToTime(t1)
            player.play()
        }
    }
    
    @IBAction func cancelPostButton(sender: AnyObject) {
        self.performSegueWithIdentifier("newPostToCamera", sender: nil)
    }
    
    
    
}

extension NewPostViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func googleNearbyButton(sender: AnyObject) {
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
                
                if(place.formattedAddress != nil){
                    self.postPlaceName = place.name
                    self.postPlaceID = place.placeID
                    //                    self.restaurant = Restaurant(
                    //                        name: place.name,
                    //                        phone: place.phoneNumber,
                    //                        longitude: (self.locationManager.location?.coordinate.longitude)!,
                    //                        latitude: (self.locationManager.location?.coordinate.latitude)!
                    //                    )
                    
                }
            } else {
                print("No place selected")
            }
        })
    }
}
