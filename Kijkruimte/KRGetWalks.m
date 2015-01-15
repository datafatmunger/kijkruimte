//
//  KRGetWalks.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRWalk.h"
#import "KRGetWalks.h"

@implementation KRGetWalks

@synthesize delegate = _delegate;

-(void)getWalks {
    SCServiceRequest *request = [[SCServiceRequest alloc] init];
    request.delegate = self;
	
    [request getResponseForUrlString:@"http://api.hearushere.nl/walks"
                            method:@"GET"
                        parameters:nil
                          useCache:NO
                              sync:_sync];
}

# pragma mark -
# pragma SCServiceRequestDelegate

-(void)handleResponse:(id)obj {
    NSMutableArray *walks = [[NSMutableArray alloc] init];
    NSArray *walksObjs = (NSArray*)obj;
    for(NSDictionary *walkDict in walksObjs) {
		KRWalk *walk = [[KRWalk alloc] initWithDictionary:walkDict];
		[walks addObject:walk];
    }
    [_delegate handleWalks:walks];
}

-(void)handleError:(NSString*)message {
    [_delegate handleGetWalksError:message];
}

@end
