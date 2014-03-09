//
//  SCServiceRequest.m
//  Kijkruimte
//
//  Created by James Graves on 10/24/12.
//  Copyright 2012 Hipstart. All rights reserved.
//

#import "SCServiceRequest.h"

NSString *kSCClientId = @"50ec847d33865167c22cf865c3160819";
NSString *kSCServiceAPIURL = @"http://api.soundcloud.com/";

@interface SCServiceRequest (Private)

-(void)sendAsync:(NSMutableURLRequest*)request;
-(void)sendSync:(NSMutableURLRequest*)request;

@end

@implementation SCServiceRequest

@synthesize delegate = _delegate;

-(id)init {
    if(self = [super init]) {
        _tries = 0;
    }
    return self;
}

-(void)getResponseForRequest:(NSString*)endpoint
                      method:(NSString*)method
                  parameters:(id)parameters
                    useCache:(BOOL)useCache
                        sync:(BOOL)sync {
    
    NSString *urlStr = [kSCServiceAPIURL stringByAppendingFormat:@"%@.json?client_id=%@", endpoint, kSCClientId];
    NSLog(@"REQUEST TO: %@", urlStr);
	
	[self getResponseForUrlString:urlStr
						   method:method
					   parameters:parameters
						 useCache:useCache
							 sync:sync];
}

-(void)getResponseForUrlString:(NSString*)urlStr
                      method:(NSString*)method
                  parameters:(id)parameters
                    useCache:(BOOL)useCache
                        sync:(BOOL)sync {
          
    NSURL *url = [NSURL URLWithString:urlStr];
    BOOL fromCache = [@"GET" isEqualToString:method] && useCache;

    _urlRequest = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:!fromCache ? NSURLRequestReloadIgnoringCacheData : NSURLRequestReturnCacheDataElseLoad
                                      timeoutInterval:240.0f];

    [_urlRequest setHTTPMethod:method];
    
    if(parameters != nil) {
        if([method isEqualToString:@"GET"] ||
           [method isEqualToString:@"DELETE"]) {
            NSEnumerator *enumerator = [parameters keyEnumerator];
            id key = [enumerator nextObject];
        
            for(NSInteger i = 0; key != nil; key = [enumerator nextObject], i++) {
                urlStr = [urlStr stringByAppendingFormat:@"%@%@=%@",
                          @"&",
                          key,
                          [parameters objectForKey:key]];
            }
        } else {
            NSError *error;
            NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters
                                                                   options:0
                                                                     error:&error];
            
            NSString* byteSizeString = [NSString stringWithFormat: @"%d", (int)requestBody.bytes];
            [_urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [_urlRequest setValue:byteSizeString forHTTPHeaderField:@"Content-Length"];
            [_urlRequest setHTTPBody:requestBody];
        }
	}
    
    url = [NSURL URLWithString:urlStr];
    [_urlRequest setURL:url];
    NSLog(@"URL is %@", [_urlRequest.URL absoluteString]);
    if(!sync) {
        [self sendAsync:_urlRequest];
    } else {
        [self sendSync:_urlRequest];
    }
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {	
    _statusCode = [((NSHTTPURLResponse *)response) statusCode];
    NSLog(@"RESPONSE RECEIVED: %d", _statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
    NSLog(@"Got some data. . .");
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    if(_tries < 10) {
        NSLog(@"Trying request again...");
        ++_tries;
        [self sendAsync:_urlRequest];
    } else {
        [_delegate handleError:@"Request failed"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_statusCode == 200) {        
        NSError *error;
        id obj = [NSJSONSerialization
                  JSONObjectWithData:_receivedData
                  options:NSJSONReadingMutableContainers
                  error:&error];
        NSString *response = [NSString stringWithUTF8String:[_receivedData bytes]];
        if(nil != response)
            NSLog(@"%@", response);
        if(obj)
            [_delegate handleResponse:obj];
        else {
            NSString *response = [NSString stringWithUTF8String:[_receivedData bytes]];
            [_delegate handleError:
             [NSString stringWithFormat:@"Mangled response: %@", response]];
        }
    } else {
        [_delegate handleError:
         [NSString stringWithFormat:@"Server returned: %d", _statusCode]];
    }
}

# pragma mark -
# pragma mark SCServiceRequest (Private)

-(void)sendAsync:(NSMutableURLRequest*)urlRequest {
    NSLog(@"ASYNC REQUEST");
    NSURLConnection* urlConnection = [NSURLConnection connectionWithRequest:urlRequest
                                                                   delegate:self];
    if (urlConnection) {
        _receivedData = [[NSMutableData alloc] init];
    } else {
        [_delegate handleError:@"Request could not be made."];
    }
}

-(void)sendSync:(NSMutableURLRequest*)urlRequest {
    NSLog(@"SYNC REQUEST");
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* receivedData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                 returningResponse:&response error:&error];
    if(error != nil) {
        if (_delegate && [_delegate respondsToSelector:@selector(handleError:)]) {
            [_delegate handleError:[error description]];
        }
    } else {
        _receivedData = [[NSMutableData alloc] initWithData:receivedData];
        _statusCode = ((NSHTTPURLResponse*)response).statusCode;
        NSLog(@"RESPONSE RECEIVED: %d", _statusCode);
        [self connectionDidFinishLoading:nil];
    }
}

@end
