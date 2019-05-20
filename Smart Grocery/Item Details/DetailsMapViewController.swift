//
//  DetailsMapViewController.swift
//  Smart Grocery
//
//  Created by Eric Roca on 20/05/2019.
//  Copyright © 2019 Eric Roca. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailsMapViewController: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var mapView: GMSMapView!
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 16.0)
        mapView.camera = camera
        showMarker(position: camera.target)
    }
    
    //MARK: GMSMapView
    
    func showMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = position
        marker.title = "Palo Alto"
        marker.snippet = "San Francisco"
        marker.map = mapView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
