//
//  KRMessageView.m
//  Kijkruimte
//
//  Created by James Bryan Graves on 12/20/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import "KRMessageView.h"

@implementation KRMessageView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_delegate messageViewTapped:self];
}

@end
