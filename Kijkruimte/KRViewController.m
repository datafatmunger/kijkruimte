//
//  KRViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <math.h>
#import "KRAppDelegate.h"
#import "KRInfoViewController.h"
#import "KRMapPin.h"
#import "KRTrackDetail.h"
#import "KRViewController.h"
#import "KRWalk.h"

#define MAP_ZOOM_LEVEL 0.01

@interface KRViewController (Private)

-(NSString*)generateUuidString;
-(void)getTracks;
-(double)randomDoubleBetween:(double)smallNumber and:(double)bigNumber;
-(void)testModeUpdate;
-(void)testMode;

@end

@implementation KRViewController {
	dispatch_source_t degradeTimer_;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	_canRetry = NO;
    _isRunning = NO;
    _loadCount = 0;
    _tracks = [NSMutableDictionary new];
	_bleTracks = [NSMutableArray new];
    _guid = [self generateUuidString];
    
    double x1 = 100.0, y1 = 50.0, x2 = 250.0, y2 = 70.0;
    
    [self angleBetween2Pointsx1:x1 y1:y1 x2:x2 y2:y2];
    
    [_actView startAnimating];
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen height: %f", screenRect.size.height);
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _controls.frame = CGRectMake(_controls.frame.origin.x,
                                                      self.view.frame.size.height - _controls.frame.size.height,
                                                      _controls.frame.size.width,
                                                      _controls.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         NSLog(@"Done!");
                     }];
	
	_currentLocation = self.walk.location;
	NSLog(@"Location: %f, %f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
	NSLog(@"Radius: %f", self.walk.radius);
	
    MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span = MKCoordinateSpanMake(MAP_ZOOM_LEVEL, MAP_ZOOM_LEVEL);
	region.span = span;
	region.center = _currentLocation.coordinate;
    _mapView.region = region;
	
	
	KRWalk *huhWalk = (KRWalk*)self.walk;
	for(id <MKOverlay> polygon in huhWalk.polygons) {
		[_mapView addOverlay:polygon];
	}
	
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
	
	[self handleHuhTracks];
	
	if(self.walk.credits) {
		_info.hidden = NO;
	}
	
	if(customWalk) {
		_doneButton.hidden = YES;
	}
	
	[_button setTitle:@"Start" forState:UIControlStateNormal];
	_button.backgroundColor = [UIColor colorWithRed:255 green:242 blue:0 alpha:1.0];
	[_button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	((KRInfoViewController*)segue.destinationViewController).creditsUrlStr = [NSString stringWithFormat:@"http://hearushere.nl/%@", self.walk.credits];
}

-(void)angleBetween2Pointsx1:(double)x1 y1:(double)y1 x2:(double)x2 y2:(double)y2 {
    
    double deltaY = y2 - y1;
    double deltaX = x2 - x1;
    double degrees = atan2(deltaY, deltaX) * 180 / M_PI;
    
    NSLog(@"degrees: %f", degrees);
}

-(void)updateTracks:(CLLocation*)location {
	if(!_isRunning) return;
	
	BOOL playingGeo = NO;
	
    for(int i = 0; i < [_tracks count]; i++) {
        KRTrack *track = [[_tracks allValues] objectAtIndex:i];
		
		if(track.location.coordinate.latitude == 0.0 ||
		   track.location.coordinate.longitude == 0.0)
			continue; // If the track doesn't have coordinates, just continue - JBG
		
        NSLog(@"comparing %f, %f with %f, %f",
              location.coordinate.latitude,
              location.coordinate.longitude,
              track.location.coordinate.latitude,
              track.location.coordinate.longitude);
		
        CLLocationDistance distance = [location distanceFromLocation:track.location];
        NSLog(@"You are %fm from sound: %@", distance, track.trackId);
		
		double radius = track.radius > 1 ? track.radius : self.walk.radius;
        double volume = 0.0;
        if(distance <= radius && distance > 0.0f) {
            volume = (log(distance/radius) * -1)/4;
            volume = volume > 1.0 ? 1.0 : volume;
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
                //                [_mapView removeAnnotation:track.pin];
                //                [_mapView addAnnotation:track.pin];
            }
			playingGeo = YES;
        } else if(distance <= 0.0f) {
            volume = 1.0;
            track.audioPlayer.volume = volume;
            if(track.audioPlayer != nil && ![track.audioPlayer isPlaying]) {
                [track.audioPlayer play];
                track.pin.isPlaying = YES;
                //                [_mapView removeAnnotation:track.pin];
                //                [_mapView addAnnotation:track.pin];
            }
			playingGeo = YES;
        } else {
            track.audioPlayer.volume = volume;
            if(track.pin.isPlaying != NO) {
                //[track.audioPlayer stop];
                track.pin.isPlaying = NO;
                //                [_mapView removeAnnotation:track.pin];
                //                [_mapView addAnnotation:track.pin];
            }
			playingGeo = playingGeo || NO;
        }

        track.pin.subtitle = [NSString stringWithFormat:@"Volume: %f", volume];
        [_mapView setNeedsDisplay];
    }
	
	
	if(self.background.audioPlayer != nil && ![self.background.audioPlayer isPlaying]) {
		self.background.audioPlayer.volume = 1.0;
		[self.background.audioPlayer play];
		self.background.pin.isPlaying = YES;
	}
}

