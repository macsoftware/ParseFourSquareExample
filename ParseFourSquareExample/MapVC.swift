//
//  MapVC.swift
//  ParseFourSquareExample
//
//  Created by Ian MacKinnon on 23/01/2023.
//

import UIKit
import MapKit
import Parse

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelButtonClicked))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonClicked))
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecogniser:)))
        gestureRecogniser.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecogniser)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locationManager.startUpdatingLocation()
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func chooseLocation(gestureRecogniser: UIGestureRecognizer){
        
        if gestureRecogniser.state == UIGestureRecognizer.State.began{
            
            let touches = gestureRecogniser.location(in: self.mapView)
            let coords = self.mapView.convert(touches, toCoordinateFrom: self.mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coords
            annotation.title = PlaceModel.sharedInstance.placeName
            annotation.subtitle = PlaceModel.sharedInstance.placeType
            self.mapView.addAnnotation(annotation)
            
            PlaceModel.sharedInstance.placeLatitude = String(coords.latitude)
            PlaceModel.sharedInstance.placeLongitude = String(coords.longitude)
        }
        
    }
    
    @objc func cancelButtonClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func saveButtonClicked(){

        let obj = PFObject(className: "Places")
        obj["name"] = PlaceModel.sharedInstance.placeName
        obj["type"] = PlaceModel.sharedInstance.placeType
        obj["atmosphere"] = PlaceModel.sharedInstance.placeAtmosphere
        obj["latitude"] = PlaceModel.sharedInstance.placeLatitude
        obj["longitude"] = PlaceModel.sharedInstance.placeLongitude
        
        if let imageData = PlaceModel.sharedInstance.placeImage.jpegData(compressionQuality: 0.5){
            obj["image"] = PFFileObject(name: "image.jpg", data: imageData)
        }
        
        obj.saveInBackground{ success, error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                    alert.addAction(okButton)
                    self.present(alert, animated: true)
            }else{
                self.performSegue(withIdentifier: "fromMapVCtoPlacesVC", sender: nil)
            }
            
        }
            
    }

}
