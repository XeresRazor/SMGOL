//
//  Socket.swift
//  SMGOL
//
//  Created by David Green on 1/31/16.
//  Copyright © 2016 Digital Worlds Entertainment. All rights reserved.
//

import Foundation

#if os(OSX)
import Darwin.C
    #else
    import Glibc
#endif

private func valueForSocketDomain(domain: Socket.SocketDomain) -> Int32 {
    switch domain {
    case .ip:
        return AF_INET
    case .ipv6:
        return AF_INET6
    }
}

private func valueForSocketType(type: Socket.SocketType) -> Int32 {
    switch type {
    case .Stream:
        return SOCK_STREAM
    case .Datagram:
        return SOCK_DGRAM
    }
}

public class Socket {
    public enum SocketDomain {
        case ip
        case ipv6
    }
    
    public enum SocketType {
        case Stream
        case Datagram
    }
    
    private var _socket : Int32 = 0
    private var domain : SocketDomain
    private var type : SocketType
    
    public init(domain _domain: SocketDomain, type _type: SocketType) {
        domain = _domain
        type = _type
    }
    
    func open(port: UInt16) -> Bool {
        assert(!isOpen())
        
        // Create the socket
        _socket = socket(valueForSocketDomain(domain), valueForSocketType(type), 0)
        
        if _socket <= 0 {
            print("Failed to create socket")
            _socket = 0
            return false
        }
        
        // Bind to port
        var address = sockaddr_in()
        address.sin_family = sa_family_t(valueForSocketDomain(domain))
        address.sin_addr.s_addr = 0
        address.sin_port = htons(port)
    }
    
    func isOpen() -> Bool {
        return _socket != 0
    }
    
}

public struct Address {
    let address : UInt32
    let port : UInt16
    
    init() {
        address = 0
        port = 0
    }
    
    init(a: UInt8, b: UInt8, c: UInt8, d: UInt8, port _port: UInt16) {
        address = (UInt32(a) << 24) | (UInt32(b) << 16) | (UInt32(c) << 8) | UInt32(d)
        port = _port
    }
    
    init(address _address: UInt32, port _port: UInt16) {
        address = _address
        port = _port
    }
    
    var a : UInt8 {
        get {
            return UInt8(address >> 24)
        }
    }
    
    var b : UInt8 {
        get {
            return UInt8(address >> 16)
        }
    }
    
    var c : UInt8 {
        get {
            return UInt8(address >> 8)
        }
    }
    
    var d : UInt8 {
        get {
            return UInt8(address)
        }
    }
}

func == (left: Address, right: Address) -> Bool {
    return left.address == right.address && left.port == right.port
}

func != (left: Address, right: Address) -> Bool {
    return !(left == right)
}
