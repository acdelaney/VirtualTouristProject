# VirtualTouristProject

The Virtual Tourist is a fun portfolio app where the user can add pins to a map and download images from Flickr that are associated with that location.

## Installation

```
git clone https://github.com/acdelaney/VirtualTouristProject.git
```

## Usage

On launch, the app opens to a map and displays previously add pins.  Using a long press gesture, the user can drop pins on specific locations that he or she is interested in traveling to.  Tapping a pin will navigate to the Photo Album view controller.  The first time a pin is selected photos associated with that geolocation are downloaded from Flickr and added to the collection view.  Photos appear with a placeholder image until the image from Flickr is fully downloaded.  Selecting an image removes it from the collection view, allowing the user to curate the view.  Selecting the tool bar button New Collection initiates another download from Flickr and replaces the current collection of photos.  All pins and associated photos are stored in a persistent Core Data model.
