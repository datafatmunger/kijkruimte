//
//  KRMapPin.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/28/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRMapPin.h"

@implementation KRMapPin

@synthesize coordinate = _coordinate;
@synthesize subtitle = _subtitle;
@synthesize title = _title;
@synthesize isPlaying = _isPlaying;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                  title:(NSString*)title
               subtitle:(NSString *)subtitle {
    if(self = [self init]) {
        _isPlaying = NO;
        _title = title;
        _subtitle = subtitle;
        _coordinate = coordinate;
    }
    return self;
}

@end