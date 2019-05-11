//
//  SearchViewModel.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

enum SearchScope:String, CaseIterable {
    case Name = "name"
    case Regain   = "region"
    case Capital = "capital"
    case CallingCode  = "callingcode"
    case Language   = "lang"
    case Currency    = "currency"
    
    func getScopeFromIndex(_ index:Int) -> SearchScope
    {
        return SearchScope.allCases[index]
    }
    func getAllValues() -> [String] {
        return  SearchScope.allCases.map { $0.rawValue }
    }
}

class SearchViewModel {
    
    var countryService: CountryService = CountryService()
    
    func search(searchText: String,
                searchScope: SearchScope,
                completion:@escaping completionBlock) {
        
        countryService.getCountrySearchResults(searchText, searchScope: searchScope.rawValue, completionBlock:completion)
    }
    
}
