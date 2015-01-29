//
//  TripInformation.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/3/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripInfo.h"

/*
 *  TripInfoViewController: display information of one single trip
 */

@interface TripInfoViewController : UIViewController

- (void)setTripInfoFrom:(NSString *)orig To:(NSString *)dest WithDetails:(TripInfo *)trip; // pass data from upper level controller to current controller during push segue

@end
