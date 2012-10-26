//
//  KRGetTrackDetail.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "SCGetTrackDetail.h"

@implementation SCGetTrackDetail

@synthesize delegate = _delegate;

-(void)getTrackDetail:(NSString*)trackId {
    SCServiceRequest *request = [[SCServiceRequest alloc] init];
    request.delegate = self;
    [request getResponseForRequest:[NSString stringWithFormat:@"tracks/%@", trackId]
                            method:@"GET"
                        parameters:nil
                          useCache:NO
                              sync:_sync];
}

# pragma mark -
# pragma SCGetUserTracksDelegate

-(void)handleResponse:(id)obj {
    KRTrackDetail *detail = [[KRTrackDetail alloc] init];
    detail.streamUrl = [obj objectForKey:@"stream_url"];
    [_delegate handleDetail:detail];
}

-(void)handleError:(NSString*)message {
    [_delegate handleGetDetailError:message];
}

@end
