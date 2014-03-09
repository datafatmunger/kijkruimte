//
//  KRInfoViewController.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 2/10/13.
//  Copyright (c) 2013 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRInfoViewController : UIViewController

@property(nonatomic,weak)IBOutlet UIWebView *webView;

@property(nonatomic,strong)NSString *creditsUrlStr;

-(IBAction)done:(id)sender;

@end
