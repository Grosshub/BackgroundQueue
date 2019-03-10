//
//  PendingTasks.h
//  BackgroundQueue
//
//  Created by Alexey Gross on 11/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingTasks : NSObject

@property (nonatomic) NSMutableArray * cloudOperationsInProgress;
@property (nonatomic) NSOperationQueue * cloudQueue;

@property (nonatomic) NSMutableArray * micrositesOperationsInProgress;
@property (nonatomic) NSOperationQueue * micrositesQueue;

@property (nonatomic) NSMutableArray * emailOperationsInProgress;
@property (nonatomic) NSOperationQueue * emailQueue;

@property (nonatomic) NSMutableArray * smsOperationsInProgress;
@property (nonatomic) NSOperationQueue * smsQueue;

@end
