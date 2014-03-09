//
//  KRInfoViewController.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 2/10/13.
//  Copyright (c) 2013 Hipstart. All rights reserved.
//

#import "KRInfoViewController.h"

@implementation KRInfoViewController

-(void)viewDidLoad {
    NSURL* url = [NSURL URLWithString:self.creditsUrlStr];
    NSURLRequest* request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										 timeoutInterval:30];
    [self.webView loadRequest:request];
}

-(IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
