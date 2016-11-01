//
//  LocationManager.swift
//  Flirtbox
//
//  Created by Azamat Valitov on 13.11.15.
//  Copyright © 2015 flirtbox. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: Shared Instance
    static let sharedInstance = LocationManager()
	
	var latitude : Double {
		get{
			return lat ?? 0;
		}
	};
	var longitude: Double {
		get{
			return lon ?? 0;
		}
	}
	
    private var locationManager: CLLocationManager?
    override init () {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.distanceFilter = 50;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest;
        
        if CLLocationManager.headingAvailable() {
			locationManager!.headingFilter = 5;
        }
        
        FBEvent.onAuthenticated().listen(self) { [unowned self] (isAuthenticated) -> Void in
            if isAuthenticated {
                self.updateLocation()
            }
        }
    }
    
    // MARK: - Helper methods
    private let kNeedAutoupdateKey = "kNeedAutoupdateKey"
    private let kLastUpdateDateKey = "kLastUpdateDateKey"
    func checkAutoupdate(autoupdate: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(NSNumber(bool: autoupdate), forKey: kNeedAutoupdateKey)
        userDefaults.synchronize()
    }
    private var updateLocationAndStop = true
    func updateLocationIfNeed() {
        if AuthMe.isAuthenticated() {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let autoUpdate = userDefaults.objectForKey(kNeedAutoupdateKey) as? NSNumber where autoUpdate.boolValue == true {
                let lastUpdateDate = userDefaults.objectForKey(kLastUpdateDateKey)
                if lastUpdateDate == nil || (lastUpdateDate is NSDate && NSDate().timeIntervalSinceDate(lastUpdateDate as! NSDate) > 3600) {
                    if self.isUpdating {
                        self.updateLocation()
                    }else{
                        self.updateLocationAndStop = true
                        self.startUpdating()
                    }
                }
            }
        }
    }
    func updateLocation() {
        if let lat = lat, let lon = lon where AuthMe.isAuthenticated() {
            Net.updateProfileLocation(lat, lon: lon)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(NSDate(), forKey: kLastUpdateDateKey)
            userDefaults.synchronize()
        }
    }
    private var heading: Double? = nil
    private var headingBlock: ((Double)->())?
    func setHeadingProcessBlock(block: (Double)->()) {
        headingBlock = block
        if let heading = self.heading {
            headingBlock!(heading)
        }
    }
    
    private var lat: Double? = nil
    private var lon: Double? = nil
    private var locationBlock: ((lat: Double, lon: Double)->())?
    func setLocationProcessBlock(block: (Double, Double)->()) {
        locationBlock = block
//        self.updateLocationAndStop = false
        if let lat = self.lat, let lon = self.lon {
            locationBlock!(lat: lat,lon: lon)
        }
    }
    
    func startUpdating() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager!.requestWhenInUseAuthorization()
        }else{
            startUpdatingHeading()
        }
    }
    
    func stopUpdating() {
        if isUpdating {
            isUpdating = false
            if CLLocationManager.headingAvailable() {
                locationManager?.stopUpdatingHeading()
            }
            locationManager?.stopUpdatingLocation()
        }
    }
    
    private var isUpdating = false
    private func startUpdatingHeading(){
        if !isUpdating {
            isUpdating = true
            if CLLocationManager.headingAvailable() {
                locationManager?.startUpdatingHeading()
            }
            locationManager?.startUpdatingLocation()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch (status) {
        case .NotDetermined:
            print("NotDetermined")
            startUpdating()
        case .Denied:
            print("Denied")
        case .AuthorizedWhenInUse:
            startUpdating()
        case .AuthorizedAlways:
            startUpdating()
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let rotation = newHeading.magneticHeading * M_PI / 180
        self.heading = rotation
        if headingBlock != nil {
            headingBlock!(rotation)
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last /*where locationBlock != nil*/ {
			self.lat = location.coordinate.latitude;
			self.lon = location.coordinate.longitude;
			if(locationBlock != nil){
				locationBlock!(lat: location.coordinate.latitude,lon: location.coordinate.longitude)
				if self.updateLocationAndStop {
					self.updateLocationAndStop = false
					self.updateLocation()
					self.stopUpdating()
				}
			}
        }
    }
}