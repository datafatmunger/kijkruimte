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

#import "KRTrackDetail.h"

@interface KRTrack : NSObject <NSURLConnectionDataDelegate> {
    NSNumber *trackId;
    NSString *uri;
    NSString *title;
    CLLocation *location;
    
    AVAudioPlayer *audioPlayer;
    
    NSMutableData *_audioData;
    
}

@property(nonatomic,strong)NSNumber *trackId;
@property(nonatomic,strong)NSString *uri;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)CLLocation *location;
@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)getData:(KRTrackDetail*)detail;


@end
