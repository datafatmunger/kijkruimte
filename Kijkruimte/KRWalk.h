//
//  KRWalk.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KRWalk : NSObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *imageURLStr;
@property(nonatomic, strong)NSString *scUser;
@property(nonatomic, strong)MKPolygon *polygon;
@property(nonatomic, strong)CLLocation *location;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
