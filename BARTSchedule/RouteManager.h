//
//  RouteManager.h
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripInfo.h"

/*
 *  RouteManager: Manipulate returned XMLData from HTTP Response. For three scanerios, routeinfo xml, routeschedule xml, depart schedule xml, route manager utilizes open source library (XMLDocument) to parse XML and return desired data
 */

@interface RouteManager : NSObject

-(id)initWithDeparture:(NSString *)depart
            andArrival:(NSString *)arrival;
-(NSMutableSet *)parserRouteInfoXMLWithRawData:(NSData *)rawData;   // input raw route info xml data and return a set of routes that have depart station and arrival station
-(NSMutableArray *)parseRouteScheduleXMLWithRawData:(NSData *)rawData;  // input raw route schedule xml data return an array of encapuslated objects (Trip) with depart time and arrival time regarding depart station and arrival station
+(TripInfo *)parseSingleScheduleAt:(NSString *)time WithRawData:(NSData *)rawData;  //  input raw depart schedule xml data and return an encapulsated object with all trip information

@end
