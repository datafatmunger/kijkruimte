//
//  KRWalkViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRAppDelegate.h"
#import "KRViewController.h"
#import "KRWalkView.h"
#import "KRWalkViewController.h"

@interface KRWalkViewController ()

@property(nonatomic, assign)BOOL requestMade;
@property(nonatomic, strong)CLLocationManager *locationManager;
@property(nonatomic, strong)CLLocation *currentLocation;

@end

@implementation KRWalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.requestMade = NO;
	
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	[self.locationManager startUpdatingLocation];
	
	//If walk is custom hide the views - JBG
	if(customWalk) {
		for(UIView *view in self.controls) {
			view.hidden = YES;
		}
	}
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	((KRViewController*)segue.destinationViewController).walk = self.walk;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)getWalks {
    KRGetWalks *walksAPI = [[KRGetWalks alloc] init];
    walksAPI.delegate = self;
    [walksAPI getWalks];
}

-(void)showWalk {
	MKCoordinateRegion region = _mapView.region;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
	region.span = span;
	region.center = self.walk.location.coordinate;
    self.mapView.region = region;
    [self.mapView addOverlay:self.walk.polygon];
}

-(void)toWalk {
	[self performSegueWithIdentifier:@"toWalk" sender:self];
}

-(IBAction)start:(id)sender {
	[self toWalk];
}

-(IBAction)toInfo:(id)sender {
    [self performSegueWithIdentifier:@"toInfo" sender:sender];
}

-(void)showDescription {
	[UIView animateWithDuration:0.25 animations:^{
		if(self.scrollView.frame.size.height == 164) {
			self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
											   self.scrollView.frame.origin.y,
											   self.scrollView.frame.size.width,
											   self.view.frame.size.height);
		} else {
			self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,
											   self.scrollView.frame.origin.y,
											   self.scrollView.frame.size.width,
											   164);
		}
	}];
	NSLog(@"Scroll view frame: %@", NSStringFromCGRect(self.scrollView.frame));
}

#pragma mark -
#pragma mark KRGetWalksDelegate <NSObject>

-(void)handleWalks:(NSArray*)walks {
	[self.actView stopAnimating];
	NSArray *sortedWalks = [walks sortedArrayUsingComparator:^NSComparisonResult(KRWalk *walk1, KRWalk * walk2) {
		CLLocationDistance d1 = [self.currentLocation distanceFromLocation:walk1.location];
		CLLocationDistance d2 = [self.currentLocation distanceFromLocation:walk2.location];
		return [[NSNumber numberWithDouble:d1] compare:[NSNumber numberWithDouble:d2]];
	}];
	
	for(NSInteger i = 0; i < sortedWalks.count; i++) {
		KRWalk *walk = sortedWalks[i];
		
		// Handle custom walk - JBG
		if([customWalk isEqualToString:walk.title]) {
			self.walk = walk;
			[self toWalk];
			break;
		}

		NSLog(@"Got walk: %@", walk.title);
		KRWalkView *walkView = [[[NSBundle mainBundle] loadNibNamed:@"WalkView" owner:self options:nil] objectAtIndex:0];
		walkView.frame = CGRectMake(self.scrollView.frame.size.width * i,
									0,
									self.scrollView.frame.size.width,
									walkView.frame.size.height);
		NSLog(@"Walk view frame: %@", NSStringFromCGRect(walkView.frame));
		walkView.titleLabel.text = walk.title;
		walkView.textView.text = walk.description;
		NSString *urlStr = [NSString stringWithFormat:@"http://hearushere.nl/%@", walk.imageURLStr];
		walkView.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
		walkView.imageView.layer.cornerRadius = walkView.imageView.frame.size.height / 2;
        walkView.imageView.layer.masksToBounds = YES;
		[walkView.button addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
		
		walkView.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", [self.currentLocation distanceFromLocation:walk.location]/1000];
		
		[self.scrollView addSubview:walkView];
	}
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * walks.count,
											 self.scrollView.frame.size.height);
	self.pageControl.numberOfPages = walks.count;
	self.walk = sortedWalks[0];
	self.walks = sortedWalks;
	
	[self showWalk];
}

-(void)handleGetWalksError:(NSString*)message {
	[self.actView stopAnimating];
	NSLog(@"ERROR: %@", message);
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
	
	if(page != self.pageControl.currentPage) {
		self.pageControl.currentPage = page;
		
		[self.mapView removeOverlay:self.walk.polygon];
		self.walk = self.walks[page];
		[self showWalk];
	}
}

#pragma mark -
#pragma mark MKMapKitDelegate

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
	MKPolygon *polygon = (MKPolygon *)overlay;
    MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
    renderer.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.2f];
    renderer.strokeColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.7];
	renderer.lineWidth = 3;
    return renderer;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation {
	self.currentLocation = newLocation;
	if(!self.requestMade) {
		self.requestMade = YES;
		[self getWalks];
	}
	
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}


@end
