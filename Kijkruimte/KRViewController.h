//
//  KRViewController.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//


#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "KRBluetoothProducer.h"
#import "KRBluetoothScanner.h"
#import "KRBroadcaster.h"
#import "KRMessageView.h"
#import "KRTrack.h"
#import "KRWalk.h"
#import "SCGetUserTracks.h"
#import "SCGetTrackDetail.h"

@interface KRViewController : UIViewController <
CLLocationManagerDelegate,
MKMapViewDelegate,
SCGetUserTracksDelegate,
SCGetTrackDetailDelegate,
KRMessageViewDelegate,
KRTrackDelegate> {
    
    NSMutableDictionary *_tracks;
    
    IBOutlet MKMapView *_mapView;
    IBOutlet UIActivityIndicatorView *_actView;
    IBOutlet UIView *_controls;
    IBOutlet UIButton *_button;
	IBOutlet UIButton *_doneButton;
    IBOutlet KRMessageView *_messageView;
    IBOutlet UILabel *_messageLabel;
	IBOutlet UIButton *_info;
    
    NSInteger _loadCount;
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    
    BOOL _isRunning;
    NSString *_guid;
	BOOL _canRetry;
	BOOL _enableBluetooth;
    
    NSTimer *_timer;
    
    KRBroadcaster *_broadcaster;

}

@property(nonatomic, strong)NSMutableDictionary *bleTracks;
@property(nonatomic, strong)KRBluetoothProducer *bleProducer;
@property(nonatomic, strong)KRBluetoothScanner *bleScanner;
@property(nonatomic, strong)KRWalk *walk;

-(IBAction)start;
-(IBAction)toInfo:(id)sender;

@end
