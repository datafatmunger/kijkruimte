//
//  HUHWalk.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Walk.h"

@interface HUHWalk : Walk

@property(nonatomic, strong)NSMutableArray *sounds;
@property(nonatomic, strong)NSMutableArray *polygons;

@property(nonatomic,assign)CLLocationDegrees minLat;
@property(nonatomic,assign)CLLocationDegrees maxLat;
@property(nonatomic,assign)CLLocationDegrees minLng;
@property(nonatomic,assign)CLLocationDegrees maxLng;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
