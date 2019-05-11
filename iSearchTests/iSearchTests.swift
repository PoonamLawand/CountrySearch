//
//  iSearchTests.swift
//  iSearchTests
//
//  Created by Lawand, Poonam on 5/8/19.
//  Copyright © 2019 Lawand, Poonam. All rights reserved.
//

import XCTest
@testable import iSearch

class iSearchTests: XCTestCase {
    
    var mockURLSession:MockURLSession!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
          mockURLSession = MockURLSession()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testAsyncCountryRequest(){
        
    }
}
// MARK: Mocks
//========================================================================

    class MockURLSession : URLSession {
      //  override func dataTask(with url: URL) -> URLSessionDataTask {
        override init() {
            super.init()
        }
         func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> MockNSURLSessionDataTask {
             return MockNSURLSessionDataTask(successBlock:completionHandler)
        }
        
    }

    class MockNSURLSessionDataTask : URLSessionTask {
        var successBlock : (Data?, URLResponse?, Error?) -> Void
        init(successBlock:(((Data?, URLResponse?, Error?) -> Void)?)){
            self.successBlock = successBlock!
        }

        override func resume() {
            
            self.successBlock(Data(), HTTPURLResponse(url:URL(string:"https://dummy.com")!, statusCode: 200, httpVersion: "GET", headerFields: nil), nil)
        }
    }
