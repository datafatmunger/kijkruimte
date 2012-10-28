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

@interface KRMapPin : MKPlacemark <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
	NSString *_title;
	NSString *_subtitle;
    BOOL _isPlaying;
}

@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *subtitle;
@property(nonatomic,assign)BOOL isPlaying;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                  title:(NSString*)title
               subtitle:(NSString *)subtitle;


@end
