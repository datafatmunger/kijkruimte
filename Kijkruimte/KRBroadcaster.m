//
//  KRBroadcaster.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 11/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRBroadcaster.h"

@implementation KRBroadcaster

#pragma mark Singleton Methods

+(id)sharedBroadcaster {
	static KRBroadcaster *sharedBroadcaster = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedBroadcaster = [[self alloc] init];
	});
	return sharedBroadcaster;
}

-(void)broadcastTrack:(NSDictionary*)dictionary {
    NSLog(@"Broadcasting...");
    
    NSString* resourcePath = @"http://api.hearushere.nl/listeners";
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

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"REQUEST FAILED: %@", [error localizedDescription]);
}

@end
