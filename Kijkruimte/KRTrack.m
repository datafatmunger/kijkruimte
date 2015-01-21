//
//  SCTrack.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrack.h"
#import "SCServiceRequest.h"

#define FILTER_SAMPLES 5

@interface KRTrack (Private)

-(CLLocationDegrees)getNumber:(NSString*)tag;
-(void)sendAsync:(NSMutableURLRequest*)request;

@end

@implementation KRTrack {
	double volumes[FILTER_SAMPLES];
	long volumeCount;
}

@synthesize location = _location;
@synthesize trackId = _trackId;
@synthesize uri = _uri;
@synthesize title = _title;
@synthesize audioPlayer = _audioPlayer;
@synthesize audioData = _audioData;
@synthesize pin = _pin;
@synthesize delegate = _delegate;

- (id)init {
	if (self) {
		self.pin = nil;
		self.audioPlayer = nil;
		self.audioData = [[NSMutableData alloc] init];
		
		volumeCount = 0;
	}
	return self;
}

- (id)initWithSound:(KRSound*)sound {
	self = [self init];
	if (self) {
		self.trackId = sound.soundId;
		self.location = sound.location;
		self.radius = sound.radius;
		self.background = sound.background;
		self.bluetooth = sound.bluetooth;
		self.uuid = sound.uuid;
		self.major = sound.major;
		self.minor = sound.minor;
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
    NSString *filename = [NSString stringWithFormat:@"%@", _trackId];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *songFile = [documentsDirectory stringByAppendingPathComponent:filename];
    return songFile;
}

-(void)getDataWithSound:(KRSound*)sound {
	//Check the cache - JBG
	NSString *songFile = [self getFilename];
	if(![[NSFileManager defaultManager] fileExistsAtPath:songFile]) {
		NSLog(@"REQUEST URL: %@", sound.url);
		NSString *urlStr = [NSString stringWithFormat:@"http://hearushere.nl/walks/%@", sound.url];
		NSURL *originalUrl = [NSURL URLWithString:urlStr];
		_request = [NSMutableURLRequest requestWithURL:originalUrl
										   cachePolicy:NSURLRequestReloadIgnoringCacheData
									   timeoutInterval:600];
		[self sendAsync:_request];
	} else {
		self.audioData = [[NSData dataWithContentsOfFile:songFile] mutableCopy];
		[self createPlayer];
	}
}

-(void)createPlayer {
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:self.audioData error:&error];
	self.audioPlayer.numberOfLoops = _bluetooth ? 0 : -1;
    self.audioPlayer.volume = 1.0f;
    self.audioPlayer.delegate = self;

    [_delegate trackDataLoaded:_trackId];
}

-(void)setFilteredVolume:(double)volume {
	volumes[volumeCount % FILTER_SAMPLES] = volume;
	long count = volumeCount < FILTER_SAMPLES ? volumeCount : FILTER_SAMPLES;
	double vol = volume;
	if(count > 0) {
		double sum = 0.0;
		for(long i = 0; i < count; i++) {
			sum += volumes[i];
		}
		vol = (double)sum / (double)count;
	}
	self.audioPlayer.volume = vol;
	++volumeCount;
}

#pragma mark - 
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [self.audioData appendData:data];
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
    [self.audioData writeToFile:songFile atomically:YES];
}

-(NSURLRequest*)connection:(NSURLConnection*)inConnection
           willSendRequest:(NSURLRequest*)inRequest
          redirectResponse:(NSURLResponse*)inRedirectResponse {
    NSLog(@"%@", [[inRequest URL] absoluteString]);
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
