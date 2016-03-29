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
import MapKit

class MapViewController: UIViewController, UISearchBarDelegate {
    var markerPlaceID = ""
    var markerPlaceName = ""
    
    
    @IBAction func searchButton(sender: AnyObject) {
        if searchBar.hidden {
            searchBar.hidden = false
            searchButton.setTitle("Cancel", forState: UIControlState.Normal)
        }else{
            searchBar.hidden = true
            searchButton.setTitle("Shoot", forState: UIControlState.Normal)
        }
    }
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    //@IBOutlet weak var mapOverlay: UIView!
    func searchBarSearchButtonClicked(searchbar: UISearchBar) {
        print("search for \(searchBar.text!)")
        var lat:Double = 0, lon:Double = 0
        //        postRef.queryOrderedByChild("post_place_name").queryEqualToValue("\(searchBar.text!)").observeEventType(.Value, withBlock: { snapshot in
        //            let temp = snapshot.children.nextObject()
        //            lat = temp!.value["post_latitude"] as! Double
        //            lon = temp!.value["post_longitude"] as! Double
        //            print("lat: \(lat), lon: \(lon)")
        //            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude:lon, zoom: 16)
        //            self.mapView.animateToCameraPosition(camera)
        //        })
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            lat = localSearchResponse!.boundingRegion.center.latitude
            lon = localSearchResponse!.boundingRegion.center.longitude
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude:lon, zoom: 16)
            self.mapView.animateToCameraPosition(camera)
        }
    }
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.hidden = true
        searchBar.delegate = self

        mapView.delegate = self
        
        print("onCreate: "+NSStringFromClass(self.dynamicType))
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Get a reference to our posts
        let postRef = Firebase(url:"https://jrecse.firebaseio.com/posts")
        postRef.queryOrderedByChild("post_place_name").observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.value["post_place_name"] as! String)
            let marker_place_name = snapshot.value["post_place_name"]
            let marker_place_id = snapshot.value["post_placeID"]
            let marker_longitude = snapshot.value["post_longitude"]
            let marker_latitude = snapshot.value["post_latitude"]
            let marker_description = snapshot.value["post_description"]
            let markerPostition = CLLocationCoordinate2DMake(marker_latitude as! Double, marker_longitude as! Double)
//            let marker = self.createMarker(markerPostition, markerTitle: marker_place_name as! String)
            let marker = GMSMarker()
            marker.title = marker_place_name as! String
            marker.position = markerPostition
            marker.userData = marker_place_id as! String
            marker.map = self.mapView
            print(marker.userData)
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
    
    @IBAction func newPostButton(sender: AnyObject) {
        let userRef = Firebase(url: "https://jrecse.firebaseio.com/users")
        if(userRef.authData != nil){
            self.performSegueWithIdentifier("mapViewToCameraView", sender: nil)
        }else{
            self.performSegueWithIdentifier("mapViewToLoginView", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapViewToTableView" {
            if let destination = segue.destinationViewController as? PlaceTableViewController {
                
                destination.placeID = self.markerPlaceID
                destination.placeTitile = self.markerPlaceName
                
                print("----1----")
                print(self.markerPlaceID)
                
                print("----2----")
                print(destination.placeID)
                
            }
        }
    }

    
    
    
}



extension MapViewController: GMSMapViewDelegate{
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        print("tap")
        return false
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        print("tap")
        self.markerPlaceName = marker.title
        self.markerPlaceID = marker.userData as! String
        self.performSegueWithIdentifier("mapViewToTableView", sender: nil)
    }
}
