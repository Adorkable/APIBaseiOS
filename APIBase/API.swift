//
//  API.swift
//  APIBase
//
//  Created by Ian Grossberg on 11/19/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

public protocol API {
    
    static var requestProtocol : String { get }
    static var domain : String { get }
    static var port : String { get }
    static var baseUrl : NSURL? { get }
    
    static var cachePolicy : NSURLRequestCachePolicy { get }
    static var timeoutInterval : NSTimeInterval { get }
    
    static func encodeString(string : String) -> String?
    
    static func addParameter(inout addTo : String, name : String, value : String)
}

public extension API {
    static var requestProtocol : String {
        get {
            return "http"
        }
    }
    
    static var baseUrl : NSURL? {
        get {
            return NSURL(string: self.requestProtocol + "://" + self.domain + ":" + self.port)
        }
    }
    
    static var cachePolicy : NSURLRequestCachePolicy {
        get {
            return NSURLRequestCachePolicy.ReloadRevalidatingCacheData
        }
    }
    static var timeoutInterval : NSTimeInterval {
        get {
            return 30
        }
    }
    
    static func encodeString(string : String) -> String? {
        
        return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
    
    static func addParameter(inout addTo : String, name : String, value : String) {
        
        guard name.characters.count > 0 else { return }
        guard value.characters.count > 0 else { return }
        
        guard let encodedValue = self.encodeString(value) else {
            // TODO: report failure
            return
        }
        
        let add = name + "=" + encodedValue
        
        if addTo.characters.count > 0 {
            addTo += "&" + add
        } else {
            addTo = add
        }
    }
}