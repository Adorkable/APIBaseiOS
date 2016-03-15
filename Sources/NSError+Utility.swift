//
//  NSError+Utility.swift
//  APIBase
//
//  Created by Ian Grossberg on 7/26/15.
//  Copyright © 2015 Adorkable. All rights reserved.
//

import Foundation

public let NSFunctionErrorKey = "FunctionError"
public let NSLineErrorKey = "LineError"

extension NSError {
    
    // TODO: support NSLocalizedString
    // TODO: support Recovery Attempter
    static func userInfo(description : String, underlyingError : NSError? = nil, failureReason : String? = nil, recoverySuggestion : String? = nil, recoveryOptions : [String]? = nil, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) -> [String : AnyObject] {
        
        var userInfo = [
            NSFilePathErrorKey : fileName,
            NSFunctionErrorKey : functionName,
            NSLineErrorKey : NSNumber(integer: line),
            
            NSLocalizedDescriptionKey : description
        ]
        
        if let underlyingError = underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }
        
        if let failureReason = failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }
        
        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        
        if let recoveryOptions = recoveryOptions {
            userInfo[NSLocalizedRecoveryOptionsErrorKey] = recoveryOptions
        }

        return userInfo
    }
    
    convenience init(domain : String? = nil, code : Int = 0, description : String, underlyingError : NSError? = nil, failureReason : String? = nil, recoverySuggestion : String? = nil, recoveryOptions : [String]? = nil, fileName : String = __FILE__, functionName : String = __FUNCTION__, line : Int = __LINE__) {
        
        let useDomain : String
        if let domain = domain {
            useDomain = domain
        } else {
            useDomain = description
        }
        
        let userInfo = NSError.userInfo(description, underlyingError: underlyingError, failureReason: failureReason, recoverySuggestion: recoverySuggestion, recoveryOptions: recoveryOptions, fileName: fileName, functionName: functionName, line: line)
        
        self.init(domain: useDomain, code: 0, userInfo: userInfo)
    }
}