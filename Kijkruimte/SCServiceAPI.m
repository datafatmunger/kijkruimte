//
//  SCServiceAPI.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "SCServiceAPI.h"

@implementation SCServiceAPI

@synthesize sync = _sync;

- (id)init
{
    self = [super init];
    if (self) {
        _sync = NO;
    }
    
    return self;
}

@end
