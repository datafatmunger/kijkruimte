//
//  KRBluetoothProducer.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 21-09-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#import "KRBluetoothProducer.h"

#define SERVICE_UUID @"1AC1FE51-5809-4FC6-8415-6E6578185F45"
#define CHAR_UUID @"5DC66BE2-4325-4E4C-A629-96D21E8ADEE1"

@interface KRBluetoothProducer () <
CBPeripheralManagerDelegate
>

@property(nonatomic, strong)CBMutableCharacteristic *characteristic;
@property(nonatomic, strong)CBPeripheralManager *peripheralManager;

- (void)startAdvertising;

@end

@implementation KRBluetoothProducer

- (void)start {
	dispatch_queue_t peripheralQueue = dispatch_queue_create("com.jamesbryangraves.clbleproducer", DISPATCH_QUEUE_SERIAL);
	self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
																	 queue:peripheralQueue];
	
	if(self.peripheralManager.state == CBPeripheralManagerStatePoweredOn)
		[self startAdvertising];
}

- (void)stop {
	[self.peripheralManager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
	NSLog(@"peripheralManagerDidUpdateState");
	if(CBPeripheralManagerStatePoweredOn == peripheral.state) {
		[self startAdvertising];
	}
}

#pragma mark - KRBluetoothProducer()

- (void)startAdvertising {
	CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:SERVICE_UUID]
															   primary:YES];
	self.characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CHAR_UUID]
															 properties: CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify
																  value:nil
															permissions:CBAttributePermissionsReadable];
	service.characteristics = @[self.characteristic];
	[self.peripheralManager addService:service];
	[self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey: @[[CBUUID UUIDWithString:SERVICE_UUID]]}];
}

@end