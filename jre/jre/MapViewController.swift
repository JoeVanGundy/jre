//
//  MapViewController.swift
//  jre
//
//  Created by Joey Van Gundy on 2/19/16.
//  Copyright © 2016 Joe Van Gundy. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
    //@IBOutlet weak var mapOverlay: UIView!
    
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("onCreate: "+NSStringFromClass(self.dynamicType))
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //self.view .insertSubview(mapOverlay, aboveSubview: mapView)
        
        //Decide the zoom and position of default path
        //let camera = GMSCameraPosition.cameraWithLatitude(-33.86,longitude: 151.20, zoom: 6)
        //let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        //mapView.myLocationEnabled = true

        
        
//        let markerPosition = CLLocationCoordinate2DMake(-33.86, 151.20)
//        let markerTitle = "Yooooo"
//        
//    
//        //Return a marker that needs to be added to the map
//        let marker = createMarker(markerPosition, markerTitle: markerTitle)
//        marker.map = mapView
        //mapView.delegate = self

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
    
   
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
    
}
