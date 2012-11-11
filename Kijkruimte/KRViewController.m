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
#import "KRTrackDetail.h"
#import "KRViewController.h"

#define MAP_ZOOM_LEVEL 0.01

@interface KRViewController ()

@end

@implementation KRViewController

- (NSString *)generateUuidString {
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    return uuidString;
}

-(double)randomDoubleBetween:(double)smallNumber and:(double)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

-(void)testModeUpdate {
    
    double randLat = [self randomDoubleBetween:52.385059 and:52.391187];
    double randLng = [self randomDoubleBetween:4.906275 and:4.914773];
    
    _currentLocation = [[CLLocation alloc] initWithLatitude:randLat longitude:randLng];
    [_messageLabel setText:[NSString stringWithFormat:@"You are too far away! Using random location: %f, %f",
                            _currentLocation.coordinate.latitude,
                            _currentLocation.coordinate.longitude]];
    
    _messageView.hidden = NO;
    [self updateTracks:_currentLocation];
    
}

-(void)testMode {
    NSLog(@"Enabling test function.");
    [_locationManager stopUpdatingLocation];
    [self testModeUpdate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                              target:self
                                            selector:@selector(testModeUpdate)
                                            userInfo:nil
                                             repeats:YES];
}

-(void)broadcastTrack:(NSNumber*)trackId
             location:(CLLocation*)location
        trackLocation:(CLLocation*)trackLocation
               volume:(double)volume {
    NSDictionary *message = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                 trackId,
                                                                 [NSNumber numberWithDouble:location.coordinate.latitude],
                                                                 [NSNumber numberWithDouble:location.coordinate.longitude],
                                                                 [NSNumber numberWithDouble:trackLocation.coordinate.latitude],
                                                                 [NSNumber numberWithDouble:trackLocation.coordinate.longitude],
                                                                 [NSNumber numberWithDouble:volume],
                                                                 _guid,
                                                                 nil]
                                                        forKeys:[NSArray arrayWithObjects:
                                                                 @"trackId",
                                                                 @"latitude",
                                                                 @"longitude",
                                                                 @"trackLatitude",
                                                                 @"trackLongitude",
                                                                 @"volume",
                                                                 @"guid",
                                                                 nil]];
    NSError *error = nil;
    NSData *messageJSON = [NSJSONSerialization dataWithJSONObject:message
                                                          options:0
                                                            error:&error];
    if(!error) {
        NSString* messageStr = [[NSString alloc] initWithData:messageJSON
                                                     encoding:NSUTF8StringEncoding];
        [_stompClient sendMessage:messageStr toDestination:@"/topic/listeners"];
    } else {
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _isRunning = NO;
    _loadCount = 0;
    _tracks = [NSMutableDictionary dictionary];
    _guid = [self generateUuidString];

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
    
    MKMapPoint points[3];
    CLLocationCoordinate2D c1 = {52.392692,4.908496};
    points[0] = MKMapPointForCoordinate(c1);
    CLLocationCoordinate2D c2 = {52.389593,4.91694};
    points[1] = MKMapPointForCoordinate(c2);
    CLLocationCoordinate2D c3 = {52.384721,4.906726};
    points[2] = MKMapPointForCoordinate(c3);
    
    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:3];
    [_mapView addOverlay:polygon];
    
    [_button setImage:[UIImage imageNamed:@"btn-start-pressed"]
             forState:UIControlStateHighlighted];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;

}

-(void)viewDidAppear:(BOOL)animated {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen height: %f", screenRect.size.height);
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _controls.frame = CGRectMake(_controls.frame.origin.x,
                                                      screenRect.size.height - _controls.frame.size.height - [[UIApplication sharedApplication] statusBarFrame].size.height,
                                                      _controls.frame.size.width,
                                                      _controls.frame.size.height);

                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
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
    if(!_isRunning) return;
    
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
        if(distance <= 100.0f && distance > 0.0f) {
            volume = (log(distance/100) * -1)/4;
            volume = volume > 1.0 ? 1.0 : volume;
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
                [_mapView removeAnnotation:track.pin];
                [_mapView addAnnotation:track.pin];
            }
        } else if(distance <= 0.0f) {
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
            if(track.pin.isPlaying != NO) {
                //[track.audioPlayer stop];
                track.pin.isPlaying = NO;
                [_mapView removeAnnotation:track.pin];
                [_mapView addAnnotation:track.pin];
            }
        }
        [self broadcastTrack:track.trackId
                    location:location
               trackLocation:track.location
                      volume:volume];
        track.pin.subtitle = [NSString stringWithFormat:@"Volume: %f", volume];
        [_mapView setNeedsDisplay];
    }
}

