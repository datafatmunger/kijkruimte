//
//  SCServiceRequest.h
//  Kijkruimte
//
//  Created by James Graves on 10/24/12.
//  Copyright 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kSCClientId;
extern NSString* kSCServiceAPIURL;

@protocol SCServiceRequestDelegate <NSObject>

-(void)handleResponse:(id)obj;
-(void)handleError:(NSString*)message;

@end

@interface SCServiceRequest : NSObject {
    id<SCServiceRequestDelegate> _delegate;
    NSMutableData *_receivedData;
    NSInteger _statusCode;
    
    NSMutableURLRequest *_urlRequest;
    
    NSInteger _tries;
}

@property(nonatomic,strong)id<SCServiceRequestDelegate> delegate;

-(void)getResponseForRequest:(NSString*)endpoint
                      method:(NSString*)method
                  parameters:(id)parameters
                    useCache:(BOOL)useCache
                        sync:(BOOL)sync;

-(void)getResponseForUrlString:(NSString*)urlStr
						method:(NSString*)method
					parameters:(id)parameters
					  useCache:(BOOL)useCache
						  sync:(BOOL)sync;
@end
