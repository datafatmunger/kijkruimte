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

@end

@implementation KRTrack

@synthesize location;
@synthesize trackId;
@synthesize uri;
@synthesize title;
@synthesize audioPlayer;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        audioPlayer = nil;
        _audioData = [[NSMutableData alloc] init];
        
        trackId = [dictionary objectForKey:@"id"];
        uri = [dictionary objectForKey:@"uri"];
        title = [dictionary objectForKey:@"title"];
        
        NSString *tagList = [dictionary objectForKey:@"tag_list"];
        NSArray *tags = [tagList componentsSeparatedByString:@" "];
        
        CLLocationDegrees lat = 0.0;
        CLLocationDegrees lng = 0.0;
        
        for(NSString *tag in tags) {
            if([tag rangeOfString:@"lat"].location != NSNotFound) {
                lat = [self getNumber:tag];
            } else if([tag rangeOfString:@"lon"].location != NSNotFound)
                lng = [self getNumber:tag];
        }
        location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
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
    NSString *filename = [NSString stringWithFormat:@"%d.mp3", [trackId intValue]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *songFile = [documentsDirectory stringByAppendingPathComponent:filename];
    return songFile;
}

-(void)getData:(KRTrackDetail*)detail {
    
    //Check the cache - JBG
    NSString *songFile = [self getFilename];
    NSLog(@"Song file is: %@", songFile);
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:songFile]) {
        NSLog(@"Needs to GET file from soundcloud");
        NSString* resourcePath = [NSString stringWithFormat:@"%@?client_id=%@", detail.streamUrl, kSCClientId];
        NSURL *originalUrl = [NSURL URLWithString:resourcePath];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:10];
        [NSURLConnection connectionWithRequest:request
                                      delegate:self];
    } else {
        NSLog(@"Track coming from CACHE");
        _audioData = [NSData dataWithContentsOfFile:songFile];
        [self createPlayer];
    }
}

-(void)createPlayer {
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:_audioData error:&error];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.volume = 1.0f;
}

#pragma mark - 
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"SOUND DATA RESPONSE RECEIVED: %d", [((NSHTTPURLResponse *)response) statusCode]);
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [_audioData appendData:data];
    NSLog(@"Got some audio data. . .");
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Request FAILED: %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self createPlayer];
    NSString *songFile = [self getFilename];
    [_audioData writeToFile:songFile atomically:YES];
}

@end
