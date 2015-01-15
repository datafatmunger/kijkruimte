//
//  HUHWalk.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRSound.h"
#import "KRWalk.h"

@implementation KRWalk

-(id)initWithDictionary:(NSDictionary*)dictionary {
	self = [super init];
	if(self) {
		self.polygons = [NSMutableArray new];
		self.sounds = [NSMutableArray new];
		
		self.title = dictionary[@"title"];
		self.imageURLStr = dictionary[@"image"];
		self.credits = dictionary[@"credits"];
		self.walkDescription = dictionary[@"description"];
		self.autoPlay = [dictionary[@"autoplay"] boolValue];
		self.radius = [dictionary[@"radius"] doubleValue];
		
		self.maxLat = 0.0f;
		self.maxLng = 0.0f;
		self.minLat = FLT_MAX;
		self.minLng = FLT_MAX;
		
		NSArray *areas = dictionary[@"areas"];
		for(NSInteger i = 0; i < areas.count; i++) {
			NSDictionary *area = areas[i];
			NSArray *coordinates = area[@"coords"];
			MKMapPoint points[coordinates.count / 2];
			for(NSInteger j = 0, k = 0; j < coordinates.count; j+=2, k++) {
				CLLocationCoordinate2D c = {[coordinates[j] doubleValue], [coordinates[j+1] doubleValue]};
				points[k] = MKMapPointForCoordinate(c);
				
				if(c.latitude < self.minLat) self.minLat = c.latitude;
				if(c.latitude > self.maxLat) self.maxLat = c.latitude;
				if(c.longitude < self.minLng) self.minLng = c.longitude;
				if(c.longitude > self.maxLng) self.maxLng = c.longitude;
			}
			[self.polygons addObject:[MKPolygon polygonWithPoints:points count:coordinates.count / 2]];
		}
		CLLocationDegrees medianLat = (self.maxLat + self.minLat) / 2;
		CLLocationDegrees medianLng = (self.maxLng + self.minLng) / 2;
		self.location = [[CLLocation alloc] initWithLatitude:medianLat
												   longitude:medianLng];
		
		NSArray *sounds = dictionary[@"sounds"];
		for(NSDictionary *soundDict in sounds) {
			[self.sounds addObject:[[KRSound alloc] initWithDictionary:soundDict]];
		}
	}
	return self;
}

@end
