//
//  Task.h
//  Test
//
//  Created by Alexey Gross on 05/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Constants.h"

@interface Task : NSOperation  {
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, assign) NSInteger taskId;

@property (nonatomic, assign) TaskType type;
@property (nonatomic, assign) TaskStatus status;
@property (nonatomic) NSDate * dateStarted;

@property (nonatomic, copy) NSString * urlString;

@property (nonatomic, assign) TaskCellColorTheme colorTheme;
@property (nonatomic, assign) double progress;

@property (nullable, copy) void (^updateBlock)(Task * task);

- (id)initWithType:(TaskType)processType urlString:(NSString *)urlString colorTheme:(TaskCellColorTheme)colorTheme;
- (void)updateWithStatus:(TaskStatus)processStatus;
- (NSString *)log;

@end
