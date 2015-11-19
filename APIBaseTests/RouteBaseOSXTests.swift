//
//  RouteBaseTests.swift
//  RouteBaseTests
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import XCTest

import APIBaseOSX

// TODO: Test creating a subclass of RouteBase
class RouteBaseTests: XCTestCase {
    
    func testSubclassShouldOverrideUrl() {
        XCTAssertNotNil(RouteBase.SubclassShouldOverrideUrl, "Subclass Should Override Url should not be nil")
    }
    
    func testBaseUrl() {
        XCTAssertNotNil(RouteBase.baseUrl, "Base Url should not be nil")
        XCTAssertEqual(RouteBase.SubclassShouldOverrideUrl!, RouteBase.baseUrl!, "Base Url should equal Subclass Should Override Url")
    }
    
    func testPath() {
        XCTAssertEqual(RouteBase.SubclassShouldOverrideString, RouteBase.path, "Path should equal Subclass Should Override String")
    }
    
    func testQuery() {
        let base = RouteBase(timeoutInterval: RouteBase.defaultTimeout, cachePolicy: RouteBase.defaultCachePolicy)
        
        XCTAssertEqual(RouteBase.SubclassShouldOverrideString, base.query, "Query should equal Subclass Should Override String")
    }
    
    func testHTTPMethod() {
        XCTAssertEqual(RouteBase.SubclassShouldOverrideString, RouteBase.httpMethod, "HTTP Method should equal Subclass Should Override String")
    }
    
    func testHTTPBody() {
        let base = RouteBase(timeoutInterval: RouteBase.defaultTimeout, cachePolicy: RouteBase.defaultCachePolicy)
        
        XCTAssertEqual(RouteBase.SubclassShouldOverrideString, base.httpBody, "HTTP Body should equal Subclass Should Override String")
    }
    
    // TODO: test encodeString
    
    // TODO: test JSON Task
    // TODO: test Data Task
}
