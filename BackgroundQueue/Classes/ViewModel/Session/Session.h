//
//  Session.h
//  Test
//
//  Created by Alexey Gross on 05/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property (nonatomic, assign) NSInteger idNumber;
@property (nonatomic, copy) NSString * cloudUrlString;

@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_group_t queueGroup;

- (id)initWithID:(NSInteger)idNumber;

@end
