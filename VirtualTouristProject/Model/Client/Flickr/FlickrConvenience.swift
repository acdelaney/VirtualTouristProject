//
//  FlickrConvenience.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/13/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import Foundation
import UIKit


extension FlickrClient {
    
    
    // Gets the photos from Flickr for Latitude and Longitude and parses the JSON into usable format.
    
    func getFlickrPhotos(latitude: String!, longitude: String!, randomPage: UInt32!, completionHandlerForFlickrPhotos: @escaping (_ result: [[String:AnyObject]]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, adding Latitude and Longitude */
        
        var parameters = [FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.PhotoSearchMethod,  FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey, FlickrConstants.ParameterKeys.Radius: FlickrConstants.ParameterValues.Radius, FlickrConstants.ParameterKeys.RadiusUnits: FlickrConstants.ParameterValues.RadiusUnits, FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL, FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat, FlickrConstants.ParameterKeys.NoJSONCallBack: FlickrConstants.ParameterValues.DisableJSONCallBack, FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.PerPage]
        
        parameters[FlickrConstants.ParameterKeys.Latitude] = latitude
        parameters[FlickrConstants.ParameterKeys.Longitude] = longitude
        parameters[FlickrConstants.ParameterKeys.Page] = String(randomPage)
       
        
        /* 2. Make the request */
        let _ = taskForGETMethod(parameters: parameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFlickrPhotos(nil, error)
            } else {
                
               
                if let photoDictionary = results?["\(FlickrConstants.JSONResponseKeys.Photos)"] as? [String:AnyObject] {
                    
                    let photoArray = photoDictionary["\(FlickrConstants.JSONResponseKeys.Photo)"] as! [[String:AnyObject]]
                    
                    completionHandlerForFlickrPhotos(photoArray, nil)
                    
                } else {
                    completionHandlerForFlickrPhotos(nil, NSError(domain: "getFlickrPhotos parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFlickrPhotos"]))
                }
            }
        }
        
    }
    
    // Gets the a random page from Flickr for Latitude and Longitude and parses the JSON into usable format.
    
    func getRandomFlickrPage(latitude: String!, longitude: String!, completionHandlerForFlickrPhotos: @escaping (_ result: UInt32?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, adding Latitude and Longitude */
        
        var parameters = [FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.PhotoSearchMethod,  FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey, FlickrConstants.ParameterKeys.Radius: FlickrConstants.ParameterValues.Radius, FlickrConstants.ParameterKeys.RadiusUnits: FlickrConstants.ParameterValues.RadiusUnits, FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL, FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat, FlickrConstants.ParameterKeys.NoJSONCallBack: FlickrConstants.ParameterValues.DisableJSONCallBack, FlickrConstants.ParameterKeys.PerPage: FlickrConstants.ParameterValues.PerPage]
        
        parameters[FlickrConstants.ParameterKeys.Latitude] = latitude
        parameters[FlickrConstants.ParameterKeys.Longitude] = longitude
        
        
        /* 2. Make the request */
        let _ = taskForGETMethod(parameters: parameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFlickrPhotos(nil, error)
            } else {
                
                // Select a random page number and return it to be used in get flickr photos function
                
                if let photoDictionary = results?["\(FlickrConstants.JSONResponseKeys.Photos)"] as? [String:AnyObject] {
                    
                    if let photoPages = photoDictionary["\(FlickrConstants.JSONResponseKeys.Pages)"] as? UInt32 {
                        
                        let intPerPage = Int(FlickrConstants.ParameterValues.PerPage)
                        
                        let availablePages = min(4000/intPerPage!, Int(photoPages))
                        
                        let randomPage = arc4random_uniform(UInt32(availablePages)) + 1
                        
                        completionHandlerForFlickrPhotos(randomPage, nil)
                        
                    } else {
                        
                        completionHandlerForFlickrPhotos(nil, NSError(domain: "getFlickrPhotos parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Page Number"]))
                        
                    }
                    
                } else {
                    completionHandlerForFlickrPhotos(nil, NSError(domain: "getFlickrPhotos parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse Random Page Number"]))
                }
            }
        }
        
    }
    
    
}
