//
//  KRMapPin.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/28/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRMapPin.h"

@implementation KRMapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
	self = [super init];
	if (self != nil) {
		coordinate = location;
		title = placeName;
		subtitle = description;
	}
	return self;
}

@end