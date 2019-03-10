//
//  Task.m
//  Test
//
//  Created by Alexey Gross on 05/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "Task.h"

@implementation Task

- (id)initWithType:(TaskType)processType urlString:(NSString *)urlString colorTheme:(TaskCellColorTheme)colorTheme {
    self = [super init];
    if (self) {
        
        _type = processType;
        _dateStarted = [NSDate date];
        _status = TaskStatus_New;
        _urlString = urlString;
        _colorTheme = colorTheme;
    }
    return self;
}

- (void)updateWithStatus:(TaskStatus)processStatus {
    self.status = processStatus;
}

- (NSString *)log {
    NSMutableString * log = [NSMutableString string];
    
    if (self.type == TaskType_Cloud) {
        [log appendString:@"Cloud Sync"];
    } else if (self.type == TaskType_Microsites) {
        [log appendString:@"Microsites Sync"];
    } else if (self.type == TaskType_Email) {
        [log appendString:@"Email Sending"];
    } else if (self.type == TaskType_SMS) {
        [log appendString:@"SMS Sending"];
    }
    
    [log appendString:[NSString stringWithFormat:@" (ID: %lu)", self.taskId]];
    
    return log;
}

#pragma mark - NSOperation overriding

- (void)start {
    
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES; //Default is NO so overriding it to return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)main {
    
    if (self.isCancelled) {
        return;
    }
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager * manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL * URL = [NSURL URLWithString:self.urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask * downloadTask;
    downloadTask = [manager downloadTaskWithRequest:request
                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                               
                                               if (self.isCancelled) {
                                                   self.status = TaskStatus_Failed;
                                                   [self finish];
                                                   return;
                                               }
                                               
                                               NSInteger progress = uploadProgress.fractionCompleted * 100;
                                               self.progress = progress;
                                               self.status = TaskStatus_Pending;
                                               
                                               if (self.updateBlock) {
                                                   self.updateBlock(self);
                                               }
                                           }
                                        destination:nil
                                  completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                                      
                                      if (error || self.isCancelled) {
                                          self.status = TaskStatus_Failed;
                                      } else {
                                          self.status = TaskStatus_Success;
                                      }
                                      
                                      [self finish];
                                  }];
    [downloadTask resume];
}

- (void)finish {
    
    [self willChangeValueForKey:@"isExecuting"];
    self->executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self->finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
