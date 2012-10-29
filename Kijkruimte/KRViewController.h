//
//  KRViewController.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//


#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "KRTrack.h"
#import "SCGetUserTracks.h"
#import "SCGetTrackDetail.h"

@interface KRViewController : UIViewController <
CLLocationManagerDelegate,
MKMapViewDelegate,
SCGetUserTracksDelegate,
SCGetTrackDetailDelegate,
KRTrackDelegate,
UITableViewDataSource,
UITableViewDelegate> {
    
    NSMutableDictionary *_tracks;
    
    IBOutlet MKMapView *_mapView;
    IBOutlet UIActivityIndicatorView *_actView;
    IBOutlet UIView *_controls;
    IBOutlet UIButton *_button;
    
    NSInteger _loadCount;
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    
    BOOL _isRunning;

}

-(IBAction)start;

@end
