//
//  OperationsViewController.m
//  Test
//
//  Created by Alexey Gross on 11/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "OperationsViewController.h"
#import "TaskCell.h"
#import "CloudTask.h"
#import "MicrositesTask.h"
#import "EmailTask.h"
#import "SmsTask.h"
#import "PendingTasks.h"

@interface OperationsViewController ()

@property (nonatomic) NSMutableArray * tasks;
@property (nonatomic) PendingTasks * pendingTasks;

@property (nonatomic) TaskCellColorTheme sessionColorTheme;
@property (nonatomic) Task * dependencyTask;

@property (nonatomic) NSMutableArray * sessions;

@end

@implementation OperationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tasks = [[NSMutableArray alloc] init];
    self.pendingTasks = [[PendingTasks alloc] init];
    self.sessions = [[NSMutableArray alloc] init];
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancelTask:(id)sender {
    
}

- (IBAction)startNewSessionButtonTap:(id)sender {
    
    // Each session has a specific color theme
    if (self.sessionColorTheme == TaskCellColorTheme_Purple) {
        self.sessionColorTheme = TaskCellColorTheme_Blue;
    } else if (self.sessionColorTheme == TaskCellColorTheme_Blue) {
        self.sessionColorTheme = TaskCellColorTheme_Orange;
    } else if (self.sessionColorTheme == TaskCellColorTheme_Orange || self.sessionColorTheme == TaskCellColorTheme_None) {
        self.sessionColorTheme = TaskCellColorTheme_Purple;
    }
    
    // We are starting with this two tasks
    CloudTask * cloudTask = [self setupCloudTask];
    MicrositesTask * micrositesTask = [self setupMicrositesTask];
    self.dependencyTask = micrositesTask;
    
    // Collect the tasks to keep track the progress
    [self.pendingTasks.cloudOperationsInProgress addObject:cloudTask];
    [self.pendingTasks.micrositesOperationsInProgress addObject:micrositesTask];
    
    // Add tasks to the queue - that's will run them
    [self.pendingTasks.cloudQueue addOperation:cloudTask];
    [self.pendingTasks.micrositesQueue addOperation:micrositesTask];
}

- (IBAction)sendEmailButtonTap:(id)sender {
    
    EmailTask * emailTask = [self setupEmailTask];
    
    [self.pendingTasks.emailOperationsInProgress addObject:emailTask];
    
    [self.pendingTasks.emailQueue addOperation:emailTask];
}

- (IBAction)sendSmsButtonTap:(id)sender {
    
    SmsTask * smsTask = [self setupSmsTask];
    if (self.dependencyTask) {
        [smsTask addDependency:self.dependencyTask];
    }
    
    [self.pendingTasks.smsOperationsInProgress addObject:smsTask];
    
    [self.pendingTasks.smsQueue addOperation:smsTask];
}

#pragma mark - Business Logic

- (CloudTask *)setupCloudTask {
    
    CloudTask * cloudTask = [[CloudTask alloc] initWithType:TaskType_Cloud urlString:kConstantUrlPath_Image_MediumSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        [self.tasks insertObject:cloudTask atIndex:0];
        cloudTask.taskId = self.tasks.count;
    }
    [self.tableView reloadData];
    
    __weak CloudTask * taskTemp = cloudTask;
    cloudTask.completionBlock = ^{
        
        if (taskTemp.isCancelled || taskTemp.status == TaskStatus_Failed) {
            
            [self updateTask:taskTemp status:TaskStatus_Failed];
            return;
        }
        
        // Remove operation from the queue here if needed and reload a table in main queue
        [self updateTask:taskTemp status:TaskStatus_Success];
    };
    
    cloudTask.updateBlock = ^(Task * task) {
        [self updateTask:task status:TaskStatus_Pending];
    };
    
    return cloudTask;
}

- (MicrositesTask *)setupMicrositesTask {
    
    MicrositesTask * micrositesTask = [[MicrositesTask alloc] initWithType:TaskType_Microsites urlString:kConstantUrlPath_Image_MediumSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        [self.tasks insertObject:micrositesTask atIndex:0];
        micrositesTask.taskId = self.tasks.count;
    }
    [self.tableView reloadData];
    
    __weak MicrositesTask * taskTemp = micrositesTask;
    micrositesTask.completionBlock = ^{
        
        if (taskTemp.isCancelled || taskTemp.status == TaskStatus_Failed) {
            
            [self updateTask:taskTemp status:TaskStatus_Failed];
            return;
        }
        
        [self updateTask:taskTemp status:TaskStatus_Success];
    };
    
    micrositesTask.updateBlock = ^(Task * task) {
        [self updateTask:task status:TaskStatus_Pending];
    };
    
    return micrositesTask;
}

- (EmailTask *)setupEmailTask {
    
    EmailTask * emailTask = [[EmailTask alloc] initWithType:TaskType_Email urlString:kConstantUrlPath_Image_SmallSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        [self.tasks insertObject:emailTask atIndex:0];
        emailTask.taskId = self.tasks.count;
    }
    [self.tableView reloadData];
    
    __weak EmailTask * taskTemp = emailTask;
    emailTask.completionBlock = ^{
        
        if (taskTemp.isCancelled || taskTemp.status == TaskStatus_Failed) {
            
            [self updateTask:taskTemp status:TaskStatus_Failed];
            return;
        }
        
        [self updateTask:taskTemp status:TaskStatus_Success];
    };
    
    emailTask.updateBlock = ^(Task * task) {
        [self updateTask:task status:TaskStatus_Pending];
    };
    
    return emailTask;
}

- (SmsTask *)setupSmsTask {
    
    SmsTask * smsTask = [[SmsTask alloc] initWithType:TaskType_SMS urlString:kConstantUrlPath_Image_SmallSize colorTheme:self.sessionColorTheme];
    
    @synchronized (self) {
        [self.tasks insertObject:smsTask atIndex:0];
        smsTask.taskId = self.tasks.count;
    }
    [self.tableView reloadData];
    
    __weak SmsTask * taskTemp = smsTask;
    smsTask.completionBlock = ^{
        
        if (taskTemp.isCancelled || taskTemp.status == TaskStatus_Failed) {
            
            [self updateTask:taskTemp status:TaskStatus_Failed];
            return;
        }
        
        [self updateTask:taskTemp status:TaskStatus_Success];
    };
    
    smsTask.updateBlock = ^(Task * task) {
        [self updateTask:task status:TaskStatus_Pending];
    };
    
    return smsTask;
}

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
    
    TaskCell * cell; //= [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[TaskCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"Cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Task * task = self.tasks[indexPath.row];
    [cell updateWithTask:task];
    
    return cell;
}

#pragma mark - Utils

- (void)showAlert {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Not available"
                                 message:@"The queue model is under development!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * okButton = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          
                                                      }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