-(IBAction)start {
    NSLog(@"Start and Stop");
	
    _isRunning = !_isRunning;
	
	if(self.walk.autoPlay) {
		NSLog(@"AUTOPLAYING!");
		for(KRTrack *track in _tracks.allValues) {
			track.audioPlayer.volume = 0.0;
			[track.audioPlayer play];
		}
	}
    
    if(_isRunning) {
        _currentLocation = self.walk.location;
        [_locationManager startUpdatingLocation];
		
		for(KRTrack *track in self.bleTracks) {
			NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:track.uuid];
			CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuid.UUIDString];
			if(![_locationManager.monitoredRegions containsObject:region]) {
				[_locationManager startMonitoringForRegion:region];
			} else if(![_locationManager.rangedRegions containsObject:region]) {
				[_locationManager startRangingBeaconsInRegion:region];
			}
		}
		
		[_button setTitle:@"Stop" forState:UIControlStateNormal];
		_button.backgroundColor = [UIColor darkTextColor];
		[_button setTitleColor:[UIColor colorWithRed:255 green:242 blue:0 alpha:1] forState:UIControlStateNormal];
    } else {
		[self stop];
    }
}

-(void)stop {
	[_locationManager stopUpdatingLocation];
	for(KRTrack *track in self.bleTracks) {
		NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:track.uuid];
		CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:uuid.UUIDString];
		[_locationManager stopMonitoringForRegion:region];
		[track.audioPlayer stop];
	}
	
	for(KRTrack *track in _tracks.allValues) {
		[track.audioPlayer stop];
		track.pin.isPlaying = NO;
		//            [_mapView removeAnnotation:track.pin];
		//            [_mapView addAnnotation:track.pin];
	}
	
	if(_loadCount == _tracks.count)
		_messageView.hidden = YES;
	[_timer invalidate];
	
	[_button setTitle:@"Start" forState:UIControlStateNormal];
	_button.backgroundColor = [UIColor colorWithRed:255 green:242 blue:0 alpha:1.0];
	[_button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
}

-(IBAction)toInfo:(id)sender {
    [self performSegueWithIdentifier:@"toInfo" sender:sender];
}

