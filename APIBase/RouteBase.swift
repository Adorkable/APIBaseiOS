//
//  RouteBase.swift
//  APIBase
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

// TODO: Swift 2.0 this should be a protocol
public class RouteBase: NSObject {
    // TODO: Swift 2.0 should be internal and testable
    public class var SubclassShouldOverrideString : String {
        return "Subclass should override"
    }
    
    public class var SubclassShouldOverrideUrl : NSURL? {
        return NSURL(string: "subclassShouldOverride://asdf")
    }
    
    public class var baseUrl : NSURL? {
        return self.SubclassShouldOverrideUrl
    }
    
    public static let defaultTimeout : NSTimeInterval = 10
    let timeoutInterval : NSTimeInterval
    
    public static let defaultCachePolicy : NSURLRequestCachePolicy = .ReloadRevalidatingCacheData
    public let cachePolicy : NSURLRequestCachePolicy
    
    public init(timeoutInterval : NSTimeInterval, cachePolicy : NSURLRequestCachePolicy) {
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        
        super.init()
    }
    
    // TODO: Swift 2.0 this should be a protocol function declaration
    public class var path : String {
        return self.SubclassShouldOverrideString
    }
    
    // TODO: Swift 2.0 this should be a protocol function declaration
    public var query : String {
        return RouteBase.SubclassShouldOverrideString
    }
    
    // TODO: Swift 2.0 this should be a protocol function declaration
    public class var httpMethod : String {
        return self.SubclassShouldOverrideString
    }
    
    // TODO: Swift 2.0 this should be a protocol function declaration
    public var httpBody : String {
        return RouteBase.SubclassShouldOverrideString
    }
    
    // TODO: Swift 2.0 this should be a default implementation function
    internal class func encodeString(string : String) -> String? {
        return string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
    
    // TODO: Swift 2.0 this should be a default implementation function
    internal func buildUrl() -> NSURL? {
        
        var result : NSURL?
        
        if self.dynamicType.baseUrl != RouteBase.SubclassShouldOverrideUrl
        {
            if self.dynamicType.path != RouteBase.SubclassShouldOverrideString
            {
                var combinedPath = self.dynamicType.path
                
                var query = String()
                if self.query != RouteBase.SubclassShouldOverrideString
                {
                    query += self.query
                }
                
                if count(query) > 0
                {
                    combinedPath += "?" + query
                }
                
                result = NSURL(string: combinedPath, relativeToURL: self.dynamicType.baseUrl)
            }
        } // TODO: proper way to tell clients of this library the reason for this failure
        
        return result
    }
    
    internal class func addParameter(inout addTo : String, name : String, value : String) {
        if count(name) > 0 &&
            count(value) > 0,
            let encodedValue = self.encodeString(value)
        {
            var add = name + "=" + encodedValue
            
            if count(addTo) > 0 {
                addTo += "&" + add
            } else {
                addTo = add
            }
            
        }
    }
    
    // TODO: Swift 2.0 this should be a default implementation function
    public func dataTask(configureUrlRequest : ( (urlRequest : NSMutableURLRequest) -> Void)? = nil, completionHandler : (data : NSData?, urlResponse : NSURLResponse?, error : NSError?) -> Void ) -> NSURLSessionDataTask? {
        var result : NSURLSessionDataTask?
        
        if let url = self.buildUrl()
        {
            var urlRequest = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
            urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            
            if self.dynamicType.httpMethod != RouteBase.SubclassShouldOverrideString
            {
                urlRequest.HTTPMethod = self.dynamicType.httpMethod
            }
            
            if self.httpBody != RouteBase.SubclassShouldOverrideString
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
            result = urlSession.dataTaskWithRequest(urlRequest, completionHandler: completionHandler)
        }
        
        return result
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
                var error : NSError?
                var string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if let jsonObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: &error)
                {
                    completionHandler(jsonObject: jsonObject, error: nil)
                } else if let errorString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
                {
                    completionHandler(jsonObject: nil, error: NSError(domain: errorString, code: 0, userInfo: nil) )
                } else
                {
                    completionHandler(jsonObject: nil, error: NSError(domain: "Unknown error from request", code: 0, userInfo: nil) )
                }
            } else
            {
                completionHandler(jsonObject: nil, error: error)
            }
        })
    }
}
