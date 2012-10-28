//
//  KRViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <math.h>
#import "KRMapPin.h"
#import "KRTrackCell.h"
#import "KRTrackDetail.h"
#import "KRViewController.h"

#define MAP_ZOOM_LEVEL 0.01

@interface KRViewController ()

@end

@implementation KRViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _loadCount = 0;
    _tracks = [NSMutableDictionary dictionary];

	SCGetUserTracks *tracksAPI = [[SCGetUserTracks alloc] init];
    tracksAPI.delegate = self;
    [tracksAPI getTracks:@"kijkruimte"];
    
    double x1 = 100.0, y1 = 50.0, x2 = 250.0, y2 = 70.0;
    
    [self angleBetween2Pointsx1:x1 y1:y1 x2:x2 y2:y2];
    
    [_actView startAnimating];
    
    _currentLocation = [[CLLocation alloc] initWithLatitude:52.388 longitude:4.909006];
    MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span = MKCoordinateSpanMake(MAP_ZOOM_LEVEL, MAP_ZOOM_LEVEL);
	region.span = span;
	region.center = _currentLocation.coordinate;
    _mapView.region = region;
    
    //MKMapPoint points[3] = {{52.392692,4.908496}, {52.389593,4.91694}, {52.384721,4.906726}};
    //MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:3];
    
    MKMapPoint points[3];
    CLLocationCoordinate2D c1 = {52.392692,4.908496};
    points[0] = MKMapPointForCoordinate(c1);
    CLLocationCoordinate2D c2 = {52.389593,4.91694};
    points[1] = MKMapPointForCoordinate(c2);
    CLLocationCoordinate2D c3 = {52.384721,4.906726};
    points[2] = MKMapPointForCoordinate(c3);
    
    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:3];
    [_mapView addOverlay:polygon];
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

-(void)updateTracks:(CLLocation*)location {
    for(int i = 0; i < [_tracks count]; i++) {
        KRTrack *track = [[_tracks allValues] objectAtIndex:i];
        
        NSLog(@"comparing %f, %f with %f, %f",
              location.coordinate.latitude,
              location.coordinate.longitude,
              track.location.coordinate.latitude,
              track.location.coordinate.longitude);
        
        CLLocationDistance distance = [location distanceFromLocation:track.location];
        NSLog(@"You are %fm from sound: %@", distance, track.trackId);
        
        double volume = 0.0;
        if(distance <= 100 && distance != 0.0) {
            volume = (log(distance/100) * -1)/4;
            NSLog(@"track is playing, volume is: %f", volume);
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
                [_mapView removeAnnotation:track.pin];
                [_mapView addAnnotation:track.pin];
            }
        } else if(distance == 0.0) {
            volume = 1.0;
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
                [_mapView removeAnnotation:track.pin];
                [_mapView addAnnotation:track.pin];
            }
        } else {
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && [track.audioPlayer isPlaying]) {
                [track.audioPlayer stop];
                track.pin.isPlaying = NO;
            }
        }
        track.pin.subtitle = [NSString stringWithFormat:@"Volume: %f", volume];
    }
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleTracks:(NSArray*)tracks {
    SCGetTrackDetail *detailAPI = [[SCGetTrackDetail alloc] init];
    detailAPI.delegate = self;
    for(KRTrack *track in tracks) {
        track.delegate = self;
        
        NSLog(@"TRACK URI: %@", track.uri);
        
        [_tracks setObject:track forKey:track.trackId];
        [detailAPI getTrackDetail:[NSString stringWithFormat:@"%d", [track.trackId intValue]]];
        
        // Map Stuff - JBG
        KRMapPin *mp = [[KRMapPin alloc] initWithCoordinate:track.location.coordinate
                                                      title:track.title
                                                   subtitle:[NSString stringWithFormat:@"Volume: %f", 0.0]];
        track.pin = mp;
        [_mapView addAnnotation:track.pin];
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
    [track getData:detail];
}

-(void)handleGetDetailError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark MKMapKitDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation {
    MKPinAnnotationView *newAnnotation = nil;
    if([annotation isKindOfClass:[KRMapPin class]]) {
        KRMapPin *pin = (KRMapPin*)annotation;
        if(pin.isPlaying) {
            newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"GreenPin"];
            newAnnotation.pinColor = MKPinAnnotationColorGreen;
            newAnnotation.animatesDrop = YES;
            newAnnotation.canShowCallout = YES;
        } else {
            newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"RedPin"];
            newAnnotation.pinColor = MKPinAnnotationColorRed;
            newAnnotation.animatesDrop = YES;
            newAnnotation.canShowCallout = YES;
        }
    }
    return newAnnotation;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //CLLocation *newLocation = userLocation.location;
    // For testing only (location of Kijkruimte) - JBG
    _currentLocation = [[CLLocation alloc] initWithLatitude:52.388 longitude:4.909006];
    [self updateTracks:_currentLocation];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    polygonView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    polygonView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
    polygonView.lineWidth = 3;
    return polygonView;
}

#pragma mark -
#pragma mark KRTrackDelegate

-(void)trackDataLoaded:(NSNumber*)trackId {
    [self updateTracks:_currentLocation];
    if(++_loadCount >= [_tracks count])
        [_actView stopAnimating];
}


@end
