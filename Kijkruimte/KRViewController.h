//
//  KRViewController.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "SCGetUserTracks.h"
#import "SCGetTrackDetail.h"

@interface KRViewController : UIViewController <
CLLocationManagerDelegate,
SCGetUserTracksDelegate,
SCGetTrackDetailDelegate,
UITableViewDataSource,
UITableViewDelegate> {
    
    CLLocationManager *_locationManager;
    NSMutableDictionary *_tracks;
    
    IBOutlet UITableView *_tableView;
    IBOutlet UIActivityIndicatorView *_actView;
    
    NSInteger _detailCount;

}

@end
