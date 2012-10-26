//
//  KRTrackDetail.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/26/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRTrackDetail : NSObject {
    NSString *streamUrl;
}

@property(nonatomic,strong)NSString *streamUrl;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
