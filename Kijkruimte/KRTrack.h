//
//  SCTrack.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

#import "KRMapPin.h"
#import "KRTrackDetail.h"

@protocol KRTrackDelegate <NSObject>

-(void)trackDataLoaded:(NSNumber*)trackId;
-(void)trackDataError:(NSString*)message;

@end

@interface KRTrack : NSObject <
AVAudioPlayerDelegate,
NSURLConnectionDataDelegate
> {
    NSNumber *_trackId;
    NSString *_uri;
    NSString *_title;
    CLLocation *_location;
    
    AVAudioPlayer *_audioPlayer;
    KRMapPin *_pin;
    NSMutableData *_audioData;
    
    id<KRTrackDelegate> _delegate;
    
    NSMutableURLRequest *_request;
}

@property(nonatomic,strong)NSNumber *trackId;
@property(nonatomic,strong)NSString *uri;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)CLLocation *location;
@property(nonatomic,strong)AVAudioPlayer *audioPlayer;
@property(nonatomic,strong)KRMapPin *pin;
@property(nonatomic,strong)id<KRTrackDelegate> delegate;

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)getData:(KRTrackDetail*)detail;


@end
