//
//  HelperFunctions.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 1/23/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    
    
    // Used to display an alert controller
    
    func showAlert (_ title: String, _ message: String) -> () {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveContextHelper(context: NSManagedObjectContext) {
        
        // Save it to the parent context, so normal saving
        // can work
        do {
            try context.save()
            
        } catch {
            fatalError("Error while saving backgroundContext: \(error)")
        }
        
    }
    
    
}
