//
//  SCTrack.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrack.h"
#import "SCServiceRequest.h"

@interface KRTrack (Private)

-(CLLocationDegrees)getNumber:(NSString*)tag;
-(void)sendAsync:(NSMutableURLRequest*)request;

@end

@implementation KRTrack

@synthesize location = _location;
@synthesize trackId = _trackId;
@synthesize uri = _uri;
@synthesize title = _title;
@synthesize audioPlayer = _audioPlayer;
@synthesize pin = _pin;
@synthesize delegate = _delegate;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        _pin = nil;
        _audioPlayer = nil;
        _audioData = [[NSMutableData alloc] init];
        
        _trackId = [dictionary objectForKey:@"id"];
        _uri = [dictionary objectForKey:@"uri"];
        _title = [dictionary objectForKey:@"title"];
        
        NSString *tagList = [dictionary objectForKey:@"tag_list"];
        NSArray *tags = [tagList componentsSeparatedByString:@" "];
        
        CLLocationDegrees lat = 0.0;
        CLLocationDegrees lng = 0.0;
        
        for(NSString *tag in tags) {
            if([tag rangeOfString:@"lat"].location != NSNotFound) {
                lat = [self getNumber:tag];
            } else if([tag rangeOfString:@"lon"].location != NSNotFound) {
                lng = [self getNumber:tag];
			} else if([tag rangeOfString:@"radius"].location != NSNotFound) {
				_radius = [self getNumber:tag];
			} else if([tag rangeOfString:@"bluetooth"].location != NSNotFound) {
				_bluetooth = YES;
			} else if([tag rangeOfString:@"background"].location != NSNotFound) {
				_background = YES;
			}
        }
        _location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    return self;
}

-(CLLocationDegrees)getNumber:(NSString*)tag {
    NSMutableString *numberStr = [NSMutableString
                                  stringWithCapacity:tag.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:tag];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789."];
    
    while (![scanner isAtEnd]) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
            [numberStr appendString:buffer];
        else
            [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
    
    return [numberStr doubleValue];
}

-(NSString*)getFilename {
    NSString *filename = [NSString stringWithFormat:@"%d.mp3", [_trackId intValue]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *songFile = [documentsDirectory stringByAppendingPathComponent:filename];
    return songFile;
}

-(void)getData:(KRTrackDetail*)detail {
    
    //Check the cache - JBG
    NSString *songFile = [self getFilename];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:songFile]) {
        NSString* resourcePath = [NSString stringWithFormat:@"%@?client_id=%@", detail.streamUrl, kSCClientId];
        NSLog(@"REQUEST URL: %@", resourcePath);
        NSURL *originalUrl = [NSURL URLWithString:resourcePath];
        
        _request = [NSMutableURLRequest requestWithURL:originalUrl
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:600];
        [self sendAsync:_request];
    } else {
        _audioData = [NSData dataWithContentsOfFile:songFile];
        [self createPlayer];
        _audioData = nil;
    }
}

-(void)createPlayer {
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:_audioData error:&error];
    _audioPlayer.numberOfLoops = -1;
    _audioPlayer.volume = 1.0f;
    _audioPlayer.delegate = self;
    
    [_delegate trackDataLoaded:_trackId];
}

#pragma mark - 
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [_audioData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    if(_tries < 10) {
        [self sendAsync:_request];
    } else {
        NSLog(@"Request FAILED: %@, %@",
              [error localizedDescription],
              [[_request URL] absoluteString]);
        [_delegate trackDataError:@"FAILED to download audio."];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self createPlayer];
    NSString *songFile = [self getFilename];
    [_audioData writeToFile:songFile atomically:YES];
    _audioData = nil;
}

-(NSURLRequest*)connection:(NSURLConnection*)inConnection
           willSendRequest:(NSURLRequest*)inRequest
          redirectResponse:(NSURLResponse*)inRedirectResponse {
    NSLog(@"REDIRECT: %@", [[inRequest URL] absoluteString]);
    return inRequest;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

-(void)audioPlayerBeginInterruption:(AVAudioPlayer*)player {
    [player stop];
    
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer*)player {
    [player play];
}

#pragma mark -
#pragma mark KRTrack (Private)

-(void)sendAsync:(NSMutableURLRequest*)request {
    [NSURLConnection connectionWithRequest:request
                                  delegate:self];
}

@end
