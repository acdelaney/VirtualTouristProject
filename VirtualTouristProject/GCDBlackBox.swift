//
//  GCDBlackBox.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 12/10/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import Foundation

// To perform updates on the main thread

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
