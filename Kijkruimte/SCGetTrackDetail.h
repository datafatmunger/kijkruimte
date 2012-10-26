//
//  KRGetTrackDetail.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "SCServiceAPI.h"
#import "SCServiceRequest.h"
#import "KRTrackDetail.h"

#import <Foundation/Foundation.h>

@protocol SCGetTrackDetailDelegate <NSObject>

-(void)handleDetail:(KRTrackDetail*)detail;
-(void)handleGetDetailError:(NSString*)message;

@end

@interface SCGetTrackDetail : SCServiceAPI <SCServiceRequestDelegate> {
    id<SCGetTrackDetailDelegate> _delegate;
}

@property(nonatomic,strong)id<SCGetTrackDetailDelegate> delegate;

-(void)getTrackDetail:(NSString*)trackId;

@end
