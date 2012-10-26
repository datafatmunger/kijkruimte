//
//  SCTrack.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import "KRTrackDetail.h"

@interface KRTrack : NSObject {
    NSNumber *trackId;
    NSString *uri;
    NSNumber *lat;
    NSNumber *lng;
    
    AVAudioPlayer *audioPlayer;
    
}

@property(nonatomic,strong)NSNumber *trackId;
@property(nonatomic,strong)NSString *uri;
@property(nonatomic,strong)NSNumber *lat;
@property(nonatomic,strong)NSNumber *lng;
@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

-(id)initWithDictionary:(NSDictionary*)dictionary;
-(void)createPlayer:(KRTrackDetail*)detail;
-(void)start;


@end
