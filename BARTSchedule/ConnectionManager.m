//
//  ConnectionManager.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/3/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "ConnectionManager.h"
#import "Constant.h"
#import "RouteManager.h"

@interface ConnectionManager()
@property (strong, nonatomic) NSString *depart; // depart station
@property (strong, nonatomic) NSString *arrival;    // arrival station
@property (strong, nonatomic) NSString *date;   // trip date
@end

@implementation ConnectionManager

@synthesize depart = _depart;
@synthesize arrival = _arrival;
@synthesize date = _date;

-(id)initWithDepart:(NSString *)depart AndArrival:(NSString *)arrival AtDate:(NSString *)date
{
    self = [super init];
    if (self) {
        self.depart = depart;
        self.arrival = arrival;
        self.date = date;
    }
    return self;
}

-(NSArray *)fireHTTPrequestWithResponse:(NSURLResponse **)res error:(NSError **)e
{
    // send HTTP request to ask for all routes information
    NSString *path = [NSString stringWithFormat:@"%@/route.aspx?cmd=routeinfo&route=all&date=%@&key=%@", url, self.date, key];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSData *XMLData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:res error:e];
    
    if (*res == nil|| *e != nil) {
        return nil;
    }
    
    RouteManager *routeManager = [[RouteManager alloc] initWithDeparture:self.depart andArrival:self.arrival];
    NSMutableSet *routes = [routeManager parserRouteInfoXMLWithRawData:XMLData];    // get routes contains depart and arrival stations
    NSMutableArray *allTrips = [[NSMutableArray alloc] init];
    for (NSString *route in routes) {   // for each route, send HTTP request to ask for depart time and arrival time for these two stations
        path = [NSString stringWithFormat:@"%@/sched.aspx?cmd=routesched&route=%@&date=%@&key=%@", url, route, self.date, key];
        urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
        XMLData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:res error:e];
        if (*res == nil || *e != nil) {
            return nil;
        }
        NSMutableArray *trips = [routeManager parseRouteScheduleXMLWithRawData:XMLData];
        [trips setValue:route forKey:@"route"];
        [allTrips addObjectsFromArray:trips];
    }
    // sort all trips based on trainIndex (which is equivalent to time)
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trainIndex" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [allTrips sortedArrayUsingDescriptors:sortDescriptors];
}

- (TripInfo *)fireSingleHTTPAtDepartTime:(NSString *)time WithResponse:(NSURLResponse **)res error:(NSError **)e
{
    NSString *path = [NSString stringWithFormat:@"%@/sched.aspx?cmd=depart&orig=%@&dest=%@&time=%@&date=%@&key=%@&b=0&a=1&l=1", url, self.depart, self.arrival, [time stringByReplacingOccurrencesOfString:@" " withString:@""], self.date, key];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSData *XMLData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:res error:e];
    
    if (*res == nil || *e != nil) {
        return nil;
    }
    
    // get all details of one trip
    TripInfo* trip = [RouteManager parseSingleScheduleAt:time WithRawData:XMLData];
    return trip;
}

@end
