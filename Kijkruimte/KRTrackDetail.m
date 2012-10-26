//
//  KRTrackDetail.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrackDetail.h"

@implementation KRTrackDetail

@synthesize streamUrl;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        streamUrl = [dictionary objectForKey:@"streamUrl"];
    }
    return self;
}

@end
