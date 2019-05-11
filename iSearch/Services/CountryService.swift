//
//  ContryService.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

typealias completionBlock = (_ countries:[Country]?, _ error:Error?) -> ()

class CountryService: BaseService {
    
    var searchURL:URL!
    
    
    //To get country list for query entered text
    func getCountrySearchResults(_ searchText:String,
                                 searchScope: String = SearchScope.Name.rawValue,
                                 completionBlock: @escaping completionBlock) {
        
        
        guard let url = self.buildCountrySearchUrl(searchText, searchScope: searchScope) else {
            completionBlock(nil, nil)
            return
        }
        
        networkService.request(url, method: .get, parameters: [:], headers: [:], success: { (data, response) in
            
            if data != nil {
                
                do {
                    var responseData = data
                    if let jsonString = String(data: data!, encoding: String.Encoding.utf8) {
                        responseData = jsonString.data(using: .utf8)
                    }
                    let countryArray = try JSONDecoder().decode([Country].self, from: responseData!)
                    guard countryArray.count > 0 else {
                        return
                    }
                    completionBlock(countryArray, nil)
                } catch let error as NSError {
                    completionBlock(nil, error)
                }
            } else {
                completionBlock(nil, nil)
            }
        }) { (data, response, error) in
            completionBlock(nil, error)
        }
    }
    
    // To generate country search URL with scope
    func buildCountrySearchUrl(_ searchText:String,
                               searchScope: String) -> URL? {
        guard var url: URL = URL(string: self.baseUrl) else {
            return nil
        }
        url.appendPathComponent(searchScope)
        url.appendPathComponent(searchText)
        return url
    }
}
