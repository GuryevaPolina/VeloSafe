//
//  StreetsViewController.swift
//  VeloSafe
//
//  Created by Polina on 28/05/2019.
//  Copyright © 2019 polinaguryeva. All rights reserved.
//

import UIKit

class StreetsViewController: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    var editedTextField: UITextField?
    
    var streets = [String]()
    private var filteredStreets = [String]()
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.textAlignment = .center
        label.textColor = UIColor.init(white: 0, alpha: 0.5)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        searchBar.delegate = self
        
        filteredStreets = streets
    }
    
    func setTextToSearchBar(_ text: String) {
        searchBar.text = text
    }

}

extension StreetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = filteredStreets.isEmpty ? emptyLabel : nil
        return filteredStreets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "streetCell") as! StreetTableViewCell
        cell.configure(with: filteredStreets[indexPath.row])
        return cell
    }
}

extension StreetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setTextToSearchBar(filteredStreets[indexPath.row])
        editedTextField?.text = filteredStreets[indexPath.row]
        dismiss(animated: true, completion: nil)
    }
}

extension StreetsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredStreets = streets
        } else {
            filteredStreets = streets.filter( { $0.contains(searchText) } )
        }
        tableView.reloadData()
    }
}
