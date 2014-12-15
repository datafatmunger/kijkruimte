//
//  Walk.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Walk : NSObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *imageURLStr;
@property(nonatomic, strong)NSString *credits;
@property(nonatomic, strong)NSString *walkDescription;
@property(nonatomic, strong)CLLocation *location;
@property(nonatomic, assign)BOOL autoPlay;
@property(nonatomic, assign)double radius;

@property(nonatomic,assign)CLLocationDegrees minLat;
@property(nonatomic,assign)CLLocationDegrees maxLat;
@property(nonatomic,assign)CLLocationDegrees minLng;
@property(nonatomic,assign)CLLocationDegrees maxLng;

@end
