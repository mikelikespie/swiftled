//
//  Net.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import Darwin
import RxSwift
import Dispatch
import Foundation

private var hints: addrinfo = {
    var hints = addrinfo()
    hints.ai_family = PF_UNSPEC
    hints.ai_socktype = SOCK_STREAM
    return hints
}()

// Wrapped addrinfo
public struct AddrInfo {
    let family: Int32
    let socktype: Int32
    let proto: Int32
    let addr: SockAddr
}

extension AddrInfo {
    public func connect(workQueue: dispatch_queue_t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) -> Observable<dispatch_fd_t> {
        return create { observer in
            do {
                let socket = try self.socket()
                precondition(socket >= 0)
                
                let writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, UInt(socket), 0, workQueue);
                
                dispatch_resume(writeSource);
                NSLog("STARTING")
                
                func completeConnection() {
                    // If we got this far, we are successful!
                    // Clear out the close handler, thsi means somebody else will own the socket after this
                    
                    NSLog("COMPLETING CONNECTION")
                    dispatch_suspend(writeSource)
                    dispatch_source_set_cancel_handler(writeSource)  { }
                    dispatch_resume(writeSource)
                    
                    observer.onNext(socket)
                    observer.onCompleted()
                }
                
                dispatch_source_set_event_handler(writeSource) {
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
                
                dispatch_source_set_cancel_handler(writeSource) {
                    Darwin.close(socket)
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
                    dispatch_source_cancel(writeSource)
                }
                
            } catch let e {
                NSLog("erroring :/")
                observer.onError(e)
                return NopDisposable.instance
            }
        }
    }
    
    
    
    /// If this doesn't throw, we've connected
    private func tryConnect(socket: dispatch_fd_t) throws {
        NSLog("trying to connect")
        
        let result = self.addr.withUnsafeSockaddrPtr { ptr in
            Darwin.connect(socket, ptr, socklen_t(self.addr.dynamicType.size))
        }
        
        if result != 0 {
            throw POSIXError(rawValue: errno)!
        }
    }  /// If this doesn't throw, we've connected
    private func tryConnectContinue(socket: dispatch_fd_t) throws {
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
    public func socket() throws -> dispatch_fd_t {
        let fd = Darwin.socket(self.family, self.socktype, self.proto)
        let result = shim_fcntl(fd, F_SETFL, O_NONBLOCK);
        if result < 0 {
            throw Error.errorFromStatusCode(fd)!
        }
        
        var flag: Int = 1
        setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, &flag, socklen_t(sizeofValue(flag)))

        return fd
    }
}

public func getaddrinfoSockAddrsAsync(hostname: String, servname: String, workQueue: dispatch_queue_t=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) -> Observable<AddrInfo> {
    
    return create { observer in
        var ai: UnsafeMutablePointer<addrinfo> = nil

        dispatch_async(workQueue) {
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
                    if curAi.memory.ai_addr == nil {
                        curAi = curAi.memory.ai_next
                        continue
                    }
                    
                    let aiMem = curAi.memory
                    
                    switch aiMem.ai_addr.memory.sa_family {
                    case UInt8(AF_INET):
                        let addr = unsafeBitCast(curAi.memory.ai_addr, UnsafePointer<sockaddr_in>.self).memory
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: aiMem.ai_socktype, proto: aiMem.ai_protocol, addr: addr))
                    case UInt8(AF_INET6):
                        let addr = unsafeBitCast(curAi.memory.ai_addr, UnsafePointer<sockaddr_in6>.self).memory
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: aiMem.ai_socktype, proto: aiMem.ai_protocol, addr: addr))
                    default:
                        NSLog("skiping")
                        continue
                    }
                    
                    curAi = curAi.memory.ai_next
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