//
//  KRBroadcaster.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 11/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRBroadcaster.h"

@implementation KRBroadcaster

-(void)broadcastTrack:(NSDictionary*)dictionary {
    NSLog(@"Broadcasting...");
    
    NSString* resourcePath = @"http://ec2-54-246-7-149.eu-west-1.compute.amazonaws.com/listeners";
    NSURL *originalUrl = [NSURL URLWithString:resourcePath];
    
    _request = [NSMutableURLRequest requestWithURL:originalUrl
                                       cachePolicy:NSURLRequestReloadIgnoringCacheData
                                   timeoutInterval:600];
    [_request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:dictionary
                                                          options:0
                                                            error:&error];
    
    NSString* byteSizeString = [NSString stringWithFormat: @"%d", (int)requestBody.bytes];
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_request setValue:byteSizeString forHTTPHeaderField:@"Content-Length"];
    [_request setHTTPBody:requestBody];
    
    [NSURLConnection connectionWithRequest:_request
                                  delegate:self];
}

@end
