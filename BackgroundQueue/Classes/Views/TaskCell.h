//
//  ProcessCell.h
//  Test
//
//  Created by Alexey Gross on 10/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class Task;

@interface TaskCell : UITableViewCell

@property (nonatomic) UIView * fullscreenProgressView;

- (void)updateWithTask:(Task *)task;

@end
