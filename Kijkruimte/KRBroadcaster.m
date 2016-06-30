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
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl
														   cachePolicy:NSURLRequestReloadIgnoringCacheData
													   timeoutInterval:600];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:dictionary
                                                          options:0
                                                            error:&error];
    
    NSString* byteSizeString = [NSString stringWithFormat: @"%d", (int)requestBody.bytes];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:byteSizeString forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestBody];

	[NSURLConnection sendAsynchronousRequest:request
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   if(error) {
								   NSLog(@"REQUEST FAILED: %@", [error localizedDescription]);
							   }
						   }];
}

@end
