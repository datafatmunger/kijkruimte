//
//  KRWalk.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRWalk.h"

@implementation KRWalk

-(id)initWithDictionary:(NSDictionary*)dictionary {
	self = [super init];
	if(self) {
		self.title = dictionary[@"title"];
		self.scUser = dictionary[@"scUser"];
		self.imageURLStr = dictionary[@"image"];
		self.credits = dictionary[@"credits"];
		self.description = dictionary[@"description"];
		self.autoPlay = [dictionary[@"autoplay"] boolValue];
		self.radius = [dictionary[@"radius"] doubleValue];
		
		self.maxLat = 0.0f;
		self.maxLng = 0.0f;
		self.minLat = FLT_MAX;
		self.minLng = FLT_MAX;
		
		NSArray *coordinates = dictionary[@"area"];
		MKMapPoint points[coordinates.count / 2];
		for(NSInteger i = 0, j = 0; i < coordinates.count; i+=2, j++) {
			CLLocationCoordinate2D c = {[coordinates[i] doubleValue], [coordinates[i+1] doubleValue]};
			points[j] = MKMapPointForCoordinate(c);
			
			if(c.latitude < self.minLat) self.minLat = c.latitude;
			if(c.latitude > self.maxLat) self.maxLat = c.latitude;
			if(c.longitude < self.minLng) self.minLng = c.longitude;
			if(c.longitude > self.maxLng) self.maxLng = c.longitude;
		}
		self.polygon = [MKPolygon polygonWithPoints:points count:coordinates.count / 2];
		
		NSArray *location = dictionary[@"location"];
		self.location = [[CLLocation alloc] initWithLatitude:[location[0] doubleValue]
												   longitude:[location[1] doubleValue]];
	}
	return self;
}

@end