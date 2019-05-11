//
//  SessionNetworkService.swift
//  iSearch
//
//  Created by Lawand, Poonam on 5/9/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import Foundation

typealias CompletionBlock = (success: SuccessBlock, failure:FailureBlock)

@objcMembers class SessionNetworkService: NSObject {
    
    private var serialSession: URLSession!
    private var cacheURL: URLCache!
    var waitingRequestQueue:[URL :(completionBlocks: [CompletionBlock],task:URLSessionDataTask)] = [:]
    var currentTask:URLSessionDataTask?
    private let concurrentQueue = DispatchQueue(label: "concurrentQ", attributes: .concurrent)
    
    override init() {
        super.init()
        //Cache Configuration
        cacheURL = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "CacheRequest")
        let config = URLSessionConfiguration.default
        config.urlCache = cacheURL
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        //Session Configuration
        serialSession = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
    }
    
    //To build/create URLSessionTask from url request parameter
    func buildHttpRequest(withURL url: URL, ofType type:URLRequestMethodType, headers:[String:String], withPayLoad data:[String:AnyObject]? = nil,
                          timeoutInterval:Int? = nil, cachePolicy: URLRequest.CachePolicy? = nil, successBlock:@escaping SuccessBlock, failureBlock:@escaping FailureBlock)
    {
        
        let task = getSessionTask(withURL: url, ofType: type, headers: headers, withPayLoad: data, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy, successBlock: successBlock, failureBlock: failureBlock)
        
        task.resume()
    }
    
    //To create URLSessionTask from url request parameter
    private func getSessionTask(forSession sesssion:URLSession = URLSession.shared, withURL url: URL, ofType type:URLRequestMethodType, headers:[String:String], withPayLoad data:[String:AnyObject]? = nil,
                                timeoutInterval:Int? = nil, cachePolicy: URLRequest.CachePolicy? = nil, successBlock:@escaping SuccessBlock, failureBlock:@escaping FailureBlock) -> URLSessionDataTask {
        let request = URLRequestOf(type: type, withURL: url, headers: headers, and:data, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy)
        
        let task = sesssion.dataTask(with: request) { (data, response, error) in
            if error != nil {
                failureBlock(data, response, error)
                return
            }
            
            if let data = data,let response = String(data: data, encoding: String.Encoding.utf8) {
                #if DEBUG
                print("Request: \(String(describing: request.url?.absoluteString))")
                print("Response: \(response)")
                #endif
            }
            successBlock(data, response)
        }
        
        return task
    }
    
    //Create URLRequest from url,query parameter,method
    private func URLRequestOf(type:URLRequestMethodType, withURL url: URL, headers:[String:String], and data: [String:AnyObject]? = nil,  timeoutInterval: Int? = nil, cachePolicy: URLRequest.CachePolicy? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        
        if let timeoutInterval = timeoutInterval, let cachePolicy = cachePolicy {
            request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: TimeInterval(timeoutInterval))
        }
        
        if let body = data {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        request.httpMethod = type.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return request
    }
    
    
}

extension SessionNetworkService : NetworkServiceInterface {
    //Generate Reuest
    func request(_ url: URL, method: URLRequestMethodType, parameters: [String : AnyObject]?, headers: [String : String]?, success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
        
        //Serial Request
        self.buildSerialHttpRequest(withURL: url, ofType: method, headers: headers ?? [:], withPayLoad: nil, timeoutInterval: 30, cachePolicy: .returnCacheDataElseLoad, successBlock:success,failureBlock:failure)
    }
}

//MARK:- Serial api call with cache policy

extension SessionNetworkService {
    
