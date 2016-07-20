//
//  Socket.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//


#if os(Linux)
    import Glibc
#endif

import RxSwift


public protocol SockAddr {
    init()
    
    mutating func setup(_ listenAddr: Address, listenPort: UInt16) throws
    
    static var size : Int {get}
    static var addressFamily: Int32 { get }
    
    // returns PF_INET6 or PF_INET
    static var protocolFamily: Int32 { get }
    
    func withUnsafeSockaddrPtr<Result>(@noescape _ body: @noescape (UnsafePointer<sockaddr>) throws -> Result) rethrows -> Result
}

public enum Address {
    case loopback
    case any
    case ipv6Addr(address: String)
    case ipv4Addr(address: String)
}

extension sockaddr_in6: SockAddr {
    public mutating func setup(_ listenAddr: Address, listenPort: UInt16) throws {
        switch listenAddr {
        case .any:
            self.sin6_addr = in6addr_any
        case let .ipv6Addr(address: address):
            try Error.throwIfNotSuccess(inet_pton(self.dynamicType.addressFamily, address, &self.sin6_addr))
        case .ipv4Addr:
            fatalError("Cannot listen to IPV4Address in an ipv6 socket")
        case .loopback:
            self.sin6_addr = in6addr_loopback
        }
        
        self.sin6_port = listenPort.bigEndian
        self.sin6_family = sa_family_t(self.dynamicType.addressFamily)
        #if !os(Linux)
        self.sin6_len = UInt8(self.dynamicType.size)
        #endif
    }
    
    public func withUnsafeSockaddrPtr<Result>(@noescape _ body: @noescape (UnsafePointer<sockaddr>) throws -> Result) rethrows -> Result {
        var copy = self
        return try withUnsafePointer(&copy) { ptr -> Result in
            return try body(unsafeBitCast(ptr, to: UnsafePointer<sockaddr>.self))
        }
    }
    
    public static let size = sizeof(sockaddr_in6.self)
    public static let addressFamily = AF_INET6
    public static let protocolFamily = PF_INET6
}

let INADDR_ANY = in_addr(s_addr: 0x00000000)
let INADDR_LOOPBACK4 = in_addr(s_addr: UInt32(0x7f000001).bigEndian)

extension sockaddr_in: SockAddr {
    public static let size = sizeof(sockaddr_in.self)
    public static let addressFamily = AF_INET
    public static let protocolFamily = PF_INET

    public mutating func setup(_ listenAddr: Address, listenPort: UInt16) throws {
        switch listenAddr {
        case .any:
            self.sin_addr = INADDR_ANY
        case let .ipv4Addr(address: address):
            try Error.throwIfNotSuccess(inet_pton(self.dynamicType.addressFamily, address, &self.sin_addr))
        case .ipv6Addr:
            fatalError("Cannot listen to IPV6Address in an ipv4 socket")
        case .loopback:
            self.sin_addr = INADDR_LOOPBACK4
        }
        
        self.sin_port = listenPort.bigEndian
        self.sin_family = sa_family_t(self.dynamicType.addressFamily)
        
        #if !os(Linux)
        self.sin_len = UInt8(self.dynamicType.size)
        #endif
    }
    
    public func withUnsafeSockaddrPtr<Result>( _ body: @noescape (UnsafePointer<sockaddr>) throws -> Result) rethrows -> Result {
        var copy = self
        return try withUnsafePointer(&copy) { ptr -> Result in
            return try body(unsafeBitCast(ptr, to: UnsafePointer<sockaddr>.self))
        }
    }
}


public extension SockAddr {    
    var addr: sockaddr {
        return self.withUnsafeSockaddrPtr { ptr in
            return ptr.pointee
        }
    }
}

