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
import  SWXMLHash

class MapViewController: UIViewController {
    
    // Private propertie
    
    private var searchViewIsOpen = false
    private var isGraphCreated = false
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var zoomLevel: Float = 15.0
    
    // Public properties
    
    var graph: StreetGraph!
    
    //MARK: - Outlets
    
    @IBOutlet private var searchView: UIView!
    @IBOutlet private weak var mapView: GMSMapView!
    
    @IBOutlet private weak var firstPointTextField: UITextField!
    @IBOutlet private weak var secondPointTextField: UITextField!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        initGraph()
    
    }
    
    //MARK: - Methods

    private func initView() {
        mapView.delegate = self
        
        searchView.layer.shadowColor = UIColor.lightGray.cgColor
        searchView.layer.shadowOpacity = 1.0
        searchView.layer.shadowOffset = .zero
        searchView.layer.shadowRadius = 3.0
        searchView.layer.masksToBounds = false
        
        searchView.frame.size.height = 144
        searchView.frame = CGRect(x: 0, y: -searchView.frame.size.height, width: view.frame.size.width, height: searchView.frame.size.height)
        view.addSubview(searchView)
    }
    
    private func initGraph() {
        let file =  NSDataAsset(name: "saintp")!
        let xml = SWXMLHash.parse(file.data)
        DispatchQueue.global().async {
            if let osm = try? OSM.init(xml: xml) {
                
                self.graph = StreetGraph(osm: osm)
                print(self.graph.bounds)
                self.isGraphCreated = true
                self.drawGraph()
                self.createAdjacencyMatrix()
            } else {
                DispatchQueue.main.async {
                    print("fail")
                }
            }
        }
    }
    
    private func createAdjacencyMatrix() {
        var matrix = [Segment : TurnDirection]()
        
        for node in self.graph.nodes.values {
            for adjacentNode in node.adjacent {
                for doubleAdjacentNode in adjacentNode.adjacent {
                    
//                    let path = GMSMutablePath()
//                    path.add(CLLocationCoordinate2D(latitude: node.location.latitude,
//                                                    longitude: node.location.longitude))
//
//                    path.add(CLLocationCoordinate2D(latitude: doubleAdjacentNode.location.latitude,
//                                                    longitude: doubleAdjacentNode.location.longitude))
//                    let polyline = GMSPolyline(path: path)
//                    polyline.strokeColor = .blue
//                    polyline.strokeWidth = 2.0
//                    polyline.geodesic = true
//                    polyline.map = mapView
                    
                    let d = (doubleAdjacentNode.location.latitude - node.location.latitude) * (adjacentNode.location.longitude - node.location.longitude) - (doubleAdjacentNode.location.longitude - node.location.longitude) * (adjacentNode.location.latitude - node.location.latitude)
                    let eps = 1e-10
                    print(d)
                    if (d < -eps) {
                        matrix[Segment(firstPointId: node.id, secondPointId: doubleAdjacentNode.id)] = .left
                    } else if (d > eps) {
                        matrix[Segment(firstPointId: node.id, secondPointId: doubleAdjacentNode.id)] = .right
                    } else {
                        matrix[Segment(firstPointId: node.id, secondPointId: doubleAdjacentNode.id)] = .none
                        
                    }
                }
            }
        }
        print("creating matrix done")
    }
    
    private func drawGraph() {
        for edge in graph.edgeList {
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2D(latitude: edge.from.location.latitude,
                                            longitude: edge.from.location.longitude))
            
            path.add(CLLocationCoordinate2D(latitude: edge.to.location.latitude,
                                            longitude: edge.to.location.longitude))
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .red
            polyline.strokeWidth = 2.0
            polyline.geodesic = true
            polyline.map = mapView
        }
        print("draw complete")
    }
    
    @objc private func moveSearchView() {
        UIView.animate(withDuration: 0.5) {
            if self.searchViewIsOpen {
                self.searchView.frame.origin.y = -self.searchView.frame.size.height
            } else {
                self.searchView.frame.origin.y = 0
            }
        }
        searchViewIsOpen = !searchViewIsOpen
    }

    // MARK: - Actions
    
    @IBAction func changeTwoPoints(_ sender: Any) {
        guard let first = firstPointTextField.text,
            let second = secondPointTextField.text else {return}
        firstPointTextField.text = second
        secondPointTextField.text = first
    }
    
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
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

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        moveSearchView()
        searchView.endEditing(true)
    }
}


