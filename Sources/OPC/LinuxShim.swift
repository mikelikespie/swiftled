//
//  SimdShim.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 7/20/16.
//  Copyright © 2016 Lolrus Industries. All rights reserved.
//


#if os(Linux)

public struct float3  {
    public var x: Float
    
    public var y: Float
    
    public var z: Float
    
    /// Initialize to the zero vector.
    public init() {
        self.init(0,0,0)
    }
    
    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public func + (lhs: float3, rhs: float3) -> float3 {
    return float3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

public func * (lhs: float3, rhs: Float) -> float3 {
    return float3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
}


public func * (lhs: float3, rhs: float3) -> float3 {
    return float3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
}


public func distance_squared(_ lhs: float3, _ rhs: float3) -> Float {
    let (xd, yd, zd) = (lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    return xd * xd +
        yd * yd +
        zd * zd
}

public func clamp(_ lhs: float3, min min_: Float, max max_: Float) -> float3 {
    return float3(
        max(min(lhs.x, max_), min_),
        max(min(lhs.y, max_), min_),
        max(min(lhs.z, max_), min_)
    )
}

public func min(_ lhs: float3, _ rhs: Float) -> float3 {
    return float3(min(rhs, lhs.x), min(rhs, lhs.y), min(rhs, lhs.z))
}

#endif

#if os(Linux)


public enum POSIXErrorCode : CInt {
    case EDEADLK = 35
    case ENAMETOOLONG = 36
    case ENOLCK = 37
    case ENOSYS = 38
    case ENOTEMPTY = 39
    case ELOOP = 40
//    case EWOULDBLOCK = EAGAIN
    case ENOMSG = 42
    case EIDRM = 43
    case ECHRNG = 44
    case EL2NSYNC = 45
    case EL3HLT = 46
    case EL3RST = 47
    case ELNRNG = 48
    case EUNATCH = 49
    case ENOCSI = 50
    case EL2HLT = 51
    case EBADE = 52
    case EBADR = 53
    case EXFULL = 54
    case ENOANO = 55
    case EBADRQC = 56
    case EBADSLT = 57
//    case EDEADLOCK = EDEADLK
    case EBFONT = 59
    case ENOSTR = 60
    case ENODATA = 61
    case ETIME = 62
    case ENOSR = 63
    case ENONET = 64
    case ENOPKG = 65
    case EREMOTE = 66
    case ENOLINK = 67
    case EADV = 68
    case ESRMNT = 69
    case ECOMM = 70
    case EPROTO = 71
    case EMULTIHOP = 72
    case EDOTDOT = 73
    case EBADMSG = 74
    case EOVERFLOW = 75
    case ENOTUNIQ = 76
    case EBADFD = 77
    case EREMCHG = 78
    case ELIBACC = 79
    case ELIBBAD = 80
    case ELIBSCN = 81
    case ELIBMAX = 82
    case ELIBEXEC = 83
    case EILSEQ = 84
    case ERESTART = 85
    case ESTRPIPE = 86
    case EUSERS = 87
    case ENOTSOCK = 88
    case EDESTADDRREQ = 89
    case EMSGSIZE = 90
    case EPROTOTYPE = 91
    case ENOPROTOOPT = 92
    case EPROTONOSUPPORT = 93
    case ESOCKTNOSUPPORT = 94
    case EOPNOTSUPP = 95
    case EPFNOSUPPORT = 96
    case EAFNOSUPPORT = 97
    case EADDRINUSE = 98
    case EADDRNOTAVAIL = 99
    case ENETDOWN = 100
    case ENETUNREACH = 101
    case ENETRESET = 102
    case ECONNABORTED = 103
    case ECONNRESET = 104
    case ENOBUFS = 105
    case EISCONN = 106
    case ENOTCONN = 107
    case ESHUTDOWN = 108
    case ETOOMANYREFS = 109
    case ETIMEDOUT = 110
    case ECONNREFUSED = 111
    case EHOSTDOWN = 112
    case EHOSTUNREACH = 113
    case EALREADY = 114
    case EINPROGRESS = 115
    case ESTALE = 116
    case EUCLEAN = 117
    case ENOTNAM = 118
    case ENAVAIL = 119
    case EISNAM = 120
    case EREMOTEIO = 121
    case EDQUOT = 122
    case ENOMEDIUM = 123
    case EMEDIUMTYPE = 124
    case ECANCELED = 125
    case ENOKEY = 126
    case EKEYEXPIRED = 127
    case EKEYREVOKED = 128
    case EKEYREJECTED = 129
    case EOWNERDEAD = 130
    case ENOTRECOVERABLE = 131
    case ERFKILL = 132
    case EHWPOISON = 133
}

    public func arc4random() ->  UInt32 {
        return UInt32(Glibc.random())
    }

#endif
