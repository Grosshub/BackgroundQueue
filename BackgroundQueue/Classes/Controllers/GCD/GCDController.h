//
//  GCDController.h
//  Test
//
//  Created by Alexey Gross on 03/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCDController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end


