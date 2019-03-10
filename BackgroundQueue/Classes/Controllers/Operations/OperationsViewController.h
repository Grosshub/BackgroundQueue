//
//  OperationsViewController.h
//  Test
//
//  Created by Alexey Gross on 11/02/2019.
//  Copyright © 2019 Alexey Gross. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OperationsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end
