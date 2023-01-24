//
//  DetailsVC.swift
//  ParseFourSquareExample
//
//  Created by Ian MacKinnon on 23/01/2023.
//

import UIKit
import MapKit
import Parse

class DetailsVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var atmosphereLabel: UILabel!
    
    var chosenPlaceId = ""
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    @IBOutlet weak var detailsMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getDataFromParse()
        detailsMapView.delegate = self
    }
    
    func getDataFromParse(){
        let query = PFQuery(className: "Places")
        query.whereKey("objectId", equalTo: chosenPlaceId)
        query.findObjectsInBackground{ objects, error in
            if error != nil {
                self.makeAlert(inputTitle: "Error", inputMessage: error?.localizedDescription ?? "Error")
            }else{
                if objects != nil {
                    if objects!.count > 0 {
                        let obj = objects![0]
                        if let placeName = obj.object(forKey: "name") as? String{
                            self.placeNameLabel.text = placeName
                        }
                        if let placeType = obj.object(forKey: "type") as? String{
                            self.placeTypeLabel.text = placeType
                        }
                        if let placeAtmosphere = obj.object(forKey: "atmosphere") as? String{
                            self.atmosphereLabel.text = placeAtmosphere
                        }
                        if let placeLatitude = obj.object(forKey: "latitude") as? String{
                            if let doub = Double(placeLatitude){
                                self.chosenLatitude = doub
                            }
                        }
                        if let placeLongitude = obj.object(forKey: "longitude") as? String{
                            if let doub = Double(placeLongitude){
                                self.chosenLongitude = doub
                            }
                        }
                        if let imageData = obj.object(forKey: "image") as? PFFileObject {
                            imageData.getDataInBackground{ data, error in
                                if error == nil {
                                    if data != nil {
                                        self.imageView.image = UIImage(data: data!)
                                    }
                                }
                                
                            }
                        }
                        
                        // maps
                        let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        let region = MKCoordinateRegion(center: location, span: span)
                        self.detailsMapView.setRegion(region, animated: true)
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = self.placeNameLabel.text!
                        annotation.subtitle = self.placeTypeLabel.text!
                        self.detailsMapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }

    func makeAlert(inputTitle: String, inputMessage: String){
        let alert = UIAlertController(title: inputTitle, message: inputMessage, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenLongitude != 0.0 && self.chosenLatitude != 0.0{
            let requestLocation = CLLocation(latitude: chosenLatitude, longitude: chosenLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                
                if let pms = placemarks {
                    if pms.count > 0 {
                        let mkPlaceMark = MKPlacemark(placemark: pms[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.placeNameLabel.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
                
            }
        }
    }

}
