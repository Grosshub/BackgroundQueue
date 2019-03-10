//
//  ProcessCell.m
//  Test
//
//  Created by Alexey Gross on 10/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "TaskCell.h"
#import "Task.h"

@interface TaskCell()

@property (nonatomic, assign) double progress;
@property (nonatomic) Task * task;

@end

@implementation TaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _progress = 0.0;
        
        _fullscreenProgressView = [[UIView alloc] initWithFrame:CGRectZero];
        _fullscreenProgressView.backgroundColor = [UIColor purpleColor];
        [self addSubview:_fullscreenProgressView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIColor *)getColorForTheme:(TaskCellColorTheme)colorTheme {
    
    if (colorTheme == TaskCellColorTheme_Purple) {
        return [UIColor purpleColor];
    } else if (colorTheme == TaskCellColorTheme_Blue) {
        return [UIColor blueColor];
    } else if (colorTheme == TaskCellColorTheme_Orange) {
        return [UIColor orangeColor];
    }
    
    return [UIColor blackColor];
}

- (void)updateWithProgress:(double)progress {
    self.progress = progress;
    
    if (self.progress >= 100) {
        self.fullscreenProgressView.hidden = YES;
    } else {
        self.fullscreenProgressView.hidden = NO;
    }
}

- (void)updateWithTask:(Task *)task {
    self.task = task;
    
    self.textLabel.text = [self.task log];
    
    UIColor * highlighted_color = [self getColorForTheme:self.task.colorTheme];
    
    if (self.task.status == TaskStatus_Success) {
        self.textLabel.textColor = highlighted_color;
        self.textLabel.text = [self.textLabel.text stringByAppendingString:@" [ DONE ]"];
    } else if (self.task.status == TaskStatus_Pending) {
        self.textLabel.textColor = [UIColor grayColor];
    }
    
    if (self.task.status == TaskStatus_Failed) {
        self.textLabel.textColor = [UIColor redColor];
        self.textLabel.text = [self.textLabel.text stringByAppendingString:@" [ failed ]"];
        self.fullscreenProgressView.hidden = YES;
    } else {
        self.fullscreenProgressView.backgroundColor = highlighted_color;
        [self updateWithProgress:self.task.progress];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxWidth = self.frame.size.width;
    CGFloat progressWidth = maxWidth * (self.progress / 100);
    CGFloat progressHeight = 10;
    
    self.fullscreenProgressView.frame = CGRectMake(0,
                                                   self.frame.size.height - progressHeight,
                                                   progressWidth,
                                                   progressHeight);
}

@end
