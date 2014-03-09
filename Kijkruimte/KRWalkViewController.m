//
//  KRWalkViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRViewController.h"
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

-(void)toWalk {
	self.walk = self.walks[0];
	[self performSegueWithIdentifier:@"toWalk" sender:self];
}

#pragma mark -
#pragma mark KRGetWalksDelegate <NSObject>

-(void)handleWalks:(NSArray*)walks {
	for(KRWalk *walk in walks) {
		NSLog(@"Got walk: %@", walk.title);
		NSLog(@"Got scUser: %@", walk.scUser);
	}
	self.walks = walks;
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * walks.count,
											 self.scrollView.frame.size.height);
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
    self.pageControl.currentPage = page;
}


@end
