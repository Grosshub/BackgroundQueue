//
//  PendingTasks.m
//  BackgroundQueue
//
//  Created by Alexey Gross on 11/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "PendingTasks.h"
#import "Constants.h"

@implementation PendingTasks

- (id)init {
    self = [super init];
    if (self) {
        
        _cloudOperationsInProgress = [[NSMutableArray alloc] init];
        _cloudQueue = [[NSOperationQueue alloc] init];
        _cloudQueue.maxConcurrentOperationCount = 1;
        _cloudQueue.name = kConstantQueueName_Cloud;
        
        _micrositesOperationsInProgress = [[NSMutableArray alloc] init];
        _micrositesQueue = [[NSOperationQueue alloc] init];
        _micrositesQueue.maxConcurrentOperationCount = 1;
        _micrositesQueue.name = kConstantQueueName_Microsites;
        
        _emailOperationsInProgress = [[NSMutableArray alloc] init];
        _emailQueue = [[NSOperationQueue alloc] init];
        _emailQueue.maxConcurrentOperationCount = 1;
        _emailQueue.name = kConstantQueueName_Email;
        
        _smsOperationsInProgress = [[NSMutableArray alloc] init];
        _smsQueue = [[NSOperationQueue alloc] init];
        _smsQueue.maxConcurrentOperationCount = 1;
        _smsQueue.name = kConstantQueueName_SMS;
    }
    return self;
}

@end
