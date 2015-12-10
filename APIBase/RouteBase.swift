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

public enum SuccessResult<T> {
    case Success(T)
    case Failure(NSError)
}

public typealias ConfigureUrlRequestHandler = (urlRequest : NSMutableURLRequest) -> Void
public typealias DataTaskCompletionHandler = (result : SuccessResult<NSData>, urlResponse : NSURLResponse?) -> Void
public typealias JsonTaskCompletionHandler = (result : SuccessResult<AnyObject>) -> Void

public protocol Route {
    // TODO: once Swift supports protocol class vars as this should be overridable (when inheriting from RouteBase for example)
    var baseUrl : NSURL? { get }
    
    var timeoutInterval : NSTimeInterval { get }
    var cachePolicy : NSURLRequestCachePolicy  { get }
    
    var path : String { get }
    var query : String { get }
    static var httpMethod : String { get }
    var httpBody : String { get }
    
    func buildUrl() -> NSURL?
    
    func dataTask(configureUrlRequest configureUrlRequest : ConfigureUrlRequestHandler?, completionHandler : DataTaskCompletionHandler) -> NSURLSessionDataTask?
    func jsonTask(configureUrlRequest : ConfigureUrlRequestHandler?, completionHandler : JsonTaskCompletionHandler) -> NSURLSessionDataTask?
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
        
        return NSURL(string: combinedPath, relativeToURL: self.baseUrl)
    }
    
    public func dataTask(configureUrlRequest configureUrlRequest : ConfigureUrlRequestHandler? = nil, completionHandler : DataTaskCompletionHandler) -> NSURLSessionDataTask? {
        
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
        
        if let configureUrlRequest = configureUrlRequest {
            configureUrlRequest(urlRequest: urlRequest)
        }
        
        let urlSession = NSURLSession.sharedSession()
        
        return urlSession.dataTaskWithRequest(urlRequest, completionHandler: { (data, urlResponse, error) -> Void in
            
            guard let data = data else {
                
                if let error = error {
                    
                    completionHandler(result: .Failure(error), urlResponse: urlResponse)
                } else {
                    
                    completionHandler(result: .Failure(NSError(domain: "Response is empty", code: 0, userInfo: nil) ), urlResponse: urlResponse)
                }
                
                return
            }
            
            completionHandler(result: .Success(data), urlResponse: urlResponse)
        })
    }
    
    public func jsonTask(configureUrlRequest : ConfigureUrlRequestHandler? = nil, completionHandler : JsonTaskCompletionHandler) -> NSURLSessionDataTask? {
        
        return self.dataTask(configureUrlRequest: { (urlRequest : NSMutableURLRequest) -> Void in
            
            if let configureUrlRequest = configureUrlRequest
            {
                configureUrlRequest(urlRequest: urlRequest)
            }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // TODO: should this go before or after the calls closer to the client?
            
            }, completionHandler: { (result, urlResponse) -> Void in
                
                switch result {
                case .Success(let data):
                    
                    do
                    {
                        let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        completionHandler(result: .Success(jsonObject))
                        
                    } catch let error as NSError
                    {
                        if error.code == 3840, // Invalid JSON format, may be straight text
                            let decodedErrorString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                            
                                let decodedError = NSError(domain: decodedErrorString as String, code: 0, userInfo: nil)
                                completionHandler(result: .Failure(decodedError))
                            
                        } else {
                            completionHandler(result: .Failure(error))
                        }
                    }
                    
                    break
                    
                case .Failure(let error):
                    completionHandler(result: .Failure(error))
                    break
                }
        })
    }
}

// TODO: currently Generic Protocols are not supported
public class RouteBase<T : API>: NSObject, Route {
    
    public var baseUrl : NSURL? {
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
