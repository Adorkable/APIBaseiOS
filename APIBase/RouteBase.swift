//
//  RouteBase.swift
//  APIBase
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

internal let SubclassShouldOverrideString = "Subclass should override"

internal let SubclassShouldOverrideUrl : NSURL? = NSURL(string: "subclassShouldOverride://asdf")

public protocol Route {
    static var baseUrl : NSURL? { get }
    
    var timeoutInterval : NSTimeInterval { get }
    var cachePolicy : NSURLRequestCachePolicy  { get }
    
    var path : String { get }
    var query : String { get }
    static var httpMethod : String { get }
    var httpBody : String { get }
    
    func buildUrl() -> NSURL?
    
    func dataTask(configureUrlRequest configureUrlRequest : ( (urlRequest : NSMutableURLRequest) -> Void)?, completionHandler : (data : NSData?, urlResponse : NSURLResponse?, error : NSError?) -> Void ) -> NSURLSessionDataTask?
    func jsonTask(configureUrlRequest : ( (urlRequest : NSMutableURLRequest) -> Void)?, completionHandler : (jsonObject : AnyObject?, error : NSError?) -> Void) -> NSURLSessionDataTask?
}

public extension Route {
    
    func buildUrl() -> NSURL? {
        
        // TODO: proper way to tell clients of this library the reason for this failure
        guard self.path != SubclassShouldOverrideString else {
            return nil
        }
        
        var combinedPath = self.path
        
        var query = String()
        if self.query != SubclassShouldOverrideString
        {
            query += self.query
        }
        
        if query.characters.count > 0
        {
            combinedPath += "?" + query
        }
        
        return NSURL(string: combinedPath, relativeToURL: self.dynamicType.baseUrl)
    }
    
    public func dataTask(configureUrlRequest configureUrlRequest : ( (urlRequest : NSMutableURLRequest) -> Void)? = nil, completionHandler : (data : NSData?, urlResponse : NSURLResponse?, error : NSError?) -> Void ) -> NSURLSessionDataTask? {
        
        guard let url = self.buildUrl() else {
            // TODO: notify client?
            return nil
        }
        
        guard self.dynamicType.httpMethod != SubclassShouldOverrideString else {
            // TODO: notify client
            return nil
        }
        
        let urlRequest = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        urlRequest.HTTPMethod = self.dynamicType.httpMethod
    
        if self.httpBody != SubclassShouldOverrideString
        {
            if let bodyData = self.httpBody.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            {
                urlRequest.HTTPBody = bodyData
                urlRequest.setValue("\(bodyData.length)", forHTTPHeaderField: "Content-Length")
            }
        }
        
        if configureUrlRequest != nil
        {
            configureUrlRequest!(urlRequest: urlRequest)
        }
        
        let urlSession = NSURLSession.sharedSession()
        return urlSession.dataTaskWithRequest(urlRequest, completionHandler: completionHandler)
    }
    
    public func jsonTask(configureUrlRequest : ( (urlRequest : NSMutableURLRequest) -> Void)? = nil, completionHandler : (jsonObject : AnyObject?, error : NSError?) -> Void) -> NSURLSessionDataTask? {
        
        return self.dataTask(configureUrlRequest: { (urlRequest : NSMutableURLRequest) -> Void in
            
            if let configureUrlRequest = configureUrlRequest
            {
                configureUrlRequest(urlRequest: urlRequest)
            }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // TODO: should this go before or after the calls closer to the client?
            
            }, completionHandler: { (data, urlResponse, error) -> Void in
                if data != nil
                {
                    do
                    {
                        if let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        {
                            completionHandler(jsonObject: jsonObject, error: nil)
                        } else if let errorString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                        {
                            completionHandler(jsonObject: nil, error: NSError(domain: errorString, code: 0, userInfo: nil) )
                        } else
                        {
                            completionHandler(jsonObject: nil, error: NSError(domain: "Unknown error from request", code: 0, userInfo: nil) )
                        }
                    } catch let error as NSError
                    {
                        completionHandler(jsonObject: nil, error: error)
                    }
                } else
                {
                    completionHandler(jsonObject: nil, error: error)
                }
        })
    }
}

// TODO: currently Generic Protocols are not supported
public class RouteBase<T : API>: NSObject, Route {
    
    public static var baseUrl : NSURL? {
        return T.baseUrl
    }
    
    public let timeoutInterval : NSTimeInterval
    public let cachePolicy : NSURLRequestCachePolicy
    
    public init(timeoutInterval : NSTimeInterval = T.timeoutInterval, cachePolicy : NSURLRequestCachePolicy = T.cachePolicy) {
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        
        super.init()
    }
    
    // TODO: Figure out better abstact function mechanism
    public var path : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    public var query : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    public class var httpMethod : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    public var httpBody : String {
        return SubclassShouldOverrideString
    }
    
    public class func addParameter(inout addTo : String, name : String, value : String) {
        
        T.addParameter(&addTo, name: name, value: value)
    }
}
