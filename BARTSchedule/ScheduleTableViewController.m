//
//  ScheduleTableViewController.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "TripInfoViewController.h"
#import "TripInfo.h"
#import "ConnectionManager.h"

@interface ScheduleTableViewController ()
@property (strong, nonatomic) TripInfo *currentTrip;    // the chosen trip when hit one row of the table
@end

@implementation ScheduleTableViewController

@synthesize trips = _trips;
@synthesize departure = _departure;
@synthesize arrival = _arrival;
@synthesize date = _date;
@synthesize refreshButton = _refreshButton;
@synthesize currentTrip = _currentTrip;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ - %@", self.departure, self.arrival];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}

- (IBAction)refreshSchedule:(UIBarButtonItem *)sender {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    // put http request implementation into another queue and make it become asynchronous
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        ConnectionManager *connectionMgr = [[ConnectionManager alloc] initWithDepart:self.departure AndArrival:self.arrival AtDate:self.date];
        NSArray *sortedTrips = [connectionMgr fireHTTPrequestWithResponse:&response error:&error];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            self.navigationItem.rightBarButtonItem = sender;
            if (response == nil || error != nil) {  // Network error
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network Connection Error" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [alert show];
            }else{
                self.trips = sortedTrips;
                [self.tableView reloadData];
            }
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"tripDetail"]) {
        TripInfoViewController *tvc = (TripInfoViewController *)segue.destinationViewController;
        [tvc setTripInfoFrom:self.departure To:self.arrival WithDetails:(TripInfo *)sender];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.trips count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TripIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    NSInteger index = [indexPath row];
    TripInfo *trip = [self.trips objectAtIndex:index];
    cell.textLabel.text = [NSString stringWithFormat:@"Depart: %@, Arrive: %@", trip.departTime, trip.arrivalTime];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Train: %ld", trip.trainIndex];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator performSelector:@selector(startAnimating) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    TripInfo *trip = [self.trips objectAtIndex:[indexPath row]];
    
    // Asychronous HTTP request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *departure = trip.departTime;
        NSURLResponse *response = nil;
        NSError *error = nil;
        ConnectionManager *connectionMgr = [[ConnectionManager alloc] initWithDepart:self.departure AndArrival:self.arrival AtDate:self.date];
        TripInfo *tripDetails = [connectionMgr fireSingleHTTPAtDepartTime:departure WithResponse:&response error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            if (tripDetails == nil || response == nil || error != nil) {
                [self performSegueWithIdentifier:@"tripDetail" sender:trip];
            }else{
                [self performSegueWithIdentifier:@"tripDetail" sender:tripDetails];
            }
            
        });
    });
}
@end
