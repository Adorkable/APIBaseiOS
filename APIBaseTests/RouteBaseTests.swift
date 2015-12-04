//
//  RouteBaseTests.swift
//  RouteBaseTests
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import XCTest

#if os(iOS)
    @testable import APIBaseiOS
#elseif os(OSX)
    @testable import APIBaseOSX
#endif

struct TestAPI : API {
    static var domain : String {
        return "www.asdf.com"
    }
    static var port : String {
        return "80"
    }
}

// TODO: Test creating a subclass of RouteBase
class RouteBaseTests: XCTestCase {
    
    func testBaseUrl() {
        XCTAssertNotNil(RouteBase<TestAPI>.baseUrl, "Base Url should not be nil")
        XCTAssertNotEqual(SubclassShouldOverrideUrl!, RouteBase<TestAPI>.baseUrl!, "Base Url should not equal Subclass Should Override Url")
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
