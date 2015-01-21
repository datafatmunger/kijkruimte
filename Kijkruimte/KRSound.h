//
//  HUHSound.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KRSound : NSObject

@property(nonatomic, strong)NSString *soundId;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)CLLocation *location;
@property(nonatomic, assign)double radius;
@property(nonatomic, assign)BOOL background;

@property(nonatomic, assign)BOOL bluetooth;
@property(nonatomic, strong)NSString *uuid;
@property(nonatomic, strong)NSNumber *major;
@property(nonatomic, strong)NSNumber *minor;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
