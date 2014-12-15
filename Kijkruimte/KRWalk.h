//
//  KRWalk.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Walk.h"

@interface KRWalk : Walk

@property(nonatomic, strong)NSString *scUser;
@property(nonatomic, strong)MKPolygon *polygon;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
