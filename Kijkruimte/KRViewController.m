//
//  KRViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/24/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRTrackDetail.h"
#import "KRViewController.h"

@interface KRViewController ()

@end

@implementation KRViewController

-(void)viewDidLoad {
    [super viewDidLoad];
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
        [detailAPI getTrackDetail:track.trackId];
    }
}

-(void)handleGetTracksError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark SCGetUserTracksDelegate

-(void)handleDetail:(KRTrackDetail*)detail {
    NSLog(@"STREAM URL: %@", detail.streamUrl);
}

-(void)handleGetDetailError:(NSString*)message {
    NSLog(@"ERROR: %@", message);
}

@end
