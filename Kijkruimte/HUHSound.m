//
//  HUHSound.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "HUHSound.h"

@implementation HUHSound

-(id)initWithDictionary:(NSDictionary*)dictionary {
	self = [super init];
	if(self) {
		self.soundId = [[NSUUID UUID] UUIDString];
		self.url = dictionary[@"url"];
		self.radius = [dictionary[@"radius"] doubleValue];
		if(dictionary[@"location"]) {
			NSArray *location = dictionary[@"location"];
			self.location = [[CLLocation alloc] initWithLatitude:[location[0] doubleValue]
													   longitude:[location[1] doubleValue]];
		}
		self.bluetooth = dictionary[@"bluetooth"];
		self.background = dictionary[@"background"];
	}
	return self;
}

@end
