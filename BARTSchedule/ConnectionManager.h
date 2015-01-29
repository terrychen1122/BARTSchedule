//
//  ConnectionManager.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/3/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripInfo.h"

/*
 *  ConnectionManager: responsible for sending HTTP request
 */

@interface ConnectionManager : NSObject

- (id)initWithDepart:(NSString *)depart
          AndArrival:(NSString *)arrival
              AtDate:(NSString *)date;

- (NSArray *)fireHTTPrequestWithResponse:(NSURLResponse **)res
                                   error:(NSError **)e; // send HTTP request to get all trips betweeen depart and arrival at a date
- (TripInfo *)fireSingleHTTPAtDepartTime:(NSString *)time
                           WithResponse:(NSURLResponse **)res
                                  error:(NSError **)e;  // send HTTP request to get one trip between depart and arrival based on depart time

@end
