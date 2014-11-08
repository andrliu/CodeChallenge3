//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import "ALMapItem.h"
@import CoreLocation;
#define kStationBeanList @"http://www.bayareabikeshare.com/stations/json"

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *stationBeanArray;
@property NSMutableArray *currentArray;
@property NSArray *dataArrray;
@property CLLocationManager *manager;
@property CLLocation *currentLocation;
@property BOOL isSearched;


@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationBeanArray = [NSMutableArray array];
    self.currentArray = [NSMutableArray array];
    self.dataArrray = [NSArray array];

    self.manager = [[CLLocationManager alloc]init];
    [self.manager requestAlwaysAuthorization];
    [self.manager startUpdatingLocation];
    self.manager.delegate = self;

    self.navigationItem.title = @"Locating...";

}

- (void)loadJson:(NSString *)json
{
    NSURL *url = [NSURL URLWithString:json];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             [self Error:connectionError];
         }
         else
         {
             NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSArray *jsonArray = jsonDictionary[@"stationBeanList"];
             self.dataArrray = jsonArray;
             for (NSDictionary *dict in self.dataArrray)
             {
                 ALMapItem *bikeStation = [[ALMapItem alloc] init];

                 bikeStation.stationName= dict[@"stationName"];

                 bikeStation.availableBikes= dict[@"availableBikes"];

                 bikeStation.latitude = [dict[@"latitude"] doubleValue];

                 bikeStation.longitude = [dict[@"longitude"] doubleValue];

                 CLLocation *bikeStationLocation = [[CLLocation alloc]initWithLatitude:bikeStation.latitude longitude:bikeStation.longitude];

                 bikeStation.distance = [bikeStationLocation distanceFromLocation: self.manager.location];

                 [self.stationBeanArray addObject:bikeStation];

                 self.currentArray = self.stationBeanArray;

                 [self.tableView reloadData];

                 self.navigationItem.title = @"Bike station info";
             }
         }
     }];
}

- (IBAction)sortDistanceOnButtonPressed:(UIBarButtonItem *)sender
{
    self.currentArray = [[self.currentArray sortedArrayUsingComparator:^NSComparisonResult(ALMapItem *obj1, ALMapItem *obj2){

                                  if (obj1.distance < obj2.distance)
                                  {
                                      return (NSComparisonResult)NSOrderedAscending;
                                  }

                                  if (obj1.distance > obj2.distance)
                                  {
                                      return (NSComparisonResult)NSOrderedDescending;
                                  }
                                  return (NSComparisonResult)NSOrderedSame;

                              }] mutableCopy];

    [self.tableView reloadData];

    self.navigationItem.title = @"Sotred by distance";

}

- (void)Error:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:action];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self Error:error];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy <1000 && location.horizontalAccuracy < 1000)
        {
            [self reverseGeocode:location];
            [self.manager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode:(CLLocation *)location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, id error)
     {
         CLPlacemark *placemark = placemarks.firstObject;
         self.currentLocation = placemark.location;
         [self loadJson:kStationBeanList];
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mvc = segue.destinationViewController;
    NSInteger rowNumber = [self.tableView indexPathForSelectedRow].row;
    ALMapItem *mapItem = [self.currentArray objectAtIndex:rowNumber];
    mvc.mapItem = mapItem;
    mvc.currentLocation = self.currentLocation;
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = self.searchBar.text;

    if (searchText.length == 0)
    {
        self.currentArray = self.stationBeanArray;
    }
    else
    {
        [self.currentArray removeAllObjects];
        for (NSDictionary *dict in self.dataArrray)
        {
            if ([[dict[@"stationName"] lowercaseString] containsString:[searchText lowercaseString]])
            {

                ALMapItem *bikeStation = [[ALMapItem alloc] init];

                bikeStation.stationName= dict[@"stationName"];

                bikeStation.availableBikes= dict[@"availableBikes"];

                bikeStation.latitude = [dict[@"latitude"] doubleValue];

                bikeStation.longitude = [dict[@"longitude"] doubleValue];

                CLLocation *bikeStationLocation = [[CLLocation alloc]initWithLatitude:bikeStation.latitude longitude:bikeStation.longitude];

                bikeStation.distance = [bikeStationLocation distanceFromLocation: self.manager.location];

                [self.currentArray addObject: bikeStation];
            }
        }
    }
    [self.tableView reloadData];
}



#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.currentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    ALMapItem *mapItem = self.currentArray [indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"Location: %@", mapItem.stationName];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available: %@, Distance: %f", mapItem.availableBikes, mapItem.distance];

    return cell;
}

@end
