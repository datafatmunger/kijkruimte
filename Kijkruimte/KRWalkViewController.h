//
//  KRWalkViewController.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "KRGetWalks.h"
#import "KRWalk.h"

@interface KRWalkViewController : UIViewController <
KRGetWalksDelegate
>

@property(nonatomic,weak)IBOutlet UIPageControl *pageControl;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak)IBOutlet MKMapView *mapView;

@property(nonatomic,strong)KRWalk *walk;
@property(nonatomic,strong)NSArray *walks;

-(IBAction)start:(id)sender;

@end
