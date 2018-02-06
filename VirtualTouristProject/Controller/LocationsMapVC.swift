//
//  ViewController.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/10/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsMapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationsMapView: MKMapView!
    
    // Get the AppDelegate for the Stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var pins: [Pin] = []
    
    var tappedPin = MKAnnotationView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Map delegate
        
        locationsMapView.delegate = self
        
        // Load locations from Core Data and set to pins
        
        loadLocations()
        
        // Turn Pin Entities into annotations for the map and add them
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            
            let lat = pin.latitude
            let long = pin.longitude
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate property
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // Add all the annotations onto the map
        locationsMapView.addAnnotations(annotations)
    }
    
    // Drop a new pin on the map with a long gesture.  Drop the Pin after the gesture ends.  Create a Pin entity based on the location of the long press.
    
    @IBAction func addNewPin(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            let touchLocation = sender.location(in: locationsMapView)
            
            let locationCoordinate = locationsMapView.convert(touchLocation, toCoordinateFrom: locationsMapView)
            
            let stack = delegate.stack
            
            Pin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, context: stack.context )
            
            stack.save()
            
            print("Pin Saved")
            
            //Add location of touch to map as a Pin annotation.
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = locationCoordinate
            
            locationsMapView.addAnnotation(annotation)
        }
    }

    // Fetch existing Pins from Core Data and set them equal to pin Array.
    
    func loadLocations() {
        
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),
                              NSSortDescriptor(key: "createDate", ascending: false)]
        
        do {
            pins = try stack.context.fetch(fr) as! [Pin]
            print("Pins loaded!")
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
  
    // Prepare for seque by injecting the tapped pin into the PhotoAlbum VC so it can be used in the fetchedresultscontroller
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "pinTapped" {
            
            if let PhotoAlbumVC = segue.destination as? PhotoAlbumVC {
                
                PhotoAlbumVC.selectedPin = tappedPin
                
                grabSelectedPinEntity(pin: tappedPin, viewController: PhotoAlbumVC)
            }
        }
    }
    
    //MARK: MapView Delegate
    
    // Set pin to red and animate drop
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // When pin is tapped navigate to the PhotoAlbum VC, then deselect tapped pin so it can be selected again later.
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
        tappedPin = view
        performSegue(withIdentifier: "pinTapped", sender: self)
        mapView.deselectAnnotation(tappedPin.annotation, animated: false)
    }
    
    // Take tapped pin annotation and fetch the associated Pin Entity based on the coordinates.  Then inject it into the PhotoAlbumVC to be used by the fetchedresultscontroller.
    
    func grabSelectedPinEntity(pin: MKAnnotationView, viewController: PhotoAlbumVC) {
        
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<Pin>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false),
                              NSSortDescriptor(key: "createDate", ascending: false)]
        
        let latitude = pin.annotation?.coordinate.latitude
        let longitude = pin.annotation?.coordinate.longitude
        
        let pinPred = NSPredicate(format: "abs(latitude - %f) < 0.0001 && abs(longitude - %f) < 0.0001", latitude!, longitude!)
        
        fr.predicate = pinPred
        
        do {
            viewController.pin = try stack.context.fetch(fr)
            print("Pin Predicate Fetched!")
            
        } catch let error as NSError {
            
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}




