//
//  KRMessageView.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 12/20/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KRMessageView;

@protocol KRMessageViewDelegate <NSObject>

-(void)messageViewTapped:(KRMessageView*)view;

@end

@interface KRMessageView : UIView {
    IBOutlet id<KRMessageViewDelegate> _delegate;
}

@end
