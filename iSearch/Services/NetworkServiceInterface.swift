//
//  NetworkServiceInterface.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

enum URLRequestMethodType: String {
    case get    = "GET"
    case post   = "POST"
    case delete = "DELETE"
    case put    = "PUT"
}

typealias SuccessBlock = (_ data:Data?, _ response:URLResponse?) -> ()
typealias FailureBlock = (_ data:Data?, _ response:URLResponse?, _ error:Error?) -> ()

protocol NetworkServiceInterface {
    
    func request(_ url: URL,
                 method: URLRequestMethodType,
                 parameters: [String: AnyObject]?,
                 headers: [String: String]?,
                 success: @escaping SuccessBlock,
                 failure: @escaping FailureBlock)
}
