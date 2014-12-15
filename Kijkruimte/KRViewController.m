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
#import "HUHWalk.h"

#define MAP_ZOOM_LEVEL 0.01

dispatch_source_t ble_create_dispatch_timer(double interval, dispatch_queue_t queue, dispatch_block_t block) {
	dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
	if (timer) {
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
		dispatch_source_set_event_handler(timer, block);
		dispatch_resume(timer);
	}
	return timer;
}

@interface KRViewController (Private) <
KRBluetoothScannerDelegate
>

-(NSString*)generateUuidString;
-(void)getTracks;
-(double)randomDoubleBetween:(double)smallNumber and:(double)bigNumber;
-(void)testModeUpdate;
-(void)testMode;

@end

@implementation KRViewController {
	dispatch_source_t degradeTimer_;
	KRTrack *background_;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
	_canRetry = NO;
    _isRunning = NO;
    _loadCount = 0;
    _tracks = [NSMutableDictionary dictionary];
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
	
	
	if([self.walk isKindOfClass:[KRWalk class]]) {
		[_mapView addOverlay:((KRWalk*)self.walk).polygon];
	} else if([self.walk isKindOfClass:[HUHWalk class]]) {
		HUHWalk *huhWalk = (HUHWalk*)self.walk;
		for(id <MKOverlay> polygon in huhWalk.polygons) {
			[_mapView addOverlay:polygon];
		}
	}
	
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
	
	// Is the walk legacy or not? - JBG
	if([self.walk isKindOfClass:[KRWalk class]]) {
		[self getTracks];
	} else {
		[self handleHuhTracks];
	}
	
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
//        [self broadcastTrack:track.trackId
//                    location:location
//               trackLocation:track.location
//                playPosition:track.audioPlayer.currentTime
//                      volume:volume];
        track.pin.subtitle = [NSString stringWithFormat:@"Volume: %f", volume];
        [_mapView setNeedsDisplay];
    }
	
//	if(!playingGeo) {
		background_.audioPlayer.volume = 1.0;
		if(background_.audioPlayer != nil && ![background_.audioPlayer isPlaying]) {
			[background_.audioPlayer play];
			background_.pin.isPlaying = YES;
		}
//	} else {
//		NSLog(@"STOPING BACKGROUND");
//		background_.audioPlayer.volume = 0.0;
//	}
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
		
		//Bluetooth Scanner - JBG
		if(_enableBluetooth) {
			NSLog(@"Enabling bluetooth...");
			self.bleTracks = [NSMutableDictionary dictionary];
			self.bleScanner = [[KRBluetoothScanner alloc] init];
			self.bleScanner.delegate = self;
			[self.bleScanner scan];
			
			self.bleProducer = [[KRBluetoothProducer alloc] init];
			[self.bleProducer start];
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
	for(KRTrack *track in _tracks.allValues) {
		[track.audioPlayer stop];
		track.pin.isPlaying = NO;
		//            [_mapView removeAnnotation:track.pin];
		//            [_mapView addAnnotation:track.pin];
	}
	
	if(_loadCount == _tracks.count)
		_messageView.hidden = YES;
	[_timer invalidate];
	
	//        for(int i = 0; i < [_tracks count]; i++) {
	//            KRTrack *track = [[_tracks allValues] objectAtIndex:i];
	//            [self broadcastTrack:track.trackId
	//                        location:_currentLocation
	//                   trackLocation:track.location
	//                    playPosition:track.audioPlayer.currentTime
	//                          volume:0.0f];
	//        }
	
	if(_enableBluetooth) {
		[self.bleScanner stop];
		[self.bleProducer stop];
	}
	
//	if(degradeTimer_) {
//		dispatch_source_cancel(degradeTimer_);
//		degradeTimer_ = nil;
//	}
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

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleTracks:(NSArray*)tracks {
    SCGetTrackDetail *detailAPI = [[SCGetTrackDetail alloc] init];
    detailAPI.delegate = self;
    for(KRTrack *track in tracks) {
        track.delegate = self;
        
        NSLog(@"TRACK URI: %@", track.uri);
		
        [_tracks setObject:track forKey:track.trackId];
        [detailAPI getTrackDetail:track.trackId];
        
        // Map Stuff - JBG
        KRMapPin *mp = [[KRMapPin alloc] initWithCoordinate:track.location.coordinate
                                                      title:track.title
                                                   subtitle:[NSString stringWithFormat:@"Volume: %f", 0.0]];
        track.pin = mp;
        //        [_mapView addAnnotation:track.pin];
		
		if(track.background) {
			NSLog(@"Setting whisper");
			background_ = track;
		}
		
		if(track.bluetooth)
			_enableBluetooth = YES;
    }

    [_messageLabel setText:[NSString stringWithFormat:@"Loading audio...%ld of %lu", (long)_loadCount, (unsigned long)tracks.count]];
    
}

-(void)handleGetTracksError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
    [_actView stopAnimating];
    [_messageLabel setText:@"FAILED to connect to SoundCloud! (Tap to retry)"];
	_canRetry = YES;
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleDetail:(KRTrackDetail*)detail {
    NSLog(@"STREAM URL: %@", detail.streamUrl);
    KRTrack *track = [_tracks objectForKey:detail.trackId];
    [track getDataWithDetail:detail];
}

-(void)handleGetDetailError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
    [_actView stopAnimating];
    [_messageLabel setText:@"FAILED to connect to SoundCloud! (Tap to retry)"];
	_canRetry = YES;
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
    if(++_loadCount >= [_tracks count]) {
        [_actView stopAnimating];
        _messageView.hidden = YES;
    }
    [_messageLabel setText:[NSString stringWithFormat:@"Loading...%ld of %lu", (long)_loadCount, (unsigned long)_tracks.count]];
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
        // For testing only (location of Kijkruimte) - JBG
        [self updateTracks:_currentLocation];
//        NSLog(@"LOCATION!!!!");
    }
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
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

