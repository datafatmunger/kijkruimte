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

#import "KRSound.h"
#import "KRMapPin.h"
#import "KRTrackDetail.h"

@protocol KRTrackDelegate <NSObject>

-(void)trackDataLoaded:(NSString*)trackId;
-(void)trackDataError:(NSString*)message;

@end

@interface KRTrack : NSObject <
AVAudioPlayerDelegate,
NSURLConnectionDataDelegate
> {
    NSString *_trackId;
    NSString *_title;
    CLLocation *_location;
    
    AVAudioPlayer *_audioPlayer;
    KRMapPin *_pin;
    NSMutableData *_audioData;
    
    id<KRTrackDelegate> _delegate;
    
    NSMutableURLRequest *_request;
    NSInteger _tries;
}

@property(nonatomic,strong)NSString *trackId;
@property(nonatomic,strong)NSString *uri;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)CLLocation *location;
@property(nonatomic, assign)double radius;
@property(nonatomic, assign)BOOL background;

@property(nonatomic, strong)NSString *uuid;
@property(nonatomic, strong)NSNumber *major;
@property(nonatomic, strong)NSNumber *minor;
@property(nonatomic, assign)BOOL bluetooth;


@property(nonatomic,strong)AVAudioPlayer *audioPlayer;
@property(nonatomic,strong)NSMutableData *audioData;
@property(nonatomic,strong)KRMapPin *pin;
@property(nonatomic,strong)id<KRTrackDelegate> delegate;

-(id)initWithSound:(KRSound*)sound;
- (id)initWithSilence;
-(void)getDataWithSound:(KRSound*)sound;
-(void)setFilteredVolume:(double)volume;


@end
