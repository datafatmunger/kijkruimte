//
//  KRBluetoothScanner.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 04-09-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "KRBluetoothScanner.h"

@interface KRBluetoothScanner () <CBCentralManagerDelegate>

@property(nonatomic, strong)CBCentralManager *centralManager;

@end

@implementation KRBluetoothScanner

- (id)init {
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("nl.hearushere.blequeue", DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
    }
    return self;
}

- (void)scan {
	if(self.centralManager.state == CBCentralManagerStatePoweredOn)
		[self.centralManager scanForPeripheralsWithServices:nil
													options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
}

- (void)stop {
	[self.centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff: {

            break;
        }
        case CBCentralManagerStatePoweredOn:{
			[self scan];
            break;
        }
		default: {
			// Unsupport central state, don't worry it's been like this forever - JBG
		}
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
	 advertisementData:(NSDictionary *)advertisementData
				  RSSI:(NSNumber *)RSSI {
	
	[self.delegate foundDevice:peripheral.identifier.UUIDString RSSI:RSSI];
}

@end
