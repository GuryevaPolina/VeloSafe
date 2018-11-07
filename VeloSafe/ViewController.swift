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

    let apiKey = "AIzaSyAQvGWJxMwv71xV8WvbvSSZk25E_uoqPEY"
    
    var searchViewIsOpen = false
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var graph: [Int: GeoPoint] = [:]
    
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
        drawBasicGraph()
    }
    
    func drawPath(from gp1: GeoPoint, to gp2: GeoPoint) {
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(gp1.latitude),\(gp1.longitude)&destination=\(gp2.latitude),\(gp2.longitude)&sensor=false&key=\(apiKey)"
        let urlRequest = URLRequest(url: URL(string: url)!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options:[]) as? [String: Any] else {
                    print("[drawPath] json error")
                    return
                }
                print(json)
                guard let routes = json["routes"] as? [[String: Any]] else {
                    print("[drawPath] routes error")
                    return
                }
                for route in routes {
                    guard let overviewPolyline = route["overview_polyline"] as? [String: Any] else {
                        print("[drawPath] overview error")
                        return
                    }
                    guard let points = overviewPolyline["points"] as? String else {
                        print("[drawPath] points error")
                        return
                    }
                    let path = GMSPath(fromEncodedPath: points)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 4.0
                    polyline.strokeColor = .red
                    polyline.map = self.mapView
                }
            }
            catch {
                print("json error")
            }
        }
        task.resume()
    }
    
    func drawBasicGraph() {
        drawPath(from: graph[0]!, to: graph[1]!)
        drawPath(from: graph[1]!, to: graph[4]!)
      //  drawPath(from: graph[0]!, to: graph[3]!)
      //  drawPath(from: graph[3]!, to: graph[1]!)
      //  drawPath(from: graph[1]!, to: graph[4]!)
     //   drawPath(from: graph[4]!, to: graph[5]!)
      //  drawPath(from: graph[5]!, to: graph[6]!)
     //   drawPath(from: graph[6]!, to: graph[1]!)
    }
    
    func initView() {
        mapView.delegate = self
        
        searchView.layer.shadowColor = UIColor.lightGray.cgColor
        searchView.layer.shadowOpacity = 1.0
        searchView.layer.shadowOffset = .zero
        searchView.layer.shadowRadius = 3.0
        searchView.layer.masksToBounds = false
        
        searchView.frame.size.height = 144
        searchView.frame = CGRect(x: 0, y: -searchView.frame.size.height, width: view.frame.size.width, height: searchView.frame.size.height)
        view.addSubview(searchView)
        
        guard let path = Bundle.main.path(forResource: "graph.txt", ofType: nil) else {
            print("[initView] path is not found")
            return
        }
        
        let (res, error) = GraphParser.parseGraphFromFile(withPath: path)
        if error == nil {
            graph = res
        }
        
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


