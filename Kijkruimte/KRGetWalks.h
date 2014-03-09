//
//  KRGetWalks.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "SCServiceAPI.h"
#import "SCServiceRequest.h"

@protocol KRGetWalksDelegate <NSObject>

-(void)handleWalks:(NSArray*)walks;
-(void)handleGetWalksError:(NSString*)message;

@end

@interface KRGetWalks : SCServiceAPI <SCServiceRequestDelegate> {
    id<KRGetWalksDelegate> _delegate;
}

@property(nonatomic,strong)id<KRGetWalksDelegate> delegate;

-(void)getWalks;

@end
