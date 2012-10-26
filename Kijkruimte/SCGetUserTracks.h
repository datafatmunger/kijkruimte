//
//  SCGetUserTracks.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "SCServiceAPI.h"
#import "SCServiceRequest.h"
#import "KRTrack.h"
#import <Foundation/Foundation.h>

@protocol SCGetUserTracksDelegate <NSObject>

-(void)handleTracks:(NSArray*)tracks;
-(void)handleGetTracksError:(NSString*)message;

@end

@interface SCGetUserTracks : SCServiceAPI <SCServiceRequestDelegate> {
    id<SCGetUserTracksDelegate> _delegate;
}

@property(nonatomic,strong)id<SCGetUserTracksDelegate> delegate;

-(void)getTracks:(NSString*)username;

@end
