//
//  ViewController.m
//  BARTSchedule
//
//  Created by Xuhui Chen on 12/2/14.
//  Copyright (c) 2014 Xuhui Chen. All rights reserved.
//

#import "ViewController.h"
#import "Constant.h"

#define OriStationSelected   1
#define DesStationSelected    2
#define DateSelected  3

@interface ViewController ()
@property (strong, nonatomic) NSArray* stations;
@property int sectionSelected;
@property (strong, nonatomic) NSArray *trips;
@property (strong, nonatomic) NSString *departure;
@property (strong, nonatomic) NSString *arrival;
@end

@implementation ViewController

@synthesize orgStation = _orgStation;
@synthesize destStation = _destStation;
@synthesize scheduleDate = _scheduleDate;
@synthesize datePicker = _datePicker;
@synthesize itemPicker = _itemPicker;
@synthesize stations = _stations;
@synthesize trips = _trips;
@synthesize departure = _departure;
@synthesize arrival = _arrival;

- (void)viewDidLoad {
    [super viewDidLoad];
    // User Interface Set up
    self.orgStation.text = SFStation;
    self.destStation.text = Millbrae;
    self.scheduleDate.text = [self defaultCurrentDate];
    self.sectionSelected = 0;
    
    self.scheduleDate.delegate = self;
    self.orgStation.delegate = self;
    self.destStation.delegate = self;
    self.itemPicker.delegate = self;
    
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setDate:[NSDate date] animated:YES];
    self.datePicker.hidden = YES;
    self.itemPicker.hidden = YES;
}

// Lazy initialisation
- (NSArray *)stations{
    if (!_stations){
        _stations = [[NSArray alloc] initWithObjects:SFStation, Millbrae, nil];
    }
    return _stations;
}

// implementation of pressing serach button
- (IBAction)searchSchedule:(UIButton *)sender {
    if ([self.orgStation.text isEqualToString:self.destStation.text]) { // same departure and arrival station
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid Query: Identical Departure and Arrival Station" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else{
        // parameters setup for sending http request
        self.departure = ([self.orgStation.text isEqualToString:SFStation])? @"24TH" : @"MLBR";
        self.arrival = ([self.destStation.text isEqualToString:SFStation])? @"24TH" : @"MLBR";
        NSString *date = self.scheduleDate.text;
        self.scheduleDate.enabled = NO;
        self.orgStation.enabled = NO;
        self.destStation.enabled = NO;
        
        // display spinning icon when waiting http response
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center = self.view.center;
        [self.view addSubview:activityView];
        activityView.hidesWhenStopped = YES;
        [activityView performSelector:@selector(startAnimating) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
        
        // put all network connection implementation into another queue and make HTTP request become asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSURLResponse *response = nil;
            NSError *error = nil;
            ConnectionManager *connectionMagr = [[ConnectionManager alloc] initWithDepart:self.departure AndArrival:self.arrival AtDate:date];
            NSArray *sortedTrips = [connectionMagr fireHTTPrequestWithResponse:&response error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityView stopAnimating];
                self.scheduleDate.enabled = YES;
                self.orgStation.enabled = YES;
                self.destStation.enabled = YES;
                if (response == nil || error != nil) {  // Network error
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network Connection Error" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [alert show];
                }else {
                    __block NSArray *trips = sortedTrips;
                    self.trips = trips;
                    [self performSegueWithIdentifier:@"fetchXMLResult" sender:@""];
                }
            });
        });
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"fetchXMLResult"]) {
        ScheduleTableViewController *stvc = (ScheduleTableViewController *)[segue destinationViewController];
        stvc.trips = self.trips;
        stvc.departure = self.departure;
        stvc.arrival = self.arrival;
        stvc.date = self.scheduleDate.text;
    }
}

#pragma mark UIPickerView delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.sectionSelected == OriStationSelected || self.sectionSelected == DesStationSelected) {
        return [self.stations count];
    }
    
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.sectionSelected) {
        case OriStationSelected:
            self.orgStation.text = [self.stations objectAtIndex:row];
            break;
        case DesStationSelected:
            self.destStation.text = [self.stations objectAtIndex:row];
            break;
        default:
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.sectionSelected == OriStationSelected || self.sectionSelected == DesStationSelected) {
        return [self.stations objectAtIndex:row];
    }
    return @"";
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Disable appearance of keyboard and determine which picker should display
    
    if (textField == self.scheduleDate) {
        self.itemPicker.hidden = YES;
        self.sectionSelected = DateSelected;
        [self showDatePicker];
        return NO;
    }
    
    if (textField == self.orgStation) {
        if (self.sectionSelected != OriStationSelected) {
            self.itemPicker.hidden = YES;
            self.datePicker.hidden = YES;
            self.sectionSelected = OriStationSelected;
            [self.itemPicker reloadAllComponents];
            [self.itemPicker selectRow:[self.stations indexOfObject:self.orgStation.text] inComponent:0 animated:NO];
            [self showItemPicker];
        }
        return NO;
    }
    
    if (textField == self.destStation) {
        if (self.sectionSelected != DesStationSelected) {
            self.itemPicker.hidden = YES;
            self.datePicker.hidden = YES;
            self.sectionSelected = DesStationSelected;
            [self.itemPicker reloadAllComponents];
            [self.itemPicker selectRow:[self.stations indexOfObject:self.destStation.text] inComponent:0 animated:NO];
            [self showItemPicker];
        }
        return NO;
    }
    return YES;
}

#pragma mark helper functions
-(void)showDatePicker
{
    if (!self.datePicker.hidden) {
        return;
    }
    self.datePicker.hidden = NO;
    self.datePicker.frame = CGRectMake(0, 568, 320, 162);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.datePicker.frame = CGRectMake(0, 406, 320, 162);
                     }];
}

-(void)hideDatePicker
{
    self.datePicker.hidden = YES;
}

-(void)showItemPicker
{
    self.itemPicker.hidden = NO;
    self.itemPicker.frame = CGRectMake(0, 568, 320, 162);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.itemPicker.frame = CGRectMake(0, 406, 320, 162);
                     }];
}

// resign the pickers
- (IBAction)backgroundHit:(UIButton *)sender {
    if (!self.datePicker.hidden) {
        NSDate *selected = [self.datePicker date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/YYYY"];
        self.scheduleDate.text = [dateFormat stringFromDate:selected];
        [self hideDatePicker];
    }
    
    if (!self.itemPicker.hidden) {
        self.itemPicker.hidden = YES;
        self.sectionSelected = 0;
    }
    
}

-(NSString *)defaultCurrentDate
{
    NSDateFormatter *dataFormat = [[NSDateFormatter alloc] init];
    [dataFormat setDateFormat:@"MM/dd/YYYY"];
    return [dataFormat stringFromDate:[NSDate date]];
}
@end
