//
//  FlickrClient.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/13/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    // shared session
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(parameters: [String:AnyObject]?, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url:  flickrURLFromParameters(parameters!))
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error!.localizedDescription))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response?  */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: JSON Conversion
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
        
        
    // MARK: Create a URL from parameters
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrConstants.URL.ApiScheme
        components.host = FlickrConstants.URL.ApiHost
        components.path = FlickrConstants.URL.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
        
    }
    
    // Take results from Flickr and return Array of URLs, checking to make sure there aren't any nil values
    
    func createPhotoArray(result: [[String:AnyObject]]) -> [URL] {
        
        var arrayOfPhotos = [] as [URL]
        
        for result in result {
            
            if (result[FlickrConstants.JSONResponseKeys.Image] as? String) != nil {
                
                if let imageURL = URL(string: result[FlickrConstants.JSONResponseKeys.Image] as! String) {
                    
                    arrayOfPhotos.append(imageURL)
                }
            }
        }
        
        return arrayOfPhotos
    }

        
    // Create a singleton to access it easily
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
        
    }

