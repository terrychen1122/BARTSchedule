//
//  RouteManager.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "RouteManager.h"
#import "XMLDocument/SMXMLDocument.h"

@interface RouteManager()
@property (strong, nonatomic) NSString *depart; // depart station
@property (strong, nonatomic) NSString *arrival;    // arrival station
@end

@implementation RouteManager
@synthesize depart = _depart;
@synthesize arrival = _arrival;

- (id)initWithDeparture:(NSString *)depart
             andArrival:(NSString *)arrival
{
    self = [super init];
    if (self) {
        self.depart = depart;
        self.arrival = arrival;
    }
    return self;
}

- (NSMutableSet *)parserRouteInfoXMLWithRawData:(NSData *)rawData
{
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:rawData error:&error];
    
    if (error) {
        NSLog(@"error while parsing xml.");
        return nil;
    }
    
    NSMutableSet *routes = [[NSMutableSet alloc] init];
    SMXMLElement *allRoutes = [document childNamed:@"routes"];
    for(SMXMLElement *route in [allRoutes childrenNamed:@"route"]){
        NSArray *stops = [[route childNamed:@"config"].children valueForKey:@"value"];
        NSInteger departIndex = NSNotFound;
        NSInteger destIndex = NSNotFound;
        for (int i = 0; i < [stops count]; i++) {
            if ([[stops objectAtIndex:i] isEqualToString:self.depart]) {
                departIndex = i;
            }else if([[stops objectAtIndex:i] isEqualToString:self.arrival]) {
                destIndex = i;
            }
        }
        if (departIndex != NSNotFound && destIndex != NSNotFound) {
            // depart station must appear before arrival station in a route
            if (departIndex < destIndex) {
                [routes addObject:[route valueWithPath:@"number"]];
            }
        }
    }
    return routes;
}

- (NSMutableArray *)parseRouteScheduleXMLWithRawData:(NSData *)rawData
{
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:rawData error:&error];
    if (error) {
        NSLog(@"error while parsing xml.");
        return nil;
    }
    
    NSMutableArray *trips = [[NSMutableArray alloc] init];
    SMXMLElement *routes = [document childNamed:@"route"];
    for (SMXMLElement *trains in [routes childrenNamed:@"train"]) {
        NSString *departTime = nil;
        NSString *arrivalTime = nil;
        NSString *bikeFlag = nil;
        for (SMXMLElement *stop in [trains childrenNamed:@"stop"]) {
            NSString *station = [stop attributeNamed:@"station"];
            if ([station isEqualToString:self.depart]) {
                // this train doesn't stop at depart station
                if ([stop attributeNamed:@"origTime"] == nil) {
                    break;
                }
                departTime = [stop attributeNamed:@"origTime"];
                bikeFlag = [stop attributeNamed:@"bikeflag"];
            }
            if ([station isEqualToString:self.arrival]) {
                // this train doesn't stop at arrival station
                if ([stop attributeNamed:@"origTime"] == nil) {
                    break;
                }
                arrivalTime = [stop attributeNamed:@"origTime"];
            }
        }
        if (departTime != nil && arrivalTime != nil) {
            TripInfo *trip = [[TripInfo alloc] init];
            trip.departTime = departTime;
            trip.arrivalTime = arrivalTime;
            trip.trainIndex = [[trains attributeNamed:@"index"] integerValue];
            trip.date = [document valueWithPath:@"date"];
            trip.isBikeAllowed = [bikeFlag isEqualToString:@"1"] ? TRUE : FALSE;
            [trips addObject:trip];
        }
    }
    
    return trips;
}

+(TripInfo *)parseSingleScheduleAt:(NSString *)time WithRawData:(NSData *)rawData
{
    NSError *error;
    SMXMLDocument *document = [SMXMLDocument documentWithData:rawData error:&error];
    if (error) {
        NSLog(@"error while parsing xml.");
        return nil;
    }
    SMXMLElement *schedule = [document childNamed:@"schedule"];
    SMXMLElement *request = [schedule childNamed:@"request"];
    for (SMXMLElement *trip in [request childrenNamed:@"trip"]) {
        if ([[trip attributeNamed:@"origTimeMin"] isEqualToString:time]) {
            TripInfo *tripDetail = [[TripInfo alloc] init];
            tripDetail.departTime = time;
            tripDetail.arrivalTime = [trip attributeNamed:@"destTimeMin"];
            tripDetail.date = [trip attributeNamed:@"origTimeDate"];
            tripDetail.fare = [trip attributeNamed:@"fare"];
            SMXMLElement *legend = [trip childNamed:@"leg"];
            tripDetail.trainHeadStation = [legend attributeNamed:@"trainHeadStation"];
            tripDetail.route = [[[legend attributeNamed:@"line"] componentsSeparatedByString:@" "] objectAtIndex:1];
            tripDetail.transfercode = [legend attributeNamed:@"transfercode"];
            tripDetail.isBikeAllowed = [[legend attributeNamed:@"bikeflag"] isEqualToString:@"1"];
            tripDetail.trainIndex = [[legend attributeNamed:@"trainIdx"] integerValue];
            return tripDetail;
        }
    }
    return nil;
}

@end
