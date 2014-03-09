//
//  KRWalkViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRViewController.h"
#import "KRWalkView.h"
#import "KRWalkViewController.h"

@interface KRWalkViewController ()

@end

@implementation KRWalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self getWalks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	((KRViewController*)segue.destinationViewController).walk = self.walk;
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

#pragma mark -
#pragma mark KRGetWalksDelegate <NSObject>

-(void)handleWalks:(NSArray*)walks {
	for(NSInteger i = 0; i < walks.count; i++) {
		KRWalk *walk = walks[i];
		NSLog(@"Got walk: %@", walk.title);
		KRWalkView *walkView = [[[NSBundle mainBundle] loadNibNamed:@"WalkView" owner:self options:nil] objectAtIndex:0];
		walkView.frame = CGRectMake(self.scrollView.frame.size.width * i,
									0,
									walkView.frame.size.width,
									walkView.frame.size.height);
		NSLog(@"Walk view frame: %@", NSStringFromCGRect(walkView.frame));
		walkView.titleLabel.text = walk.title;
		NSString *urlStr = [NSString stringWithFormat:@"http://hearushere.nl/%@", walk.imageURLStr];
		walkView.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]]];
		walkView.imageView.layer.cornerRadius = walkView.imageView.frame.size.height / 2;
        walkView.imageView.layer.masksToBounds = YES;
		[self.scrollView addSubview:walkView];
	}
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * walks.count,
											 self.scrollView.frame.size.height);
	self.pageControl.numberOfPages = walks.count;
	self.walk = walks[0];
	self.walks = walks;
	
	[self showWalk];
}

-(void)handleGetWalksError:(NSString*)message {
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

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:overlay];
    polygonView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    polygonView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
    polygonView.lineWidth = 3;
    return polygonView;
}


@end
