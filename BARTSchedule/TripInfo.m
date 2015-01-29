//
//  TripInfo.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "TripInfo.h"

@implementation TripInfo

@synthesize departTime = _departTime;
@synthesize arrivalTime = _arrivalTime;
@synthesize isBikeAllowed = _isBikeAllowed;
@synthesize trainIndex = _trainIndex;
@synthesize trainHeadStation = _trainHeadStation;
@synthesize fare = _fare;
@synthesize route = _route;
@synthesize transfercode = _transfercode;

-(id)init
{
    self = [super init];
    if(self){
        self.trainHeadStation = nil;
        self.fare = nil;
        self.transfercode = nil;
    }
    return self;
}

@end
