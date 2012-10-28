//
//  KRTrackCell.h
//  Kijkruimte
//
//  Created by James Bryan Graves on 10/27/12.
//  Copyright (c) 2012 Hipstart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KRTrackCell : UITableViewCell {
    IBOutlet UILabel *name;
    IBOutlet UILabel *volume;
}

@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UILabel *volume;

@end
