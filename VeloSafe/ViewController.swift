//
//  ViewController.swift
//  VeloSafe
//
//  Created by Polina Guryeva on 23/10/2018.
//  Copyright © 2018 polinaguryeva. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController {

    var searchViewIsOpen = false
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var firstPointTextField: UITextField!
    @IBOutlet weak var secondPointTextField: UITextField!
    
    private var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func initView() {
        mapView.delegate = self
        
        searchView.layer.shadowColor = UIColor.lightGray.cgColor
        searchView.layer.shadowOpacity = 1.0
        searchView.layer.shadowOffset = .zero
        searchView.layer.shadowRadius = 3.0
        searchView.layer.masksToBounds = false
        
        searchView.frame.size.height = 128
        searchView.frame = CGRect(x: 0, y: -searchView.frame.size.height, width: view.frame.size.width, height: searchView.frame.size.height)
        view.addSubview(searchView)
    }

    @IBAction func changeTwoPoints(_ sender: Any) {
        guard let first = firstPointTextField.text,
            let second = secondPointTextField.text else {return}
        firstPointTextField.text = second
        secondPointTextField.text = first
    }
    
    @objc func moveSearchView() {
        UIView.animate(withDuration: 0.5) {
            if self.searchViewIsOpen {
                self.searchView.frame.origin.y = -self.searchView.frame.size.height
            } else {
                self.searchView.frame.origin.y = 0
            }
        }
        searchViewIsOpen = !searchViewIsOpen
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        mapView.camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {return}
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        moveSearchView()
        searchView.endEditing(true)
    }
}


