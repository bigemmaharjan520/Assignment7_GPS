//
//  ViewController.swift
//  BigemMaharjan_Assignment7_GPS
//
//  Created by user240741 on 3/13/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
  //Top bar that shows the red color once the user exists the speed limit of 115 km/hr
    @IBOutlet weak var topBarRedView: UIView!
    
    //Bottom bar that shows gray in color but changes once the user starts the strip
    @IBOutlet weak var grayGreenBotBar: UIView!
    
    //Current speed label
    @IBOutlet weak var currentSpeed: UILabel!
    
    //Max speed
    @IBOutlet weak var maxSpeed: UILabel!
    
    //Average Speed
    @IBOutlet weak var averageSpeed: UILabel!
    
    //Distance
    @IBOutlet weak var distance: UILabel!
    
    //Max Acceleration
    @IBOutlet weak var maxAcceleration: UILabel!
    
    //Map View
    @IBOutlet weak var mapView: MKMapView!
    
    //creating variable for location manager
     var locationManager: CLLocationManager!
    
    //user start location
     var userStartLocation: CLLocation?
    
    //user last location
     var userLastLocation: CLLocation?
    
    // Initialize maximum speed
    var maxSpeedCal: CLLocationSpeed = 0.0
    
    // calculating distance travelled
     var distanceTravelled: CLLocationDistance = 0.0
    
    //maximum accelerator that the user has accelerated
     var maximumAcceleration: CLLocationSpeed = 0.0
    
    //user start trip time
     var userTripStartTime: Date?
    
    //user end trip time
     var userTripEndTime: Date?
    
    //total speed
     var totalSpeed: CLLocationSpeed = 0.0
    
    //reading of user speed
     var userSpeedReadings: Int = 0
    
    //boolean to upade the location
     var isUpdatingLocation: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //asking for user permission to get access to location
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
    }
    
       
    //Start trip button
    @IBAction func startTrip(_ sender: Any) {
        //updating the location of the user as it moves
        locationManager.startUpdatingLocation()
        
        //setting the bar as green color as user starts the trip
        grayGreenBotBar.backgroundColor = .green
        
        //getting datetime of user starting trip time
          userTripStartTime = Date()
        
        //showing user location in map
        mapView.showsUserLocation = true
        
        //tracking the user movement and following
        mapView.setUserTrackingMode(.follow, animated: true)
        
        //updating the location in map of the user
          isUpdatingLocation = true
    }
    
       
    //Stop trip button It will stop sending the user location
    @IBAction func stopTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        
        //getting end time of user trip
               userTripEndTime = Date()
        
        //setting the bar as gray as it should be once the user stops or end trip
        grayGreenBotBar.backgroundColor = .systemGray
        
        //setting all the other features to Zero as user stops the trip
        currentSpeed.text = "0.00 km/h"
               maxSpeed.text = "0.00 km/h"
               averageSpeed.text = "0.00 km/h"
               distance.text = "0.00 km"
               maxAcceleration.text = "0.00 m/s²"
               mapView.showsUserLocation = false
               mapView.setUserTrackingMode(.none, animated: true)
        
        //stoping the update of location
        isUpdatingLocation = false
    }
    
    
    
    // Function that displays the speed of the user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isUpdatingLocation, let liveLocation = locations.last
        else {
            return
        }
        
        //Calculating the current speed of user
        let latestSpeed = liveLocation.speed
              currentSpeed.text = String(format: "%.1f km/h", abs(latestSpeed) * 3.6)
              if(abs(latestSpeed)*3.6) >= 120{
                  topBarRedView.backgroundColor = .red
                  topBarRedView.alpha = 1
                              }else{
                                  topBarRedView.alpha = 0
                                  topBarRedView.backgroundColor = .white
                              }
        
        
        //Calculating the maximum speed of the user
              if latestSpeed > maxSpeedCal {
                  maxSpeedCal = latestSpeed
                  maxSpeed.text = String(format: "%.1f km/h", abs(maxSpeedCal) * 3.6)
              }
        
        //Calculating the average speed
        totalSpeed += latestSpeed
               userSpeedReadings += 1
               let averageSpeedCal = totalSpeed / Double(userSpeedReadings)
               averageSpeed.text = String(format: "%.1f km/h", abs(averageSpeedCal) * 3.6)
        
        //calculating distance travelled and maximum acceleration
        if let userLastLocation = userLastLocation {
                   let distanceIncrement = liveLocation.distance(from: userLastLocation)
            distanceTravelled += distanceIncrement
                   distance.text = String(format: "%.2f km", distanceTravelled / 1000)
                   
                   let timeIncrement = liveLocation.timestamp.timeIntervalSince(userLastLocation.timestamp)
                   maximumAcceleration = (latestSpeed - userLastLocation.speed) / timeIncrement
                   maxAcceleration.text = String(format: "%.1f m/s²", abs(maximumAcceleration))
               }
        
        userLastLocation = liveLocation
            
            // Updating map to display location of user with zoom in
            mapView.setCenter(liveLocation.coordinate, animated: true)
            let region = MKCoordinateRegion(center: liveLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
        
    }
    
    //Function to calculate the average speed, speed exceed and distance to exceed speed limit at last
    func distanceCalculationToSpeedLimitExceed() -> CLLocationDistance {
           let speedLimit = 115.0 // km/h
           let averageSpeed = totalSpeed / Double(userSpeedReadings)
           let timeToExceedLimit = (speedLimit / (averageSpeed * 3.6))
           let distanceToExceedLimit = timeToExceedLimit * maxSpeedCal * 3.6 * 1000
           return distanceToExceedLimit
       }
    
    


}

