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
@synthesize trackId;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        trackId = [dictionary objectForKey:@"id"];
        streamUrl = [dictionary objectForKey:@"stream_url"];
    }
    return self;
}

@end
