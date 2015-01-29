//
//  ViewController.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleTableViewController.h"
#import "ConnectionManager.h"

@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *itemPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *orgStation;
@property (weak, nonatomic) IBOutlet UITextField *destStation;
@property (weak, nonatomic) IBOutlet UITextField *scheduleDate;


@end

