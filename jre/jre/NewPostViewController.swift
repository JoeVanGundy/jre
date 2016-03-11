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

class NewPostViewController: UIViewController,UITextFieldDelegate{
    let ref = Firebase(url: "https://jrecse.firebaseio.com")

    @IBOutlet weak var userCoordinatesLabel: UILabel!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBAction func submitPostButton(sender: AnyObject) {
        let postRef = ref.childByAppendingPath("posts")
        
        let newPost = [
            "username": ref.authData.uid,
            "post_place_name": placeNameTextField.text! as String,
            "post_longitude": locationManager.location!.coordinate.longitude,
            "post_latitude": locationManager.location!.coordinate.latitude,
            "post_description": "hello",
            "post_up_votes": 0,
            "post_down_votes": 0,
            "post_flag_count": 0,
            "post_creation_date": getCurrentDate(),
            "post_media_url": "http://google.com"
        ]
        
        let newPostRef = postRef.childByAutoId()
        newPostRef.setValue(newPost)
    }
    
    @IBAction func getUserCoordinates(sender: AnyObject) {
       userCoordinatesLabel.text = "Latitude:\(locationManager.location?.coordinate.latitude),Longitude:\(locationManager.location?.coordinate.longitude)"
    }
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        placeNameTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        placeNameTextField.resignFirstResponder()
        return true
    }
    
    
    func getCurrentDate() ->Double{
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
//        let hour = components.hour
//        let minutes = components.minute
//        let seconds = components.second
        
        var timestamp = NSDate().timeIntervalSince1970
        
        return timestamp
        
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
}
