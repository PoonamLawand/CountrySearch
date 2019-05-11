//
//  NetworkServiceFactory.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

enum NetworkServiceType: String {
    case SessionService = "urlSession"
    case AlamofireService = "alamofire"
}
class NetworkServiceFactory {
    
    static func getNetworkService(ofType: NetworkServiceType) -> NetworkServiceInterface {
        return SessionNetworkService()
    }
}


