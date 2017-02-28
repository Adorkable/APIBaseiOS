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
    static var baseUrl : URL? { get }
    
    static var cachePolicy : NSURLRequest.CachePolicy { get }
    static var timeoutInterval : TimeInterval { get }
    
    static func encodeString(_ string : String) -> String?
    
    static func addParameter(_ addTo : inout String, name : String, value : String)
}

public extension API {
    static var requestProtocol : String {
        get {
            return "http"
        }
    }
    
    static var baseUrl : URL? {
        get {
            return URL(string: self.requestProtocol + "://" + self.domain + ":" + self.port)
        }
    }
    
    static var cachePolicy : NSURLRequest.CachePolicy {
        get {
            return NSURLRequest.CachePolicy.reloadRevalidatingCacheData
        }
    }
    static var timeoutInterval : TimeInterval {
        get {
            return 30
        }
    }
    
    static func encodeString(_ string : String) -> String? {
        
        return string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    static func addParameter(_ addTo : inout String, name : String, value : String) {
        
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
