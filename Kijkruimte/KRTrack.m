//
//  SCTrack.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrack.h"

@interface KRTrack (Private)

-(NSNumber*)getNumber:(NSString*)tag;

@end

@implementation KRTrack

@synthesize trackId;
@synthesize uri;
@synthesize lat;
@synthesize lng;

-(id)initWithDictionary:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        trackId = [dictionary objectForKey:@"id"];
        uri = [dictionary objectForKey:@"uri"];
        
        NSString *tagList = [dictionary objectForKey:@"taglist"];
        NSArray *tags = [tagList componentsSeparatedByString:@" "];
        for(NSString *tag in tags) {
            if([tag rangeOfString:@"lat"].location != NSNotFound)
                self.lat = [self getNumber:tag];
            else if([tag rangeOfString:@"lon"].location != NSNotFound)
                self.lng = [self getNumber:tag];

        }
    }
    return self;
}

-(NSNumber*)getNumber:(NSString *)tag {
    NSMutableString *numberStr = [NSMutableString
                                  stringWithCapacity:tag.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:tag];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789."];
    
    while (![scanner isAtEnd]) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
            [numberStr appendString:buffer];
        else
            [scanner setScanLocation:([scanner scanLocation] + 1)];
    }
    
    NSLog(@"%@", numberStr);
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *number = [f numberFromString:numberStr];
    return number;
}

@end
