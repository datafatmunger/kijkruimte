//
//  KRViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <math.h>

#import "KRTrackCell.h"
#import "KRTrackDetail.h"
#import "KRViewController.h"

@interface KRViewController ()

@end

@implementation KRViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _detailCount = 0;
    _tracks = [NSMutableDictionary dictionary];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];

	SCGetUserTracks *tracksAPI = [[SCGetUserTracks alloc] init];
    tracksAPI.delegate = self;
    [tracksAPI getTracks:@"kijkruimte"];
    
    double x1 = 100.0, y1 = 50.0, x2 = 250.0, y2 = 70.0;
    
    [self angleBetween2Pointsx1:x1 y1:y1 x2:x2 y2:y2];
    
    [_actView startAnimating];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)angleBetween2Pointsx1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2 {
    
    double deltaY = y2 - y1;
    double deltaX = x2 - x1;
    double degrees = atan2(deltaY, deltaX) * 180 / M_PI;
    
    NSLog(@"degrees: %f", degrees);
}

#pragma mark -
#pragma mark UITableViewDelete and UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KRTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KRTrackCell"];
    KRTrack *track = [[_tracks allValues] objectAtIndex:indexPath.row];
    cell.name.text = track.title;
    if([track.audioPlayer isPlaying]) {
        cell.volume.hidden = NO;
        cell.volume.text = [NSString stringWithFormat:@"%f", track.audioPlayer.volume];
    } else {
        cell.volume.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"ROWS: %d", [_tracks count]);
    return [_tracks count];
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
    [_tableView reloadData];

}

-(void)handleGetTracksError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleDetail:(KRTrackDetail*)detail {
    NSLog(@"STREAM URL: %@", detail.streamUrl);
    KRTrack *track = [_tracks objectForKey:detail.trackId];
    [track getData:detail];
    
    _detailCount++;
    if(_detailCount == [_tracks count])
        [_actView stopAnimating];
}

-(void)handleGetDetailError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    
    // For testing only (location of Kijkruimte) - JBG
    newLocation = [[CLLocation alloc] initWithLatitude:52.388 longitude:4.909006];
    
    for(int i = 0; i < [_tracks count]; i++) {
        KRTrack *track = [[_tracks allValues] objectAtIndex:i];
        
        NSLog(@"comparing %f, %f with %f, %f",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude,
              track.location.coordinate.latitude,
              track.location.coordinate.longitude);
              
        CLLocationDistance distance = [newLocation distanceFromLocation:track.location];
        NSLog(@"You are %fm from sound: %@", distance, track.trackId);
        
        double volume = 0.0;
        if(distance <= 100 && distance != 0.0) {
            volume = (log(distance/100) * -1)/4;
            NSLog(@"track is playing, volume is: %f", volume);
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying])
                [track.audioPlayer play];
        } else if(distance == 0.0) {
            volume = 1.0;
        } else {
            if(track.audioPlayer != nil && [track.audioPlayer isPlaying])
                [track.audioPlayer stop];
        }
    }
    [_tableView reloadData];
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}


@end
