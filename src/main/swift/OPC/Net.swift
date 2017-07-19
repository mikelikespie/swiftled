//
//  Net.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//




#if os(Linux)
    import Glibc
#else
    import Darwin
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
    public func connect(_ workQueue: DispatchQueue=DispatchQueue.global()) -> Observable<Int32> {
        return Observable.create { observer in
            do {
                let socket = try self.socket()
                precondition(socket >= 0)
                
                let writeSource = DispatchSource.makeWriteSource(fileDescriptor: socket, queue: workQueue);
  
       
                let closeItem = DispatchWorkItem {
                    #if os(Linux)
                        Glibc.close(socket)
                    #else
                        NSLog("CLOSING")
                        Darwin.close(socket)
                    #endif
                }
                
                
                func completeConnection() {
                    // If we got this far, we are successful!
                    // Clear out the close handler, thsi means somebody else will own the socket after this
                    
                    NSLog("COMPLETING CONNECTION")
                    writeSource.suspend()
                    closeItem.cancel()
                    writeSource.resume()
                    
                    observer.onNext(socket)
                    observer.onCompleted()
                }
                
                writeSource.setCancelHandler(handler: closeItem)

                writeSource.setEventHandler {
                    do {
                        NSLog("Event trying to connect")
                        try self.tryConnectContinue(socket)
                        completeConnection()
                    } catch POSIXErrorCode.EINPROGRESS {
                        NSLog("EINPROGRESS")
                        // If we're in progress, we'll be trying again
                    } catch let e {
                        observer.onError(e)
                    }
                }
                
                writeSource.resume();
                
                NSLog("STARTING")
                

                do {
                    NSLog("First trying to connect")
                    try self.tryConnect(socket)
                    completeConnection()
                } catch POSIXErrorCode.EINPROGRESS {
                    NSLog("IN PROGRESS!!!")
                    // If we're in progress, we'll be trying again
                }
                
                return Disposables.create {
                    NSLog("Disposing!!!")
                    writeSource.cancel()
                }
                
            } catch let e {
                NSLog("erroring :/")
                observer.onError(e)
                return Disposables.create()
            }
        }
    }
    
    
    
    /// If this doesn't throw, we've connected
    private func tryConnect(_ socket: Int32) throws {
        NSLog("trying to connect")
        
        let result = self.addr.withUnsafeSockaddrPtr { ptr -> Int32 in
            
            #if os(Linux)
                return Glibc.connect(socket, ptr, socklen_t(type(of: self.addr).size))
            #else
                return Darwin.connect(socket, ptr, socklen_t(type(of: self.addr).size))
            #endif

        }
        
        if result != 0 {
            throw POSIXErrorCode(rawValue: errno)!
        }
    }
    
    /// If this doesn't throw, we've connected
    private func tryConnectContinue(_ socket: Int32) throws {
        NSLog("trying to connect")
        
        var result: Int = 0
        var len = socklen_t(MemoryLayout.size(ofValue: result))
        

        let status = getsockopt(socket, SOL_SOCKET, SO_ERROR, &result, &len)
        
        precondition(status == 0, "getsockopt should return zero")
        
        if result != 0 {
            throw POSIXErrorCode(rawValue: errno)!
        }
    }
    
    /// Calls socket on this and returns a socket
    public func socket() throws -> Int32 {
        #if os(Linux)
            let fd = Glibc.socket(self.family, Int32(self.socktype.rawValue), self.proto)
        #else
            let fd = Darwin.socket(self.family, self.socktype, self.proto)
        #endif
        let result = fcntl(fd, F_SETFL, O_NONBLOCK);
        if result < 0 {
            throw Error.errorFromStatusCode(fd)!
        }
        
        var flag: Int = 1
        setsockopt(fd, Int32(IPPROTO_TCP), TCP_NODELAY, &flag, socklen_t(MemoryLayout.size(ofValue: flag)))

        return fd
    }
}

public func getaddrinfoSockAddrsAsync(_ hostname: String, servname: String, workQueue: DispatchQueue=DispatchQueue.global()) ->  Observable<AddrInfo> {
    
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
                var curAi = ai
                while curAi != nil {
                    if curAi?.pointee.ai_addr == nil {
                        curAi = curAi?.pointee.ai_next
                        continue
                    }
                    
                    guard let aiMem = curAi?.pointee else {
                        continue
                    }
                    
                    #if os(Linux)
                        let socktype = __socket_type(UInt32(aiMem.ai_socktype))
                    #else
                        let socktype = aiMem.ai_socktype
                    #endif
                    
                    switch aiMem.ai_addr.pointee.sa_family {
                    case sa_family_t(AF_INET):
                        let addr = unsafeBitCast(curAi?.pointee.ai_addr, to: UnsafePointer<sockaddr_in>.self).pointee
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: socktype, proto: aiMem.ai_protocol, addr: addr))
                    case sa_family_t(AF_INET6):
                        let addr = unsafeBitCast(curAi?.pointee.ai_addr, to: UnsafePointer<sockaddr_in6>.self).pointee
                        observer.onNext(AddrInfo(family: aiMem.ai_family, socktype: socktype, proto: aiMem.ai_protocol, addr: addr))
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
        
        return Disposables.create()
    }
}
