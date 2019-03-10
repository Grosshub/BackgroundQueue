//
//  GCDController.m
//  Test
//
//  Created by Alexey Gross on 03/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "GCDController.h"
#import "Session.h"
#import "AFNetworking.h"
#import "TaskCell.h"
#import "CloudTask.h"
#import "EmailTask.h"
#import "SmsTask.h"
#import "Constants.h"

@interface GCDController ()

@property (nonatomic) NSMutableArray * tasks;
@property (nonatomic) NSMutableArray * sessions;
@property (nonatomic) Session * currentSession;

@property (nonatomic) TaskCellColorTheme sessionColorTheme;

@end

@implementation GCDController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessions = [[NSMutableArray alloc] init];
    self.tasks = [[NSMutableArray alloc] init];
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UIButton events

- (IBAction)startNewSession:(id)sender {
    
    // Each session has a specific color theme
    if (self.sessionColorTheme == TaskCellColorTheme_Purple) {
        self.sessionColorTheme = TaskCellColorTheme_Blue;
    } else if (self.sessionColorTheme == TaskCellColorTheme_Blue) {
        self.sessionColorTheme = TaskCellColorTheme_Orange;
    } else if (self.sessionColorTheme == TaskCellColorTheme_Orange || self.sessionColorTheme == TaskCellColorTheme_None) {
        self.sessionColorTheme = TaskCellColorTheme_Purple;
    }
    
    // Create a new session
    NSString * session_id = [NSString stringWithFormat:@"%lu", self.sessions.count + 1];
    __block Session * session = [[Session alloc] initWithID:session_id.integerValue];
    
    // Create queue group for session
    dispatch_group_t group = dispatch_group_create();
    session.queueGroup = group;
    
    // Create a new queue for session
    const char * queueID = [session_id UTF8String];
    dispatch_queue_t queue = dispatch_queue_create(queueID, DISPATCH_QUEUE_CONCURRENT);
    session.queue = queue;
    [self.sessions addObject:session];
    
    self.currentSession = session;
    
    NSLog(@"Total sessions in work: %lu", self.sessions.count);
    
    // We got two important task need to be implemented before other incoming tasks by user request
    
    dispatch_group_enter(group);
    [self runCloudTaskInSession:session completionHandler:^(BOOL success) {
        
        if (success) {
            // You must update the session in which the synchronization was performed
            session.cloudUrlString = kConstantUrlPath_Image_SmallestSize;
            NSLog(@"Cloud sync: successfully. URL string is configured");
        } else {
            NSLog(@"Cloud sync: failed");
        }
        
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self runMicrositesTaskInSession:session completionHandler:^(BOOL success) {
        
        if (success) {
            // You must update the session in which the synchronization was performed
            session.cloudUrlString = kConstantUrlPath_Image_SmallestSize;
            NSLog(@"Cloud sync: successfully. URL string is configured");
        } else {
            NSLog(@"Cloud sync: failed");
        }
        
        dispatch_group_leave(group);
    }];
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"Barrier");
    });
}

- (IBAction)sendEmailButtonTap:(id)sender {
    [self runEmailTaskInSession:self.currentSession];
}

- (IBAction)sendSmsButtonTap:(id)sender {
    [self runSmsTaskInSession:self.currentSession];
}

#pragma mark - Business Logic

- (void)runCloudTaskInSession:(Session *)session completionHandler:(CompletionHandler)completionHandler {
    
    CloudTask * task = [[CloudTask alloc] initWithType:TaskType_Cloud urlString:kConstantUrlPath_Image_MediumSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        task.taskId = self.tasks.count + 1;
        [self.tasks insertObject:task atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    dispatch_async(session.queue, ^{
        
        [self runTask:task progressHandler:^(NSInteger progress, id object) {
            
            NSLog(@"Cloud sync: %lu%%", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTask:(Task *)object status:TaskStatus_Pending];
            });
            
        } completionHandler:^(BOOL success) {
           completionHandler(success);
       }];
        
    });
}

