//
//  TripInformation.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/3/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "TripInfoViewController.h"
#import "Constant.h"

@interface TripInfoViewController()
@property (strong, nonatomic) TripInfo* trip;
@property (strong, nonatomic) NSString *orig;
@property (strong, nonatomic) NSString *dest;
@property (weak, nonatomic) IBOutlet UILabel *origStation;
@property (weak, nonatomic) IBOutlet UILabel *destStation;
@property (weak, nonatomic) IBOutlet UILabel *departTime;
@property (weak, nonatomic) IBOutlet UILabel *arriveTIme;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *routeNum;
@property (weak, nonatomic) IBOutlet UILabel *tripHeadStation;
@property (weak, nonatomic) IBOutlet UILabel *trainNumber;
@property (weak, nonatomic) IBOutlet UILabel *transfer;
@property (weak, nonatomic) IBOutlet UILabel *fare;
@property (weak, nonatomic) IBOutlet UILabel *bikeflag;
@end

@implementation TripInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.origStation.text = self.orig;
    self.destStation.text = self.dest;
    self.departTime.text = self.trip.departTime;
    self.arriveTIme.text = self.trip.arrivalTime;
    self.date.text = self.trip.date;
    self.routeNum.text = self.trip.route;
    self.tripHeadStation.text = self.trip.trainHeadStation ? self.trip.trainHeadStation : @"NA";
    self.trainNumber.text = [NSString stringWithFormat:@"%ld", self.trip.trainIndex];
    self.transfer.text = [self transferSwitch:self.trip.transfercode];
    self.fare.text = self.trip.fare ? self.trip.fare : @"NA";
    self.bikeflag.text = self.trip.isBikeAllowed ? @"YES" : @"NO";
}

- (void)setTripInfoFrom:(NSString *)orig To:(NSString *)dest WithDetails:(TripInfo *)trip
{
    self.orig = [NSString stringWithFormat:@"%@(%@)", [self expandAbbreviations:orig], orig];
    self.dest = [NSString stringWithFormat:@"%@(%@)", [self expandAbbreviations:dest], dest];
    self.trip = trip;
}

// get full name by abbreviations
- (NSString *)expandAbbreviations:(NSString *)abbr
{
    if ([abbr isEqualToString:@"24TH"]) {
        return SFStation;
    } else if ([abbr isEqualToString:@"MLBR"]) {
        return Millbrae;
    }
    
    return @"";
}

// get transfer information
- (NSString *)transferSwitch:(NSString *)code
{
    if (!code) {
        return @"NA";
    }
    
    if ([code isEqualToString:@"N"]) {
        return @"Normal Transfer";
    } else if([code isEqualToString:@"T"]) {
        return @"Timed Transfer";
    } else if([code isEqualToString:@"S"]) {
        return @"Scheduled Tranfer";
    }
    
    return @"No Transfer";
}

@end
