//
//  SCServiceRequest.m
//  Kijkruimte
//
//  Created by James Graves on 10/24/12.
//  Copyright 2012 Hipstart. All rights reserved.
//

#import "SCServiceRequest.h"

NSString *kSCClientId = @"e23538a05aaedb1af2e1b6b6ce613f8c";
NSString *kSCServiceAPIURL = @"http://api.soundcloud.com/";

@implementation SCServiceRequest

@synthesize delegate = _delegate;

-(void)getResponseForRequest:(NSString*)endpoint
                      method:(NSString*)method
                  parameters:(id)parameters
                    useCache:(BOOL)useCache
                        sync:(BOOL)sync {
    
    NSString *urlStr = [kSCServiceAPIURL stringByAppendingFormat:@"%@.json?client_id=%@", endpoint, kSCClientId];
    NSLog(@"REQUEST TO: %@", urlStr);
          
    NSURL *url = [NSURL URLWithString:urlStr];

    BOOL fromCache = [@"GET" isEqualToString:method] && useCache;

    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:!fromCache ? NSURLRequestReloadIgnoringCacheData : NSURLRequestReturnCacheDataElseLoad
                        timeoutInterval:240.0f];

    [urlRequest setHTTPMethod:method];
    
    if(parameters != nil) {
        if([method isEqualToString:@"GET"] ||
           [method isEqualToString:@"DELETE"]) {
            NSEnumerator *enumerator = [parameters keyEnumerator];
            id key = [enumerator nextObject];
        
            for(NSInteger i = 0; key != nil; key = [enumerator nextObject], i++) {
                endpoint = [endpoint stringByAppendingFormat:@"%@%@=%@",
                            i == 0 ? @"?" : @"&",
                            key,
                            [parameters objectForKey:key]];
            }
        } else {
            NSError *error;
            NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters
                                                                   options:0
                                                                     error:&error];
            
            NSString* byteSizeString = [NSString stringWithFormat: @"%d", (int)requestBody.bytes];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [urlRequest setValue:byteSizeString forHTTPHeaderField:@"Content-Length"];
            [urlRequest setHTTPBody:requestBody];
        }
	}
    
    NSLog(@"URL is %@", urlStr);
  
    if(!sync) {
        NSLog(@"ASYNC REQUEST");
        NSURLConnection* urlConnection = [NSURLConnection connectionWithRequest:urlRequest
                                                                       delegate:self];
        if (urlConnection) {
            _receivedData = [[NSMutableData alloc] init];
        } else {
            [_delegate handleError:@"Request could not be made."];
        }
    } else {
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
    [_delegate handleError:@"Request failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_statusCode == 200) {        
        NSError *error;
        id obj = [NSJSONSerialization
                  JSONObjectWithData:_receivedData
                  options:NSJSONReadingMutableContainers
                  error:&error];
        NSString *response = [NSString stringWithUTF8String:[_receivedData bytes]];
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

@end
