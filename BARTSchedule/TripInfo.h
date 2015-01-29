//
//  TripInfo.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 *  TripInfo: encapsulate all information of single trip
 */

@interface TripInfo : NSObject

@property (strong, nonatomic) NSString *departTime;
@property (strong, nonatomic) NSString *arrivalTime;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *trainHeadStation;
@property (strong, nonatomic) NSString *route;
@property (strong, nonatomic) NSString *fare;
@property (strong, nonatomic) NSString *transfercode;
@property BOOL isBikeAllowed;
@property NSInteger trainIndex;

@end
