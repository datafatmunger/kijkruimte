//
//  KRWalkViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 08-03-14.
//  Copyright (c) 2014 Hipstart. All rights reserved.
//

#import "KRWalk.h"
#import "KRAppDelegate.h"
#import "KRViewController.h"
#import "KRWalkView.h"
#import "KRWalkViewController.h"

@interface KRWalkViewController ()

@property(nonatomic, assign)BOOL requestMade;

@end

@implementation KRWalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.requestMade = NO;
	
	[self getWalks];
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

-(void)toWalk {
	[self performSegueWithIdentifier:@"toWalk" sender:self];
}

-(IBAction)start:(id)sender {
	[self.startButton setHidden:YES];
	[self.actView startAnimating];
	[self toWalk];
}

-(IBAction)toInfo:(id)sender {
    [self performSegueWithIdentifier:@"toInfo" sender:sender];
}

#pragma mark -
#pragma mark KRGetWalksDelegate <NSObject>

-(void)handleWalks:(NSArray*)walks {
	[self.actView stopAnimating];
	
	for(NSInteger i = 0; i < walks.count; i++) {
		KRWalk *walk = walks[i];
		// Handle custom walk - JBG
		if([@"Verwonderd duin" isEqualToString:walk.title]) {
			self.walk = walk;
			[self.actView stopAnimating];
			[self.startButton setHidden:NO];
			break;
		}
	}
}

-(void)handleGetWalksError:(NSString*)message {
	[self.actView stopAnimating];
	NSLog(@"ERROR: %@", message);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server not reachable :("
													message:@"I tried a few times, but no luck."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	
	[alert show];
}

@end
