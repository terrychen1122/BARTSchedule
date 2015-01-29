//
//  ScheduleTableViewController.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  A Table View Controller that displays all schedule of trips between departure station and arrival stations at specific date
 */

@interface ScheduleTableViewController : UITableViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSArray *trips;
@property (strong, nonatomic) NSString *departure;
@property (strong, nonatomic) NSString *arrival;
@property (strong, nonatomic) NSString *date;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@end
