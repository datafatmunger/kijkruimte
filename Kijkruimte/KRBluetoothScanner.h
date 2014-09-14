//
//  KRBluetoothScanner.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 04-09-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KRBluetoothScannerDelegate <NSObject>

-(void)foundDevice:(NSString*)uuidStr RSSI:(NSNumber*)RSSI;

@end

@interface KRBluetoothScanner : NSObject

@property(nonatomic, weak)id<KRBluetoothScannerDelegate> delegate;

- (void)scan;
- (void)stop;

@end
