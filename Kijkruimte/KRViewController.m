//
//  KRViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "KRTrackDetail.h"
#import "KRViewController.h"

@interface KRViewController ()

@end

@implementation KRViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _tracks = [NSMutableDictionary dictionary];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];

	SCGetUserTracks *tracksAPI = [[SCGetUserTracks alloc] init];
    tracksAPI.delegate = self;
    [tracksAPI getTracks:@"kijkruimte"];
    
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleTracks:(NSArray*)tracks {
    SCGetTrackDetail *detailAPI = [[SCGetTrackDetail alloc] init];
    detailAPI.delegate = self;
    for(KRTrack *track in tracks) {
        NSLog(@"TRACK URI: %@", track.uri);
        
        [_tracks setObject:track forKey:track.trackId];
        [detailAPI getTrackDetail:[NSString stringWithFormat:@"%d", [track.trackId intValue]]];
    }

}

-(void)handleGetTracksError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleDetail:(KRTrackDetail*)detail {
    NSLog(@"STREAM URL: %@", detail.streamUrl);
    KRTrack *track = [_tracks objectForKey:detail.trackId];
    [track createPlayer:detail];
    [track start];
}

-(void)handleGetDetailError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}


@end
