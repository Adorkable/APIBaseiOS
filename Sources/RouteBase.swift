//
//  RouteBase.swift
//  APIBase
//
//  Created by Ian Grossberg on 8/10/15.
//  Copyright (c) 2015 Adorkable. All rights reserved.
//

import Foundation

internal let SubclassShouldOverrideString = "Subclass should override"

internal let SubclassShouldOverrideUrl : URL? = URL(string: "subclassShouldOverride://asdf")

public enum SuccessResult<T> {
    case success(T)
    case failure(Error)
}

public typealias ConfigureUrlRequestHandler = (_ urlRequest : inout URLRequest) -> Void
public typealias DataTaskCompletionHandler = (_ result : SuccessResult<Data>, _ urlResponse : URLResponse?) -> Void
public typealias JsonTaskCompletionHandler = (_ result : SuccessResult<AnyObject>) -> Void

public protocol Route {
    // TODO: once Swift supports protocol class vars as this should be overridable (when inheriting from RouteBase for example)
    var baseUrl : URL? { get }
    
    var timeoutInterval : TimeInterval { get }
    var cachePolicy : NSURLRequest.CachePolicy  { get }
    
    var path : String { get }
    var query : String { get }
    static var httpMethod : String { get }
    var httpBody : String { get }
    
    func buildUrl() -> URL?
    
    func dataTask(configureUrlRequest : ConfigureUrlRequestHandler?, completionHandler : @escaping DataTaskCompletionHandler) -> URLSessionDataTask?
    func jsonTask(_ configureUrlRequest : ConfigureUrlRequestHandler?, completionHandler : @escaping JsonTaskCompletionHandler) -> URLSessionDataTask?
}

public extension Route {
    
    func buildUrl() -> URL? {
        
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
        
        return URL(string: combinedPath, relativeTo: self.baseUrl)
    }
    
    internal func createURLRequest(_ url : URL) -> URLRequest {
        
        var result = URLRequest(url: url, cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        result.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        result.httpMethod = type(of: self).httpMethod
        
        if self.httpBody != SubclassShouldOverrideString
        {
            if let bodyData = self.httpBody.data(using: String.Encoding.utf8, allowLossyConversion: false)
            {
                result.httpBody = bodyData
                result.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
            }
        }
        
        return result
    }
    
    internal func handleDataTaskCompletion(_ data : Data?, urlResponse : URLResponse?, error: Error?, completionHandler : DataTaskCompletionHandler) {
        
        guard let data = data else {
            
            guard let error = error else {
                completionHandler(.failure(NSError(description: "Response is empty") ), urlResponse)
                return
            }
            
            completionHandler(.failure(error), urlResponse)
            return
        }
        
        completionHandler(.success(data), urlResponse)
    }
    
    public func dataTask(configureUrlRequest : ConfigureUrlRequestHandler? = nil, completionHandler : @escaping DataTaskCompletionHandler) -> URLSessionDataTask? {
        
        guard let url = self.buildUrl() else {
            // TODO: notify client?
            return nil
        }
        
        guard type(of: self).httpMethod != SubclassShouldOverrideString else {
            // TODO: notify client
            return nil
        }
        
        var urlRequest = self.createURLRequest(url)
        
        if let configureUrlRequest = configureUrlRequest {
            configureUrlRequest(&urlRequest)
        }
        
        let urlSession = URLSession.shared

        return urlSession.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
            self.handleDataTaskCompletion(data, urlResponse: urlResponse, error: error, completionHandler: completionHandler)
        })
    }
    
    internal func handleJsonTaskCompletion(_ data : SuccessResult<Data>, completionHandler : JsonTaskCompletionHandler) {
        switch data {
        case .success(let data):
            
            do
            {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                completionHandler(SuccessResult<AnyObject>.success(jsonObject))
            } catch let error as NSError
            {
                if error.code == 3840, // Invalid JSON format, may be straight text
                    let decodedErrorString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        
                        let decodedError = NSError(description: decodedErrorString as String)
                        completionHandler(.failure(decodedError))
                        
                } else {
                    completionHandler(.failure(error))
                }
            }
            
            break
            
        case .failure(let error):
            completionHandler(.failure(error))
            break
        }
    }
    
    public func jsonTask(_ configureUrlRequest : ConfigureUrlRequestHandler? = nil, completionHandler : @escaping JsonTaskCompletionHandler) -> URLSessionDataTask? {
        
        return self.dataTask(configureUrlRequest: { (urlRequest : inout URLRequest) -> Void in
            
            if let configureUrlRequest = configureUrlRequest
            {
                configureUrlRequest(&urlRequest)
            }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept") // TODO: should this go before or after the calls closer to the client?
            
        }, completionHandler: { (result, urlResponse) -> Void in

            self.handleJsonTaskCompletion(result, completionHandler: completionHandler)
        })
    }
}

// TODO: currently Generic Protocols are not supported
open class RouteBase<T : API>: NSObject, Route {
    
    open var baseUrl : URL? {
        return T.baseUrl as URL?
    }
    
    open let timeoutInterval : TimeInterval
    open let cachePolicy : NSURLRequest.CachePolicy
    
    public init(timeoutInterval : TimeInterval = T.timeoutInterval, cachePolicy : NSURLRequest.CachePolicy = T.cachePolicy) {
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        
        super.init()
    }
    
    // TODO: Figure out better abstact function mechanism
    open var path : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    open var query : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    open class var httpMethod : String {
        return SubclassShouldOverrideString
    }
    
    // TODO: Figure out better abstact function mechanism
    open var httpBody : String {
        return SubclassShouldOverrideString
    }
    
    open class func addParameter(_ addTo : inout String, name : String, value : String) {
        
        T.addParameter(&addTo, name: name, value: value)
    }
}
