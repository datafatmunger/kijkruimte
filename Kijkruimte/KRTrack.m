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

-(float)getNumber:(NSString*)tag;

@end

@implementation KRTrack

@synthesize trackId;
@synthesize uri;
@synthesize lat;
@synthesize lng;
@synthesize audioPlayer;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        trackId = [dictionary objectForKey:@"id"];
        uri = [dictionary objectForKey:@"uri"];
        
        NSString *tagList = [dictionary objectForKey:@"tag_list"];
        NSArray *tags = [tagList componentsSeparatedByString:@" "];
        for(NSString *tag in tags) {
            if([tag rangeOfString:@"lat"].location != NSNotFound)
                lat = [NSNumber numberWithFloat:[self getNumber:tag]];
            else if([tag rangeOfString:@"lon"].location != NSNotFound)
                lng = [NSNumber numberWithFloat:[self getNumber:tag]];

        }
    }
    return self;
}

-(float)getNumber:(NSString*)tag {
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
    
    NSLog(@"%@", numberStr);
    
    return [numberStr floatValue];
}

-(void)createPlayer:(KRTrackDetail*)detail {
    
    NSString* resourcePath = [NSString stringWithFormat:@"%@?client_id=%@", detail.streamUrl, kSCClientId];
    NSURL *originalUrl = [NSURL URLWithString:resourcePath];
    
    NSData *data = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:originalUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    NSURLResponse *response;
    NSError *error;
    data = [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:&response
                                             error:&error];
    NSURL *redirectURL = [response URL];
    NSLog(@"Playing: %@", [redirectURL absoluteString]);
    
    NSData *songFile = [[NSData alloc] initWithContentsOfURL:redirectURL
                                                     options:NSDataReadingMappedIfSafe
                                                       error:&error];
    NSLog(@"got some data: %d", [songFile length]);
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:songFile error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.volume = 1.0f;
    
}

-(void)start {
    if(nil != audioPlayer)
        [audioPlayer play];
}

@end
