//
//  FlickrConstants.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/13/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

struct FlickrConstants {
    
    struct URL {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }
    
    struct ParameterKeys {
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let RadiusUnits = "radius_units"
        static let Extras = "extras"
        static let APIKey = "api_key"
        static let Method = "method"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
        
    }
    
    struct ParameterValues {
        static let Radius = "5"
        static let RadiusUnits = "mi"
        static let MediumURL = "url_m"
        static let APIKey = "DUMMY_API_KEY"
        static let PhotoSearchMethod = "flickr.photos.search"
        static let ResponseFormat = "json"
        static let DisableJSONCallBack = "1" //1 means yes
        static let PerPage = "20"
        
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Image = "url_m"
        static let Pages = "pages"
    }
    
}

