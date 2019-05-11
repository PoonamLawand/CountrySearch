//
//  SearchViewController.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/8/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    // MARK: - Properties
    //var detailViewController: DetailViewController? = nil
    var searchObjects = [Country]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchViewModel: SearchViewModel = SearchViewModel()
    var error :NSError?
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self;
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = SearchScope.Name.getAllValues()
        searchController.searchBar.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.setTextColor(color: .white)
        searchController.searchBar.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if (error == nil && searchObjects.count == 0){
            return 0
        }
        return error != nil ? 1 : searchObjects.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.error == nil else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = self.error?.localizedDescription
            return cell
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        let country = searchObjects[indexPath.row]
        if let url = URL(string: country.flag) {
            cell?.downloadAndSetflagViewImageWithURL(url)
        }
        
        cell?.countryNameLabel!.text = country.name
       
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCountry" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let countryObj:Country = self.searchObjects[indexPath.row]
                
                let controller = segue.destination as! CountryDetailViewController
                controller.currentCountry
                    = countryObj 
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    
    // MARK: - Private instance methods
    
    func serachCountryForSearchText(_ searchText: String,
                                    scope: SearchScope = SearchScope.Name) {
        guard (searchText == "") else {
            
            self.searchViewModel.search(searchText: searchText,
                                        searchScope: scope,
                                        completion: {(countries, error) in
                                            if (countries != nil){
                                                DispatchQueue.main.async {
                                                    self.searchObjects = countries ?? []
                                                    self.error  = nil
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            if (countries == nil && error != nil)
                                            {
                                                self.searchObjects  = []
                                                self.error  = error! as NSError
                                                self.tableView.reloadData()
                                            }
                                            
            })
            return
        }
        self.searchObjects = []
        self.error = nil
        self.tableView.reloadData()
    }
    
    //to check is search Text Field empty
    func isSearchBarEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar,
                   selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        serachCountryForSearchText(searchBar.text ?? "",scope: SearchScope(rawValue: scope) ?? SearchScope.Name )
        searchBar.becomeFirstResponder()
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        serachCountryForSearchText(searchController.searchBar.text ?? "",scope: SearchScope(rawValue:searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]) ?? SearchScope.Name )
    }
}
public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
}
