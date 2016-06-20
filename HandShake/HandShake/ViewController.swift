//
//  ViewController.swift
//  HandShake
//
//  Created by Kianush on 5/24/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

let URL_TO_DATA = "https://handshake-7ffdc.firebaseio.com/"

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var userName = "Player_1"
    let firebaseRootRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .NotDetermined {
                if self.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    self.locationManager.requestWhenInUseAuthorization();
                }
            }
        }
        
        self.addObserversForAllUserLocations()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
 
    }
    
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.onLocationAllowed()
    }
    
    // CLL
    func onLocationAllowed() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            self.mapView.showsUserLocation = true
            self.onLocationUpdated()
        }
    }
    
    func onLocationUpdated() {
        self.zoomToUser()
        self.uploadUserCoordinate(self.locationManager.location!.coordinate, deviceUuid: self.getDeviceUuid(), userName: self.userName)
        
    }
    
    func zoomToUser() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_MSEC))), dispatch_get_main_queue(), {()->Void in
            let userLocation = self.locationManager.location
            if userLocation != nil {
                let userCoordinate = userLocation!.coordinate
                let mapRegion = MKCoordinateRegion(center:userCoordinate, span:MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(mapRegion, animated: true)
            }
        })
    }
    
    func getDeviceUuid() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.stringForKey("mapDeviceUUID") == nil) {
            userDefaults.setObject(NSUUID.init().UUIDString, forKey: "mapDeviceUUID")
        }
        return userDefaults.stringForKey("mapDeviceUUID")!
    }
    
    func uploadUserCoordinate(userCoordinates: CLLocationCoordinate2D, deviceUuid: String, userName: String) {
        let newChildRef = self.firebaseRootRef.child(deviceUuid)
        
        let userLocationDictionary: NSDictionary = ["latitude":(userCoordinates.latitude), "longitude":(userCoordinates.longitude)]
        print(userCoordinates.latitude)
        print(userCoordinates.longitude)
        let userInfoDictionary: NSDictionary = ["name":userName, "location":userLocationDictionary]
        
        newChildRef.setValue(userInfoDictionary)
    }
    
    func userLocationAnnotationFromDictionary(valueDictionary: NSDictionary) -> UserLocationAnnotation {
        let userLocationAnnotation : UserLocationAnnotation = UserLocationAnnotation()
        userLocationAnnotation.title = valueDictionary.objectForKey("name") as? String
        let locationDict = valueDictionary.objectForKey("location") as? NSDictionary
        if (locationDict != nil && locationDict?.objectForKey("latitude") != nil && locationDict?.objectForKey("longitude") != nil) {
            let latitude = locationDict?.objectForKey("latitude") as? Double
            let longitude = locationDict?.objectForKey("longitude") as? Double
            userLocationAnnotation.coordinate.latitude = latitude!
            userLocationAnnotation.coordinate.longitude = longitude!
        }
        return userLocationAnnotation
        
    }
    
    func addObserversForAllUserLocations() {
        self.firebaseRootRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            var userLocationAnnotation : UserLocationAnnotation = UserLocationAnnotation()
            userLocationAnnotation = self.userLocationAnnotationFromDictionary(snapshot.value as! NSDictionary)
            self.mapView.addAnnotation(userLocationAnnotation)
        })
    }

}

