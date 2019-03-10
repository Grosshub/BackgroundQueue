//
//  Constants.h
//  Test
//
//  Created by Alexey Gross on 10/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Strings

/* Image URLs */
extern NSString * const kConstantUrlPath_Image_HugeSize;
extern NSString * const kConstantUrlPath_Image_BigSize;
extern NSString * const kConstantUrlPath_Image_MediumSize;
extern NSString * const kConstantUrlPath_Image_SmallSize;
extern NSString * const kConstantUrlPath_Image_SmallestSize;

/* Queue IDs */
extern NSString * const kConstantQueueName_Cloud;
extern NSString * const kConstantQueueName_Microsites;
extern NSString * const kConstantQueueName_Email;
extern NSString * const kConstantQueueName_SMS;

#pragma mark - Blocks

typedef void (^CompletionHandler)(BOOL success);
typedef void (^ProgressHandler)(NSInteger progress, id object);

#pragma mark - Enums

typedef enum {
    
    TaskCellColorTheme_None,
    TaskCellColorTheme_Purple,
    TaskCellColorTheme_Blue,
    TaskCellColorTheme_Orange
    
} TaskCellColorTheme;

typedef enum {
    
    TaskType_Cloud,
    TaskType_Microsites,
    TaskType_Email,
    TaskType_SMS
    
} TaskType;

typedef enum {
    
    TaskStatus_New,
    TaskStatus_Pending,
    TaskStatus_Success,
    TaskStatus_Failed
    
} TaskStatus;

@interface Constants : NSObject

@end
