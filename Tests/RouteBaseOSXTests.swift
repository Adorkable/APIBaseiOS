//
//  RouteBaseTests.swift
//  RouteBaseTests
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import XCTest

@testable import APIBaseOSX

struct TestAPI : API {
    static var domain : String {
        get
        {
            return "www.asdf.com"
        }
    }
}

// TODO: Test creating a subclass of RouteBase
class RouteBaseTests: XCTestCase {
    
    func testBaseUrl() {
        XCTAssertNotNil(RouteBase<TestAPI>.baseUrl, "Base Url should not be nil")
        XCTAssertNotEqual(SubclassShouldOverrideUrl!, RouteBase<TestAPI>.baseUrl!, "Base Url should not equal Subclass Should Override Url")
    }
    
    func testPath() {
        XCTAssertEqual(SubclassShouldOverrideString, RouteBase<TestAPI>.path, "Path should equal Subclass Should Override String")
    }
    
    func testQuery() {
        let base = RouteBase<TestAPI>()
        
        XCTAssertEqual(SubclassShouldOverrideString, base.query, "Query should equal Subclass Should Override String")
    }
    
    func testHTTPMethod() {
        XCTAssertEqual(SubclassShouldOverrideString, RouteBase<TestAPI>.httpMethod, "HTTP Method should equal Subclass Should Override String")
    }
    
    func testHTTPBody() {
        let base = RouteBase<TestAPI>()
        
        XCTAssertEqual(SubclassShouldOverrideString, base.httpBody, "HTTP Body should equal Subclass Should Override String")
    }
    
    // TODO: test encodeString
    
    // TODO: test JSON Task
    // TODO: test Data Task
}
