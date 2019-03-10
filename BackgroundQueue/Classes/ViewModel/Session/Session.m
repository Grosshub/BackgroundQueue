//
//  Session.m
//  Test
//
//  Created by Alexey Gross on 05/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import "Session.h"

@implementation Session

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithID:(NSInteger)idNumber {
    self = [super init];
    if (self) {
        _idNumber = idNumber;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Session with ID: %lu has been deallocated", self.idNumber);
}

@end
