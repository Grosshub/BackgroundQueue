//
//  CloudTask.m
//  Test
//
//  Created by Alexey Gross on 05/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "CloudTask.h"

@implementation CloudTask

/*
 NSLog(@"cloud has been started. process_id: %li", (long)self.taskId);
 
 NSURL * url = [NSURL URLWithString:@"https://www.dropbox.com/s/sj0acouqlkfbvww/01.png?dl=0"];
 NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
 [NSURLConnection sendAsynchronousRequest:request
 queue:[NSOperationQueue mainQueue]
 completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
 
 [self willChangeValueForKey:@"isExecuting"];
 self->executing = NO;
 [self didChangeValueForKey:@"isExecuting"];
 
 [self willChangeValueForKey:@"isFinished"];
 self->finished = YES;
 [self didChangeValueForKey:@"isFinished"];
 
 NSLog(@"cloud is finished. process_id: %li", (long)self.taskId);
 }];
 */

@end
