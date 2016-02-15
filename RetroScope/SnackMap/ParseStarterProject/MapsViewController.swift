//
//  MapsViewController.swift
//  ParseStarterProject
//
//  Created by Joey Van Gundy on 2/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import Parse
import GoogleMaps
import CoreLocation



class MapsViewController: UIViewController {
    var textArray: NSMutableArray! = NSMutableArray()
    
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self

        let query = PFQuery(className: "Reviews")
        let names = query.findObjects() as! [PFObject]
        
        
        
        for name in names { // message is of PFObject type

            var latitude = name["latitude"] as! CLLocationDegrees
            var longitude = name["longitude"] as! CLLocationDegrees
            
            var  position = CLLocationCoordinate2DMake(latitude, longitude)
            var marker = GMSMarker(position: position)
            marker.title = name["placeName"] as! String
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
        }

        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "mapsToVideo") {
            //print(self.mapView.selectedMarker)
            print("SADWAG")
            var svc = segue.destinationViewController as! VideoPlayerViewController

            
            svc.restaurantName = self.mapView.selectedMarker.title

        }
    }
    
    
    
    
    
    
}
// MARK: - CLLocationManagerDelegate
//1
extension MapsViewController: CLLocationManagerDelegate {
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
}

// MARK: - GMSMapViewDelegate
extension MapsViewController: GMSMapViewDelegate {
    
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        //performSegueWithIdentifier("mapsToVideo", sender: self)
        return false
    }
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        performSegueWithIdentifier("mapsToVideo", sender: self)
    }
    
    
    
}

