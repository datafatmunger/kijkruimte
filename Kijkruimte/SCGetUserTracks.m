//
//  SCGetUserTracks.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrack.h"
#import "SCGetUserTracks.h"

@implementation SCGetUserTracks

@synthesize delegate = _delegate;

-(void)getTracks:(NSString*)username {    
    SCServiceRequest *request = [[SCServiceRequest alloc] init];
    request.delegate = self;
    [request getResponseForRequest:[NSString stringWithFormat:@"users/%@/tracks", username]
                            method:@"GET"
                        parameters:@{ @"limit": @"100" }
                          useCache:NO
                              sync:_sync];
}

# pragma mark -
# pragma SCServiceRequestDelegate

-(void)handleResponse:(id)obj {
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    NSArray *trackObjs = (NSArray*)obj;
    for(NSDictionary *trackDict in trackObjs) {
        KRTrack *track = [[KRTrack alloc] initWithDictionary:trackDict];
        [tracks addObject:track];
    }
    [_delegate handleTracks:tracks];
}

-(void)handleError:(NSString*)message {
    [_delegate handleGetTracksError:message];
}


@end
