//
//  Pin+CoreDataClass.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/11/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData

//@objc(Pin)
public class Pin: NSManagedObject {

    // MARK: Initializer
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.createDate = NSDate()
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
   
    
}