    //Check respose in cache if not present make a new call with reuest parameter
    func buildSerialHttpRequest(withURL url: URL, ofType type:URLRequestMethodType, headers:[String:String], withPayLoad data:[String:AnyObject]? = nil, timeoutInterval:Int, cachePolicy: URLRequest.CachePolicy, successBlock:@escaping SuccessBlock, failureBlock:@escaping FailureBlock) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: { () -> Void in
            let urlRequest = self.URLRequestOf(type: type, withURL: url, headers: headers, and: data, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy)
            
            if let cachedResponse = self.cacheURL.cachedResponse(for: urlRequest) {
                DispatchQueue.main.async {
                    guard let error = self.getErrorFromResponse( cachedResponse.response as! HTTPURLResponse) else {
                        successBlock(cachedResponse.data, cachedResponse.response)
                        return
                    }
                    failureBlock(nil,nil,error)
                }
            } else {
                let task = self.getSessionTask(forSession: self.serialSession, withURL: url, ofType: type, headers: headers, withPayLoad: data, timeoutInterval: timeoutInterval, cachePolicy: cachePolicy, successBlock: { [weak self] (data, response) in
                    if let strongSelf = self {
                        DispatchQueue.main.async {
                            if let response = response, let data = data {
                                strongSelf.cacheURL.storeCachedResponse(CachedURLResponse(response:response, data:data, userInfo:nil, storagePolicy:Foundation.URLCache.StoragePolicy.allowed), for: urlRequest)
                            }
                            
                            strongSelf.executeComplitionBlocks(forURL: url, data: data, response: response)
                        }
                    }
                    }, failureBlock: {[weak self] (data, response, error) in
                        if let strongSelf = self {
                            DispatchQueue.main.async {
                                strongSelf.executeComplitionBlocks(forURL: url, data: data, response: response, error: error)
                            }
                        }
                })
                self.currentTask = task
                self.addRequestToQueue(url, task, completion: (success: successBlock, failure:failureBlock))
            }
        })
    }
    
    func clearCache() {
        waitingRequestQueue = [:]
        cacheURL.removeAllCachedResponses()
    }
    
    //To build error object from HTTPURLResponse status code
    func getErrorFromResponse(_ response : HTTPURLResponse) -> NSError?{
        
        if response.statusCode == 404 {
            let errorObj = NSError(domain: "some_domain",
                                   code: 404,
                                   userInfo: [NSLocalizedDescriptionKey: "Not Found"])
            
            return errorObj
        }
        return nil
    }
    
    //To get serch result of recent/last search key word
    //It will return server response data to show last search result from Server
    //If user search India then we call data for i,in,ind,indi,india
    //Will execute complition handler for india only to search result throw contrySrevice (i,in,ind,indi saved in cache)
    private func executeComplitionBlocks(forURL url:URL, data: Data?, response: URLResponse?, error:Error? = nil)
    {
        guard let task = waitingRequestQueue[url]?.task else
        {
            return
        }
        if( self.currentTask == task){
            if let error = error {
                if let compeletions = waitingRequestQueue[url]?.completionBlocks {
                    for compeletion in compeletions {
                        compeletion.failure(data, response, error)
                    }
                }
            }else {
                if let compeletions = waitingRequestQueue[url]?.completionBlocks {
                    for compeletion in compeletions {
                        guard let error = self.getErrorFromResponse( response as! HTTPURLResponse) else {
                            compeletion.success(data, response)
                            return
                        }
                        compeletion.failure(nil, nil,error)
                        
                    }
                }
            }
            
            
            if let index = waitingRequestQueue.index(forKey: url) {
                waitingRequestQueue.remove(at: index)
            }
        }
        
        
        
    }
    
    
    //Create a queue to track all session data task
    private func addRequestToQueue(_ url:URL, _ task:URLSessionDataTask, completion: CompletionBlock) {
        if var completionBlocks = waitingRequestQueue[url]?.completionBlocks {
            completionBlocks.append(completion)
            concurrentQueue.async(flags: .barrier) {
                self.waitingRequestQueue[url] = (completionBlocks,task)
            }
            task.cancel()
        }else {
            concurrentQueue.async(flags: .barrier) {
                self.waitingRequestQueue[url] = ([completion],task)
            }
            if task.state != .running {
                task.resume()
            }
        }
    }
}