-(IBAction)back:(id)sender {
	[self stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (KRTrack*)getTrackWithBeacon:(CLBeacon*)beacon {
	for(KRTrack *track in self.bleTracks) {
		if([track.uuid isEqualToString:beacon.proximityUUID.UUIDString] &&
		   [track.major isEqualToNumber:beacon.major] &&
		   [track.minor isEqualToNumber:beacon.minor]) {
			return track;
		}
	}
	return nil;
}

- (KRTrack*)getTrackWithRegion:(CLBeaconRegion*)region {
	for(KRTrack *track in self.bleTracks) {
		if([track.uuid isEqualToString:region.proximityUUID.UUIDString]) {
			return track;
		}
	}
	return nil;
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

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
	MKPolygon *polygon = (MKPolygon *)overlay;
	MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
	renderer.fillColor = [UIColor colorWithRed:253.0f/255 green:232.0f/255 blue:17.0f/255 alpha:0.33f];
	renderer.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9];
	renderer.lineWidth = 3;
	return renderer;
}

#pragma mark -
#pragma mark KRTrackDelegate

-(void)trackDataLoaded:(NSString*)trackId {
    [self updateTracks:_currentLocation];
    if(++_loadCount >= _tracks.count + self.bleTracks.count) {
        [_actView stopAnimating];
        _messageView.hidden = YES;
    }
    [_messageLabel setText:[NSString stringWithFormat:@"Loading...%ld of %lu", (long)_loadCount, (unsigned long)_tracks.count + self.bleTracks.count]];
}

-(void)trackDataError:(NSString*)message {
    [_actView stopAnimating];
    NSString *instructions = [NSString stringWithFormat:@"%@ (Tap to retry)", message];
    [_messageLabel setText:instructions];
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
        [self updateTracks:_currentLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager
		didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
	if(!_isRunning) return;
	for(CLBeacon *beacon in beacons) {
		KRTrack *track = [self getTrackWithBeacon:beacon];
		if(!track) return;
		
		double radius = track.radius > 1 ? track.radius : self.walk.radius;
		double distance = beacon.accuracy;
		if(distance < 0) return;
		
		double volume = 0.0;
		if(distance <= radius && distance > 0.0f) {
			volume = (log(distance/radius) * -1)/4;
			volume = volume > 1.0 ? 1.0 : volume;
			if(isnan(volume)) return;
			
			[track setFilteredVolume:volume];
			
			NSLog(@"Did range %@ %ld %ld at %f, vol: %f", beacon.proximityUUID.UUIDString, (long)beacon.major.integerValue, (long)beacon.minor.integerValue, distance, track.audioPlayer.volume);
			if(track.audioPlayer != nil && !track.audioPlayer.isPlaying) {
				[track.audioPlayer play];
			}
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
			  withError:(NSError *)error {
	NSLog(@"rangingBeaconsDidFailForRegion %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager
		 didEnterRegion:(CLRegion *)region {
	NSLog(@"didEnterRegion");
	[_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}

- (void)locationManager:(CLLocationManager *)manager
		  didExitRegion:(CLRegion *)region {
	NSLog(@"didExitRegion");
	[_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
	
	KRTrack *track = [self getTrackWithRegion:(CLBeaconRegion*)region];
	if(track) {
		track.audioPlayer.volume = 0.0;
		[track.audioPlayer stop];
	}
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
			  withError:(NSError *)error {
	NSLog(@"monitoringDidFailForRegion %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark KRMessageViewDelegate <NSObject>

-(void)messageViewTapped:(KRMessageView*)view {
	if(_canRetry) {
		_canRetry = NO;
		[_messageLabel setText:@"Retrying..."];
		[self getTracks];
	}
}

#pragma mark -
#pragma mark KRViewController (Private)

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
    double randLat = [self randomDoubleBetween:self.walk.minLat and:self.walk.maxLat];
    double randLng = [self randomDoubleBetween:self.walk.minLng and:self.walk.maxLng];
    
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

#pragma mark - HUH Track details

- (void)handleHuhTracks {
	KRWalk *huhWalk = (KRWalk*)self.walk;
	for(KRSound *sound in huhWalk.sounds) {
		if(!sound.url) continue;
		KRTrack *track = [[KRTrack alloc] initWithSound:sound];
		track.delegate = self;
		
		if(sound.background) {
			self.background = track;
		} else if(sound.bluetooth) {
			[self.bleTracks addObject:track];
		} else {
			[_tracks setObject:track forKey:track.trackId];
		}
		[track getDataWithSound:sound];
	}
	
	// If we have bleTracks, but no background we need one play in the background - JBG
	if(self.bleTracks.count > 0 && !self.background) {
		self.background = [[KRTrack alloc] initWithSilence];
	}
	
	[_messageLabel setText:[NSString stringWithFormat:@"Loading audio...%ld of %lu", (long)_loadCount, (unsigned long)_tracks.count + self.bleTracks.count]];
}

@end
