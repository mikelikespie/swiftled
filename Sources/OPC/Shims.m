//
//  Shims.m
//  SwiftledMobile
//
//  Created by Michael Lewis on 12/29/15.
//  Copyright © 2015 Lolrus Industries. All rights reserved.
//
#import <sys/fcntl.h>

extern int shim_fcntl(int fildes, int cmd, int flags);

extern int shim_fcntl(int fildes, int cmd, int flags) {
    return fcntl(fildes, cmd, flags);
}