-(void)getTracks {
    SCGetUserTracks *tracksAPI = [[SCGetUserTracks alloc] init];
    tracksAPI.delegate = self;
	KRWalk *krWalk = (KRWalk*)self.walk;
    [tracksAPI getTracks:krWalk.scUser];
}

#pragma mark - KRBluetoothScannerDelegate <NSObject>

-(void)foundDevice:(NSString*)uuidStr RSSI:(NSNumber*)RSSI {
	if(!_isRunning) return;
	
	double volume = 1.0;
//	if(RSSI.intValue < 0) {
//		volume = -(log(-(RSSI.doubleValue) - 40)) + 4;
//		volume = volume > 1.0 ? 1.0 : volume;
//		NSLog(@"RSSI: %ld, volume: %f, UUID: %@", (long)RSSI.integerValue, volume, uuidStr);
//	}
	
	KRTrack *track = [self.bleTracks objectForKey:uuidStr];
	if(!track) {
		NSArray *array = [_tracks allKeys];
		// Get a random track, if it's tagged "bluetooth" use it - JBG
		do {
			int random = arc4random()%[array count];
			NSString *key = [array objectAtIndex:random];
			track = [_tracks objectForKey:key];
		} while (!track.bluetooth);
		NSLog(@"Starting audio player...for %@, %@", uuidStr, track.title);
		if(![track.audioPlayer isPlaying]) {
			NSLog(@"Recycling track. . .");
			[track.audioPlayer play];
		}
		[self.bleTracks setObject:track forKey:uuidStr];
	}
	
	if(!isnan(volume))
		track.audioPlayer.volume = volume;
	
	// This will slow degrade the audio track so devices that "disappear", don't sound forever - JBG
//	if(!degradeTimer_) {
//		degradeTimer_ = ble_create_dispatch_timer(0.1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//			for(id key in [_tracks allKeys]) {
//				KRTrack *track = [_tracks objectForKey:key];
//				if(track.bluetooth && track.audioPlayer.volume > 0)
//					track.audioPlayer.volume -= 0.01;
//				
//				NSLog(@"degrading volume to: %f", track.audioPlayer.volume);
//			}
//		});
//	}
	
}

-(void)bleNotAuthorized {
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BlueTooth Not Authorized :("
														message:@"Please adjust your iOS settings and try again."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		
		[alert show];
	});
}

-(void)bleNotSupported {
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BLE Not Supported :("
														message:@"Sorry your device does not support BlueTooth Low Energy.  You can continue using the app, but will not hear BlueTooth sounds."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		
		[alert show];
	});
	
}

-(void)bleOff {
	dispatch_async(dispatch_get_main_queue(), ^{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BlueTooth Off :("
														message:@"Please adjust your iOS settings and try again."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		
		[alert show];
	});
}

#pragma mark - HUH Track details

- (void)handleHuhTracks {
	HUHWalk *huhWalk = (HUHWalk*)self.walk;
	for(HUHSound *sound in huhWalk.sounds) {
		KRTrack *track = [[KRTrack alloc] initWithSound:sound];
		track.delegate = self;
		[_tracks setObject:track forKey:track.trackId];
		[track getDataWithSound:sound];
	}
	[_messageLabel setText:[NSString stringWithFormat:@"Loading audio...%ld of %lu", (long)_loadCount, (unsigned long)_tracks.count]];
}

@end
