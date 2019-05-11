//
//  BaseService.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

class BaseService {
    
    var baseUrl = "https://restcountries.eu/rest/v2"
    var networkService: NetworkServiceInterface
    
    init(){
        self.networkService = NetworkServiceFactory.getNetworkService(ofType: .SessionService)
    }
}
