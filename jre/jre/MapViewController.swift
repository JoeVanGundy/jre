//
//  MapViewController.swift
//  jre
//
//  Created by Joey Van Gundy on 2/19/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class MapViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    //@IBOutlet weak var mapOverlay: UIView!
    
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("onCreate: "+NSStringFromClass(self.dynamicType))
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Get a reference to our posts
        let postRef = Firebase(url:"https://jrecse.firebaseio.com/posts")
        postRef.queryOrderedByChild("post_place_name").observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value["post_place_name"] as! String)
            let marker_place_name = snapshot.value["post_place_name"]
            let marker_longitude = snapshot.value["post_longitude"]
            let marker_latitude = snapshot.value["post_latitude"]
            let marker_description = snapshot.value["post_description"]
            let markerPostition = CLLocationCoordinate2DMake(marker_latitude as! Double, marker_longitude as! Double)
            let marker = self.createMarker(markerPostition, markerTitle: marker_place_name as! String)
            marker.map = self.mapView
            print("Marker placed!")

        })
    }
    

         override func didReceiveMemoryWarning() {
           super.didReceiveMemoryWarning()
           // Dispose of any resources that can be recreated.
         }

         override func viewWillAppear(animated: Bool) {
           super.viewWillAppear(animated)
           print("onStart/onResume: "+NSStringFromClass(self.dynamicType))
         }

         override func viewWillDisappear(animated: Bool) {
           super.viewWillDisappear(animated)
           print("onPause/onStop: "+NSStringFromClass(self.dynamicType))
         }
    
    
    
    func createMarker(markerPosition: CLLocationCoordinate2D, markerTitle: String) ->GMSMarker{
        let marker = GMSMarker()
        marker.title = markerTitle
        marker.position = markerPosition
        return marker
    }
    
    func populateMapWithPosts(){
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
   
    
    



}

// MARK: - CLLocationManagerDelegate
//1
extension MapViewController: CLLocationManagerDelegate {
    // 2
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 3
        if status == .AuthorizedWhenInUse {
            
            // 4
            locationManager.startUpdatingLocation()
            
            //5
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            // 7
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 8
            locationManager.stopUpdatingLocation()
        }
        
    }
    @IBAction func showMapButton(sender: AnyObject) {
        self.performSegueWithIdentifier("showCamera", sender: nil)
    }
    
}
