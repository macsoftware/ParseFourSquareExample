//
//  MapVC.swift
//  ParseFourSquareExample
//
//  Created by Ian MacKinnon on 23/01/2023.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelButtonClicked))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonClicked))
    }
    
    @objc func cancelButtonClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func saveButtonClicked(){
        
    }

}
