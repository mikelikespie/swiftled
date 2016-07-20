//
//  Net.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//


#if os(Linux)
    import Glibc
#endif

import RxSwift
import Dispatch
import Foundation

private var hints: addrinfo = {
    var hints = addrinfo()
    hints.ai_family = PF_UNSPEC
    #if os(Linux)
        hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
    #else
        hints.ai_socktype = SOCK_STREAM
    #endif
    return hints
}()

// Wrapped addrinfo
public struct AddrInfo {
    let family: Int32
    #if os(Linux)
    let socktype: __socket_type
    #else
    let socktype: Int32
    #endif
    let proto: Int32
    let addr: SockAddr
}

extension AddrInfo {
    public func connect(_ workQueue: DispatchQueue=DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)) -> Observable<Int32> {
        return Observable.create { observer in
            do {
                let socket = try self.socket()
                precondition(socket >= 0)
                
                let writeSource = DispatchSource.write(fileDescriptor: socket, queue: workQueue);
                
                writeSource.resume();
                NSLog("STARTING")
                
                func completeConnection() {
                    // If we got this far, we are successful!
                    // Clear out the close handler, thsi means somebody else will own the socket after this
                    
                    NSLog("COMPLETING CONNECTION")
                    writeSource.suspend()
                    writeSource.setCancelHandler { }
                    writeSource.resume()
                    
                    observer.onNext(socket)
                    observer.onCompleted()
                }
                
                writeSource.setEventHandler {
                    do {
                        NSLog("Event trying to connect")
                        try self.tryConnectContinue(socket)
                        completeConnection()
                    } catch POSIXError.EINPROGRESS {
                        NSLog("EINPROGRESS")
                        // If we're in progress, we'll be trying again
                    } catch let e {
                        observer.onError(e)
                    }
                }
                
                writeSource.setCancelHandler {
                    #if os(Linux)
                        Glibc.close(socket)
                    #else
                        Darwin.close(socket)
                    #endif
                }
                
                do {
                    NSLog("First trying to connect")
                    try self.tryConnect(socket)
                    completeConnection()
                } catch POSIXError.EINPROGRESS {
                    NSLog("IN PROGRESS!!!")
                    // If we're in progress, we'll be trying again
                }
                
                return AnonymousDisposable {
                    NSLog("Disposing!!!")
                    writeSource.cancel()
                }
                
            } catch let e {
                NSLog("erroring :/")
                observer.onError(e)
                return NopDisposable.instance
            }
        }
    }
    
    
    
    /// If this doesn't throw, we've connected
    private func tryConnect(_ socket: Int32) throws {
        NSLog("trying to connect")
        
        let result = self.addr.withUnsafeSockaddrPtr { ptr in
            
            #if os(Linux)
                return Glibc.connect(socket, ptr, socklen_t(self.addr.dynamicType.size))
            #else
                return Darwin.connect(socket, ptr, socklen_t(self.addr.dynamicType.size))
            #endif

        }
        
        if result != 0 {
            throw POSIXError(rawValue: errno)!
        }
    }  /// If this doesn't throw, we've connected
    private func tryConnectContinue(_ socket: Int32) throws {
        NSLog("trying to connect")
        
        var result: Int = 0
        var len = socklen_t(sizeofValue(result))
        
        let status = Darwin.getsockopt(socket, SOL_SOCKET, SO_ERROR, &result, &len)
        
        
        precondition(status == 0, "getsockopt should return zero")
        
        if result != 0 {
            throw POSIXError(rawValue: errno)!
        }
    }
    
    /// Calls socket on this and returns a socket
    public func socket() throws -> Int32 {
        let fd = Darwin.socket(self.family, self.socktype, self.proto)
        let result = fcntl(fd, F_SETFL, O_NONBLOCK);
        if result < 0 {
            throw Error.errorFromStatusCode(fd)!
        }
        
        var flag: Int = 1
        setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &flag, socklen_t(sizeofValue(flag)))

        return fd
    }
}

public func getaddrinfoSockAddrsAsync(_ hostname: String, servname: String, workQueue: DispatchQueue=DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault)) -> Observable<AddrInfo> {
    
    return Observable.create { observer in
        var ai: UnsafeMutablePointer<addrinfo>? = nil

        workQueue.async {
            do {
                defer {
                    if ai != nil {
                        freeaddrinfo(ai)
                    }
                }
                
                try Error.throwIfNotSuccess(getaddrinfo(hostname, servname, &hints, &ai))
                NSLog("OMG")
                var curAi = ai
                while curAi != nil {
                    if curAi?.pointee.ai_addr == nil {
                        curAi = curAi?.pointee.ai_next
                        continue
                    }
                    
                    guard let aiMem = curAi?.pointee else {
                        continue
                    }
                    
                    switch aiMem.ai_addr.pointee.sa_family {
                    case UInt8(AF_INET):
                        let addr = unsafeBitCast(curAi?.pointee.ai_addr, to: UnsafePointer<sockaddr_in>.self).pointee
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: aiMem.ai_socktype, proto: aiMem.ai_protocol, addr: addr))
                    case UInt8(AF_INET6):
                        let addr = unsafeBitCast(curAi?.pointee.ai_addr, to: UnsafePointer<sockaddr_in6>.self).pointee
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: aiMem.ai_socktype, proto: aiMem.ai_protocol, addr: addr))
                    default:
                        NSLog("skiping")
                        continue
                    }
                    
                    curAi = curAi?.pointee.ai_next
                }
                
                NSLog("completing")
                observer.onCompleted()
            } catch let e {
                NSLog("erroring")
                observer.onError(e)
            }
        }
        
        return NopDisposable.instance
    }
}
