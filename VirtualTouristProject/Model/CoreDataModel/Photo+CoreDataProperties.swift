//
//  Photo+CoreDataProperties.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/11/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var pin: Pin?

}
