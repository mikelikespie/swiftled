//
//  Shims.swift
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//

import Foundation

@_silgen_name("fcntl")
public func shim_fcntl(fildes: Int32, _ cmd: Int32, _ flags: Int32) -> Int32
