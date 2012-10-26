//
//  SCTrack.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRTrack : NSObject {
    NSString *trackId;
    NSString *uri;
    NSNumber *lat;
    NSNumber *lng;
}

@property(nonatomic,strong)NSString *trackId;
@property(nonatomic,strong)NSString *uri;
@property(nonatomic,strong)NSNumber *lat;
@property(nonatomic,strong)NSNumber *lng;

-(id)initWithDictionary:(NSDictionary*)dictionary;


@end
