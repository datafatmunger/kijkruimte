//
//  KRBroadcaster.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 11/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRBroadcaster : NSObject

+(id)sharedBroadcaster;
-(void)broadcastTrack:(NSDictionary*)dictionary;

@end
