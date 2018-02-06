//
//  PhotoAlbumVC.swift
//  VirtualTouristProject
//
//  Created by Andrew Delaney on 11/14/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

    // MARK: - Instance Variables
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = { () -> NSFetchedResultsController<Photo> in
        
        let stack = delegate.stack
        
        let fetchRequest = NSFetchRequest<Photo>(entityName: "Photo")
        
        fetchRequest.sortDescriptors = []
        
        let photoPred = NSPredicate(format: "pin == %@", argumentArray: pin)
        
        fetchRequest.predicate = photoPred
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        print("fetchresult called")
        return fetchedResultsController
    }()
    
    
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    // Variables for map and download functions
    var selectedPin = MKAnnotationView()
    var pin: [Pin] = []
    
    // Get the AppDelegate for the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var selectedPinMapView: MKMapView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        // Set delegates for map and collection view
        selectedPinMapView.delegate = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        // Set region and add pin to the map
        let mapRegion = MKCoordinateRegionMake((selectedPin.annotation?.coordinate)!, MKCoordinateSpanMake(0.5, 0.5) )
        selectedPinMapView.addAnnotation(selectedPin.annotation!)
        selectedPinMapView.setRegion(mapRegion, animated: true)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Hide activity indicator
        downloadIndicator.isHidden = true
        
        // Perform initial fetch
        executeSearch()
        
        // If there are no photos, then download from flickr
        if fetchedResultsController.fetchedObjects?.count == 0{
            print("download Flickr Called!")
            downLoadFlickrPhotos()
        }
        
        super.viewWillAppear(animated)
    }
    
    // Layout the collection view
    
    override func viewDidLayoutSubviews() {
       
        super.viewDidLayoutSubviews()
        
        // Layout the collection view so that cells take up 1/3 of the width,
        // with no space in-between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let space:CGFloat = 1.0
        
        //Show three cells across for all orientations
        
        let width = (UIScreen.main.bounds.width - (2 * space)) / 3.0
        
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: width, height: width)
        photoCollectionView.collectionViewLayout = layout
    }


    // Back button to go back to Location View
    
    @IBAction func backToMap(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // Load New Collection.  Delete existing photo objects, and initiate new download from Flickr.
    
    @IBAction func loadNewCollection(_ sender: Any) {
        
        let stack = delegate.stack

        // Delete existing photos
        
        for photo in fetchedResultsController.fetchedObjects!{
            stack.context.delete(photo)
        }
        
        // Download new photos
        
        downLoadFlickrPhotos()
    }
    
    // Download new Photos from Flickr
    
    func downLoadFlickrPhotos() {
        
        // Disable button, start activity indicator to show download in progress
        
        configureForDownload(update: false)
        downloadIndicator.startAnimating()
        
        // Grab the pin coordinates as Strings to use for Flickr Client
        
        let pinAnnotation = selectedPin.annotation
        let latitude = String(pinAnnotation!.coordinate.latitude)
        let longitude = String(pinAnnotation!.coordinate.longitude)
        
        
        // Get a random page from Flickr
        
        FlickrClient.sharedInstance().getRandomFlickrPage(latitude: latitude, longitude: longitude, completionHandlerForFlickrPhotos: { (result, error) in
            var arrayOfPhotos = [] as [URL]
            
            if let result = result {
                
                let randomPage = result
                
                // Flickr client that grabs photos using latitude and longitude coordinates
                
                FlickrClient.sharedInstance().getFlickrPhotos(latitude: latitude, longitude: longitude, randomPage: randomPage, completionHandlerForFlickrPhotos: {result, error in
                    
                    // Take Results and return array of URLs without any nil values
                    
                    if let result = result {
                        
                        arrayOfPhotos = FlickrClient.sharedInstance().createPhotoArray(result: result)
                        
                    } else {
                        
                        self.showAlert("No Results returned." , "\(String(describing: error!.localizedDescription))")
                    }
                    
                    print("Photos downloaded!")
                    
                    // Check to see if any photos are at the location.  If not, display an alert.  If there are photos then create Photo Entities and begin downloading images
                    
                    if arrayOfPhotos.isEmpty == true{
                        
                        performUIUpdatesOnMain {
                            
                            self.configureForDownload(update: true)
                            self.downloadIndicator.stopAnimating()
                            self.showAlert("No Flickr Photos", "No Photos at this Location!")
                            
                        }
                    
                    } else {
                        
                        self.convertToPhotoEntity(photoURLArray: arrayOfPhotos, pinArray: self.pin)
                        
                    }
                })
                
            } else {
                
                performUIUpdatesOnMain {
                    
                    self.configureForDownload(update: true)
                    self.downloadIndicator.stopAnimating()
                    self.showAlert("No Results returned." , "\(String(describing: error!.localizedDescription))")
                }
            }
        })
    }
    
    // Configure activity indicator and new collection button for download
    
    func configureForDownload(update: Bool) {
        newCollectionButton.isEnabled = update
        downloadIndicator.isHidden = update
    }
    
    // Take array of URLs and a Pin and create Photo Entities.  First quickly create a placeholder image and then as images download, replace them.  The fetchedresultscontroller will update the placeholders as they download.
    
    
    func convertToPhotoEntity(photoURLArray: [URL], pinArray: [Pin]) {
        
        let stack = delegate.stack
        var arrayOfDownloadedPhotos: [Photo] = []
        
        // Create the Photo and use a placeholder.  Then store them in an Array of Photo Entities.
        
        stack.performBackgroundBatchOperation { (workercontext) in
            
            
            for _ in photoURLArray {
                
                let placerHolder = UIImageJPEGRepresentation(#imageLiteral(resourceName: "imageHolder"), 1.0)
                
                let photoImage = Photo(image: placerHolder! as NSData, context: workercontext)
                
                let pinObjectID = pinArray[0].objectID
                
                let pinCopy = workercontext.object(with: pinObjectID)
                
                photoImage.pin = (pinCopy as! Pin)
                
                print("placeholder made")
                
                arrayOfDownloadedPhotos.append(photoImage)
            }
            
            self.saveContextHelper(context: workercontext)
            
            // Get the last index of the Photo Entities Array so that each Photo can be updated with an image.  Since the only property of the Photo is an image, it doesn't matter in what order they are updated with a downloaded image.
            
            let lastIndex = arrayOfDownloadedPhotos.count - 1
            
            for i in 0...lastIndex {
                
                let photoToDownload = photoURLArray[i]
                let photoEntity = arrayOfDownloadedPhotos[i]
                
                if let imageData = try? Data(contentsOf: photoToDownload){
                    
                    photoEntity.imageData = imageData as NSData
                    
                    print(i)
                    
                    self.saveContextHelper(context: workercontext)
                }
            }
            
            //When the download is complete, hide activity indicator and enable new collection button
            
            performUIUpdatesOnMain {
                
                print("All Photos Made!")
                
                self.configureForDownload(update: true)
                self.downloadIndicator.stopAnimating()
 
            }
            
        }
       
    }

    
    // MARK: Mapview Delegate
    
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
    
    
    // MARK: Core Data Collection View Datasource
    
    // Set cell image to Photo Entity image and set to scale aspect fill
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoImage", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        cell.FlickrPhoto.image =  UIImage(data: photo.imageData! as Data)
        cell.FlickrPhoto.contentMode = .scaleAspectFill
        
        return cell
    }
    
    // MARK: Core Data Collection View Delegate
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
    
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    // Delete Photo from core data when selected
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let stack = delegate.stack
        stack.context.delete(fetchedResultsController.object(at: indexPath))
        stack.save()
    }


// MARK: - CoreData Collection View (Fetches)

    func executeSearch() {
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
            
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
    


// MARK: - CoreData NSFetchedResultsControllerDelegate

    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
       
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      
        switch(type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
        case .delete:
            deletedIndexPaths.append(indexPath!)
        case .update:
            updatedIndexPaths.append(indexPath!)
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        photoCollectionView.performBatchUpdates({() -> Void in
           
            for indexPath in insertedIndexPaths {
                photoCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in deletedIndexPaths {
                photoCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in updatedIndexPaths {
                photoCollectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
    
}




