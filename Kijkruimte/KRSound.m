//
//  HUHSound.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 15-12-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRSound.h"

@implementation KRSound

-(id)initWithDictionary:(NSDictionary*)dictionary {
	self = [super init];
	if(self) {
		self.soundId = dictionary[@"file"];
		self.url = dictionary[@"file"];
		
		self.bluetooth = dictionary[@"bluetooth"];
		self.background = dictionary[@"background"];
		
		self.radius = [dictionary[@"radius"] doubleValue];
		
		if(dictionary[@"location"]) {
			NSArray *location = dictionary[@"location"];
			self.location = [[CLLocation alloc] initWithLatitude:[location[0] doubleValue]
													   longitude:[location[1] doubleValue]];
		} else if(self.bluetooth) {
			self.uuid = dictionary[@"uuid"];
		}
	}
	return self;
}

@end
