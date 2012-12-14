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

- (NSString*)generateUuidString {
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
        playPosition:(NSTimeInterval)playPosition
               volume:(double)volume {
    NSDictionary *message = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                 trackId,
                                                                 [NSNumber numberWithDouble:location.coordinate.latitude],
                                                                 [NSNumber numberWithDouble:location.coordinate.longitude],
                                                                 [NSNumber numberWithDouble:trackLocation.coordinate.latitude],
                                                                 [NSNumber numberWithDouble:trackLocation.coordinate.longitude],
                                                                 [NSNumber numberWithDouble:playPosition],
                                                                 [NSNumber numberWithDouble:volume],
                                                                 _guid,
                                                                 nil]
                                                        forKeys:[NSArray arrayWithObjects:
                                                                 @"trackId",
                                                                 @"latitude",
                                                                 @"longitude",
                                                                 @"trackLatitude",
                                                                 @"trackLongitude",
                                                                 @"playPosition",
                                                                 @"volume",
                                                                 @"guid",
                                                                 nil]];
    [_broadcaster broadcastTrack:message];
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
    
    MKMapPoint points[33];
    
    CLLocationCoordinate2D c1 = {52.38293430636731, 4.9022626876831055};
    points[0] = MKMapPointForCoordinate(c1);
    CLLocationCoordinate2D c2 = {52.38209606749874, 4.903378486633301};
    points[1] = MKMapPointForCoordinate(c2);
    CLLocationCoordinate2D c3 = {52.38303908510689, 4.9053955078125};
    points[2] = MKMapPointForCoordinate(c3);
    CLLocationCoordinate2D c4 = {52.383929694353775, 4.9074554443359375};
    points[3] = MKMapPointForCoordinate(c4);
    CLLocationCoordinate2D c5 = {52.38489886635615, 4.9091291427612305};
    points[4] = MKMapPointForCoordinate(c5);
    CLLocationCoordinate2D c6 = {52.38573705201172, 4.911360740661621};
    points[5] = MKMapPointForCoordinate(c6);
    CLLocationCoordinate2D c7 = {52.386470451405934, 4.913034439086914};
    points[6] = MKMapPointForCoordinate(c7);
    CLLocationCoordinate2D c8 = {52.38688953130371, 4.913935661315918};
    points[7] = MKMapPointForCoordinate(c8);
    CLLocationCoordinate2D c9 = {52.38767529538889, 4.915180206298828};
    points[8] = MKMapPointForCoordinate(c9);
    CLLocationCoordinate2D c10 = {52.38848723691656, 4.916338920593262};
    points[9] = MKMapPointForCoordinate(c10);
    CLLocationCoordinate2D c11 = {52.38977059790416, 4.917798042297363};
    points[10] = MKMapPointForCoordinate(c11);
    CLLocationCoordinate2D c12 = {52.39047774005495, 4.915909767150879};
    points[11] = MKMapPointForCoordinate(c12);
    CLLocationCoordinate2D c13 = {52.391708664181856, 4.912734031677246};
    points[12] = MKMapPointForCoordinate(c13);
    CLLocationCoordinate2D c14 = {52.39202293718115, 4.911231994628906};
    points[13] = MKMapPointForCoordinate(c14);
    CLLocationCoordinate2D c15 = {52.39231101879802, 4.909858703613281};
    points[14] = MKMapPointForCoordinate(c15);
    CLLocationCoordinate2D c16 = {52.392834798738555, 4.908356666564941};
    points[15] = MKMapPointForCoordinate(c16);
    CLLocationCoordinate2D c17 = {52.39210150508133, 4.907498359680176};
    points[16] = MKMapPointForCoordinate(c17);
    CLLocationCoordinate2D c18 = {52.391525337232174, 4.906983375549316};
    points[17] = MKMapPointForCoordinate(c18);
    CLLocationCoordinate2D c19 = {52.39094916186164, 4.906339645385742};
    points[18] = MKMapPointForCoordinate(c19);
    CLLocationCoordinate2D c20 = {52.3903205983338, 4.905953407287598};
    points[19] = MKMapPointForCoordinate(c20);
    CLLocationCoordinate2D c21 = {52.38974440723657, 4.905996322631836};
    points[20] = MKMapPointForCoordinate(c21);
    CLLocationCoordinate2D c22 = {52.38906344442449, 4.9060821533203125};
    points[21] = MKMapPointForCoordinate(c22);
    CLLocationCoordinate2D c23 = {52.388408662582734, 4.9063825607299805};
    points[22] = MKMapPointForCoordinate(c23);
    CLLocationCoordinate2D c24 = {52.387780062876814, 4.906811714172363};
    points[23] = MKMapPointForCoordinate(c24);
    CLLocationCoordinate2D c25 = {52.38725622295069, 4.907026290893555};
    points[24] = MKMapPointForCoordinate(c25);
    CLLocationCoordinate2D c26 = {52.38665379935076, 4.907369613647461};
    points[25] = MKMapPointForCoordinate(c26);
    CLLocationCoordinate2D c27 = {52.386313295418596, 4.907541275024414};
    points[26] = MKMapPointForCoordinate(c27);
    CLLocationCoordinate2D c28 = {52.38592040300254, 4.907283782958984};
    points[27] = MKMapPointForCoordinate(c28);
    CLLocationCoordinate2D c29 = {52.38542273425579, 4.90689754486084};
    points[28] = MKMapPointForCoordinate(c29);
    CLLocationCoordinate2D c30 = {52.385056027378766, 4.906468391418457};
    points[29] = MKMapPointForCoordinate(c30);
    CLLocationCoordinate2D c31 = {52.38471551112266, 4.906039237976074};
    points[30] = MKMapPointForCoordinate(c31);
    CLLocationCoordinate2D c32 = {52.38445357375382, 4.905352592468262};
    points[31] = MKMapPointForCoordinate(c32);
    CLLocationCoordinate2D c33 = {52.383929694353775, 4.904279708862305};
    points[32] = MKMapPointForCoordinate(c33);
    
    MKPolygon *polygon = [MKPolygon polygonWithPoints:points count:33];
    [_mapView addOverlay:polygon];
    
    [_button setImage:[UIImage imageNamed:@"btn-start-pressed"]
             forState:UIControlStateHighlighted];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    _broadcaster = [[KRBroadcaster alloc] init];

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
//                [_mapView removeAnnotation:track.pin];
//                [_mapView addAnnotation:track.pin];
            }
        } else if(distance <= 0.0f) {
            volume = 1.0;
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
//                [_mapView removeAnnotation:track.pin];
//                [_mapView addAnnotation:track.pin];
            }
        } else {
            track.audioPlayer.volume = volume;
            if(track.pin.isPlaying != NO) {
                //[track.audioPlayer stop];
                track.pin.isPlaying = NO;
//                [_mapView removeAnnotation:track.pin];
//                [_mapView addAnnotation:track.pin];
            }
        }
        [self broadcastTrack:track.trackId
                    location:location
               trackLocation:track.location
                playPosition:track.audioPlayer.currentTime
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
        [_locationManager startUpdatingLocation];
        [_button setImage:[UIImage imageNamed:@"btn-stop-passive"]
                 forState:UIControlStateNormal];
        [_button setImage:[UIImage imageNamed:@"btn-stop-pressed"]
                 forState:UIControlStateHighlighted];
        
    } else {
        [_locationManager stopUpdatingLocation];
        for(KRTrack *track in _tracks.allValues) {
            [track.audioPlayer stop];
            track.pin.isPlaying = NO;
//            [_mapView removeAnnotation:track.pin];
//            [_mapView addAnnotation:track.pin];
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
                    playPosition:track.audioPlayer.currentTime
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
//        [_mapView addAnnotation:track.pin];
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

//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>) annotation {
//    MKPinAnnotationView *newAnnotation = nil;
//    if([annotation isKindOfClass:[KRMapPin class]]) {
//        KRMapPin *pin = (KRMapPin*)annotation;
//        if(pin.isPlaying) {
//            newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
//                                                            reuseIdentifier:@"GreenPin"];
//            newAnnotation.pinColor = MKPinAnnotationColorGreen;
//            //newAnnotation.animatesDrop = YES;
//            newAnnotation.canShowCallout = YES;
//        } else {
//            newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
//                                                            reuseIdentifier:@"RedPin"];
//            newAnnotation.pinColor = MKPinAnnotationColorRed;
//            //newAnnotation.animatesDrop = YES;
//            newAnnotation.canShowCallout = YES;
//        }
//    }
//    return newAnnotation;
//}

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
//    CLLocationDistance distance = [newLocation distanceFromLocation:_currentLocation];
//    if(distance > 3000) {
        [self testMode];
//    } else {
//        _currentLocation = newLocation;
//        // For testing only (location of Kijkruimte) - JBG
//        [self updateTracks:_currentLocation];
//        NSLog(@"LOCATION!!!!");
//    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

@end
