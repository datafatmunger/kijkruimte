//
//  KRMapPin.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/28/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KRMapPin : MKPlacemark <MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, assign) BOOL isPlaying;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                  title:(NSString*)title
               subtitle:(NSString *)subtitle;


@end