- (void)runMicrositesTaskInSession:(Session *)session completionHandler:(CompletionHandler)completionHandler {
    
    CloudTask * task = [[CloudTask alloc] initWithType:TaskType_Microsites urlString:kConstantUrlPath_Image_MediumSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        task.taskId = self.tasks.count + 1;
        [self.tasks insertObject:task atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    dispatch_async(session.queue, ^{
        
        [self runTask:task progressHandler:^(NSInteger progress, id object) {
            
            NSLog(@"Microsites sync: %lu%%", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTask:(Task *)object status:TaskStatus_Pending];
            });
            
        } completionHandler:^(BOOL success) {
            completionHandler(success);
        }];
        
        // Block the queue till the downloading task is not finished
        dispatch_group_wait(session.queueGroup, DISPATCH_TIME_FOREVER);
    });
}

- (void)runEmailTaskInSession:(Session *)session {
    
    // On request, we can add a mail sending task to the current queue and execute it asynchronously
    CloudTask * task = [[CloudTask alloc] initWithType:TaskType_Email urlString:kConstantUrlPath_Image_SmallSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        task.taskId = self.tasks.count + 1;
        [self.tasks insertObject:task atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    dispatch_async(session.queue, ^{
        
        [self runTask:task progressHandler:^(NSInteger progress, id object) {
            
            NSLog(@"Email sending: %lu%%", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTask:(Task *)object status:TaskStatus_Pending];
            });
            
        } completionHandler:^(BOOL success) {
            
            if (!success) {
                NSLog(@"Email sending: failed");
            } else {
                NSLog(@"Email sending: successfully");
            }
        }];
        
    });
}

- (void)runSmsTaskInSession:(Session *)session {
    
    CloudTask * task = [[CloudTask alloc] initWithType:TaskType_SMS urlString:kConstantUrlPath_Image_SmallSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        task.taskId = self.tasks.count + 1;
        [self.tasks insertObject:task atIndex:0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    dispatch_async(session.queue, ^{
        
        NSLog(@"Before SMS has not been sent, check URL: %@ (session_id: %lu)", session.cloudUrlString, session.idNumber);
        [self runTask:task progressHandler:^(NSInteger progress, id object) {
            
            NSLog(@"SMS sending: %lu%%", progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateTask:(Task *)object status:TaskStatus_Pending];
            });
            
        } completionHandler:^(BOOL success) {
            
            if (!success) {
                NSLog(@"SMS send: failed");
            } else {
                NSLog(@"SMS send: successfully");
            }
        }];
        
    });
}

- (void)runTask:(Task *)task progressHandler:(ProgressHandler)progressHandler completionHandler:(CompletionHandler)completionHandler {
    
    __weak GCDController * selfWeak = self;
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager * manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL * URL = [NSURL URLWithString:task.urlString];
    NSURLRequest * request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask * downloadTask;
    downloadTask = [manager downloadTaskWithRequest:request
                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                  
                                               NSInteger progress = uploadProgress.fractionCompleted * 100;
                                               task.progress = progress;
                                               if (progressHandler) {
                                                   progressHandler(progress, task);
                                               }
                                           }
                                        destination:nil
                                  completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
                                         
                                      if (error) {
                                          [selfWeak updateTask:task status:TaskStatus_Failed];
                                          completionHandler(NO);
                                      } else {
                                          [selfWeak updateTask:task status:TaskStatus_Success];
                                          completionHandler(YES);
                                      }
                                  }];
    [downloadTask resume];
}

#pragma mark - VC private methods

- (void)updateTask:(Task *)task status:(TaskStatus)status {
    
    Task * taskToUpdate = [self.tasks objectAtIndex:[self.tasks indexOfObject:task]];
    taskToUpdate.status = status;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TaskCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[TaskCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"Cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Task * task = self.tasks[indexPath.row];
    [cell updateWithTask:task];

    return cell;
}

@end
