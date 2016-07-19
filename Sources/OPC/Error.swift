//
//  Error.swift
//  SocketRocket
//
//  Created by Mike Lewis on 8/7/15.
//
//

import Darwin

/// Wraps errors. Has an uknown type if it cant resolve to an oserror
enum Error: ErrorProtocol {
    case unknown(status: Int32)
    case codecError
    case utf8DecodeError
    case canceled
    
    /// For functions that return negative value on error and expect errno to be set
    static func checkReturnCode(_ returnCode: Int32) -> ErrorProtocol? {
        guard returnCode < 0 else {
            return nil
        }
        return errorFromStatusCode(errno)
    }
    
    /// Returns an error type based on status code
    static func errorFromStatusCode(_ status: Int32) -> ErrorProtocol? {
        guard status != 0 else {
            return nil
        }
        
        if let e = POSIXError(rawValue: status) {
            return e
        }
        
        return Error.unknown(status: status)
    }
    
    static func throwIfNotSuccess(_ status: Int32) throws  {
        if let e = errorFromStatusCode(status) {
            throw e
        }
    }
    
    // Same as above, but checks if less than 0, and uses errno as the varaible
    static func throwIfNotSuccessLessThan0(_ returnCode: Int32) throws  {
        if let e = checkReturnCode(returnCode) {
            throw e
        }
    }
}
