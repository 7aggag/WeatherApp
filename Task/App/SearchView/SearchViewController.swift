//
//  SearchViewController.swift
//  Task
//
//  Created by Haggag on 21/09/2024.
//

import UIKit
import MapKit

protocol SearchPlacesProtocol: AnyObject {
    func didSelectCity(city: String)
}

class SearchViewController: UIViewController {
    private var searchBar = UISearchBar()
    @IBOutlet weak var searchResultsTable: UITableView!
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchRegion: MKCoordinateRegion
    private var searchResults = [MKLocalSearchCompletion]()
    weak var delegate: SearchPlacesProtocol?
    init(delegate: SearchPlacesProtocol, region: MKCoordinateRegion = .init(.world)) {
        self.delegate = delegate
        self.searchRegion = region
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        iniTableview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    private func iniTableview() {
        searchCompleter.delegate = self
        searchCompleter.region = searchRegion
        searchBar.delegate = self
        searchResultsTable?.delegate = self
        searchResultsTable?.dataSource = self
        searchResultsTable.rowHeight = 70
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .prominent
        searchResultsTable.tableFooterView = UIView()
        navigationItem.titleView = searchBar
        searchResultsTable.keyboardDismissMode = .onDrag
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .white
        cell.textLabel?.text = searchResult.title
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.text = searchResult.subtitle
        cell.detailTextLabel?.textColor = .darkGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            if let placemark = response?.mapItems.first?.placemark {
                guard let city = placemark.administrativeArea else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Unable to fetch city information.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                    return
                }
                self.navigationController?.popViewController(animated: false)
                self.delegate?.didSelectCity(city: city)
            }
        }
    }
}
extension SearchViewController: UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTable.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}
