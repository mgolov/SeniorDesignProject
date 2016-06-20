//
//  UserLocation.swift
//  HandShake
//
//  Created by Kianush on 5/24/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class UserLocationAnnotation : NSObject, MKAnnotation {
    @objc var coordinate: CLLocationCoordinate2D
    @objc var title: String?
    @objc var subtitle: String?
    
    
    override init() {
        coordinate = CLLocationCoordinate2DMake(0,0)
        title = nil
        subtitle = nil
    }
}