-(IBAction)start {
    NSLog(@"Start and Stop");

    _isRunning = !_isRunning;

    if(_isRunning) {
        _currentLocation = [[CLLocation alloc] initWithLatitude:52.388 longitude:4.909006];
        _stompClient = [[CRVStompClient alloc] initWithHost:@"ec2-54-246-42-89.eu-west-1.compute.amazonaws.com"
                                                       port:61613
                                                      login:@"guest"
                                                   passcode:@"guest"
                                                   delegate:self];
        [_stompClient connect];
        [_locationManager startUpdatingLocation];
        [_button setImage:[UIImage imageNamed:@"btn-stop-passive"]
                 forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"btn-stop-pressed"]
                 forState:UIControlStateHighlighted];
        
    } else {
        [_stompClient disconnect];
        [_locationManager stopUpdatingLocation];
        for(KRTrack *track in _tracks.allValues) {
            [track.audioPlayer stop];
            track.pin.isPlaying = NO;
            [_mapView removeAnnotation:track.pin];
            [_mapView addAnnotation:track.pin];
        }
        [_button setImage:[UIImage imageNamed:@"btn-start-passive"]
                 forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"btn-start-pressed"]
                 forState:UIControlStateHighlighted];
        if(_loadCount == _tracks.count)
            _messageView.hidden = YES;
        [_timer invalidate];
        
        for(int i = 0; i < [_tracks count]; i++) {
            KRTrack *track = [[_tracks allValues] objectAtIndex:i];
            [self broadcastTrack:track.trackId
                        location:_currentLocation
                   trackLocation:track.location
                          volume:0.0f];
        }
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
    [_messageLabel setText:[NSString stringWithFormat:@"Loading...%d of %d", _loadCount, tracks.count]];

}

-(void)handleGetTracksError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
    [_actView stopAnimating];
    [_messageLabel setText:@"FAILED to connect to SoundCloud!"];
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
    [_actView stopAnimating];
    [_messageLabel setText:@"FAILED to connect to SoundCloud!"];
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
            //newAnnotation.animatesDrop = YES;
            newAnnotation.canShowCallout = YES;
        } else {
            newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"RedPin"];
            newAnnotation.pinColor = MKPinAnnotationColorRed;
            //newAnnotation.animatesDrop = YES;
            newAnnotation.canShowCallout = YES;
        }
    }
    return newAnnotation;
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
    if(++_loadCount >= [_tracks count]) {
        [_actView stopAnimating];
        _messageView.hidden = YES;
    }
    [_messageLabel setText:[NSString stringWithFormat:@"Loading...%d of %d", _loadCount, _tracks.count]];
}

-(void)trackDataError:(NSString*)message {
    [_actView stopAnimating];
    [_messageLabel setText:message];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
    CLLocationDistance distance = [newLocation distanceFromLocation:_currentLocation];
    if(distance > 3000) {
        [self testMode];
    } else {
        _currentLocation = newLocation;
        // For testing only (location of Kijkruimte) - JBG
        [self updateTracks:_currentLocation];
        NSLog(@"LOCATION!!!!");
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

#pragma mark -
#pragma mark CRVStompClientDelegate

-(void)stompClientDidConnect:(CRVStompClient *)stompService {
    NSLog(@"stompServiceDidConnect");

}

-(void)stompClient:(CRVStompClient *)stompService
    messageReceived:(NSString *)body
         withHeader:(NSDictionary *)messageHeader {
}

- (void)stompClientDidDisconnect:(CRVStompClient *)stompService {
    NSLog(@"stompServiceDidDisconnect");
    [_stompClient connect];
}

@end
