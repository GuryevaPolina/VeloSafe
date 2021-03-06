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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !(firstPointTextField.text?.isEmpty ?? true) &&
            !(secondPointTextField.text?.isEmpty ?? true) {
            
//            self.searchPath(from: graph.nodes["5043641714"]!,
//                            to: graph.nodes["25896553"]!)
        }
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
        
        firstPointTextField.addTarget(self, action: #selector(showStreetList(for:)), for: .editingDidBegin)
        secondPointTextField.addTarget(self, action: #selector(showStreetList(for:)), for: .editingDidBegin)
    }
    
    private func initGraph() {
        let file =  NSDataAsset(name: "saintp")!
        let xml = SWXMLHash.parse(file.data)
        DispatchQueue.main.async {
            if let osm = try? OSM(xml: xml){
                self.graph = StreetGraph(osm: osm)
                self.isGraphCreated = true
              //  self.drawGraph()
                self.createAdjacencyMatrix()
            } else {
                DispatchQueue.main.async {
                    print("fail")
                }
            }
        }
    }
    
    @objc private func showStreetList(for textField: UITextField) {
        let vc = UIStoryboard(name: "Streets", bundle: nil).instantiateViewController(withIdentifier: "streetsVC") as! StreetsViewController
        vc.streets = graph.streets
        vc.editedTextField = textField
        present(vc, animated: false, completion: nil)
    }
    
    private func createAdjacencyMatrix() {
        var matrix = [Segment : TurnDirection]()
        
        for node in self.graph.nodes.values {
            for adjacentNode in node.adjacent {
                for doubleAdjacentNode in adjacentNode.adjacent {
                    
                    let d = (doubleAdjacentNode.location.latitude - node.location.latitude) * (adjacentNode.location.longitude - node.location.longitude) - (doubleAdjacentNode.location.longitude - node.location.longitude) * (adjacentNode.location.latitude - node.location.latitude)
                    let eps = 1e-7
                  //  print(d)
                    if (d < -eps) {
                        matrix[Segment(from: node, to: doubleAdjacentNode)] = .left
                    } else if (d > eps) {
                        matrix[Segment(from: node, to: doubleAdjacentNode)] = .right
                    } else {
                        matrix[Segment(from: node, to: doubleAdjacentNode)] = .none
                        
                    }
                }
            }
        }
        graph.turnDirectionTable = matrix
        print("creating matrix done")
//        self.searchPath(from: graph.nodes["207365354"]!,
//                        to: graph.nodes["4694255902"]!)
//        self.searchPath(from: graph.nodes["5043641714"]!,
//                        to: graph.nodes["25896553"]!)
        
        searchPath()
    }
    
    
    
    @objc private func moveSearchView() {
        UIView.animate(withDuration: 0.5) {
            self.searchView.frame.origin.y = self.searchViewIsOpen ? -self.searchView.frame.size.height : -16
        }
        searchViewIsOpen = !searchViewIsOpen
    }

    //MARK: - Actions
    @IBAction private func changeTwoPoints(_ sender: Any) {
        guard let first = firstPointTextField.text,
            let second = secondPointTextField.text else {return}
        firstPointTextField.text = second
        secondPointTextField.text = first
        
//        if first.contains("Политех") {
//            self.searchPath(from: graph.nodes["5043641714"]!,
//                            to: graph.nodes["25896553"]!)
//        } else {
//            self.searchPath(from: graph.nodes["25896553"]!,
//                            to: graph.nodes["5043641714"]!)
//        }
    }
    
}

// drawing
extension MapViewController {
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
    
 //   private func searchPath(from: OSMNode, to: OSMNode) {
    private func searchPath() {
    //    var count = 0
    //    let start = DispatchTime.now()
        var values = [OSMNode]()
        for node in graph.nodes.values {
            values.append(node)
        }
        
        let N = 1000
        for _ in 0..<N {
            let from = values[Int.random(in: 0..<values.count)]
            let to = values[Int.random(in: 0..<values.count)]
            let pathFinder = AStarPathfinder(graph)
            let (path, n) = pathFinder.searchPath(from: from, to: to)
         //  drawPath(path: path)
            
            print("\(pathDistance(path)) - \(turnsCount(path))")
         //   count += n
        }
        
//        for value in values {
//            if value.adjacent.count > 2 {
//                drawPoint(value, color: .red)
//            }
//        }
    
      //  let end = DispatchTime.now()
        // print("TIME: \((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000)")
        //  print("COUNT: \(count / N) / \(graph.nodes.count)")
//        drawPath(path: path)
//        print(pathDistance(path))
    }
    
    private func turnsCount(_ path: [OSMNode]) -> Int {
        var k = 0
        for (i, node) in path.enumerated() {
            if node.adjacent.count > 2 {
                var p = 0.0
                if i != 0 && i != path.count - 1 {
                    let a = (path[i + 1].location.latitude - path[i - 1].location.latitude)
                    let b = (node.location.longitude - path[i - 1].location.longitude)
                    let c = (path[i+1].location.longitude - path[i - 1].location.longitude)
                    let d = (node.location.latitude - path[i - 1].location.latitude)
                    p = a * b - c * d
                }

                if p < 0 {
                    k += 1
                }
            }
        }
        return k
    }
    
    private func pathDistance(_ path: [OSMNode]) -> Int {
        var distance = 0.0
        if path.count == 0 {
            return 0
        }
        for i in 0..<(path.count - 1) {
            distance += path[i].distance(to: path[i + 1])
        }
        return Int(distance)
    }
    
    private func drawPoint(_ point: OSMNode, color: UIColor) {
        let center = CLLocationCoordinate2D(latitude: point.location.latitude,
                                            longitude: point.location.longitude)
        
        let circle = GMSCircle(position: center, radius: 10)
        circle.fillColor = color
        circle.strokeColor = color
        circle.map = mapView
    }
    
    private func drawPath(path pathForDraw: [OSMNode]) {
        //mapView.clear()
        let path = GMSMutablePath()
        
        for node in pathForDraw {
            path.add(CLLocationCoordinate2D(latitude: node.location.latitude,
                                            longitude: node.location.longitude))
        }
        
        let colors = [UIColor.cyan, UIColor.blue, UIColor.yellow, UIColor.black, UIColor.brown]
        
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = colors[Int.random(in: 0..<colors.count)]
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = mapView
        
        drawPoint(pathForDraw.first!, color: .red)
        drawPoint(pathForDraw.last!, color: .green)
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


