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

@interface StationsListViewController () <UITabBarDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *stationBeanArray;
@property CLLocationManager *manager;
@property CLLocation *currentLocation;


@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.stationBeanArray = [NSMutableArray array];

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
             for (NSDictionary *dict in jsonArray)
             {
                 ALMapItem *bikeStation = [[ALMapItem alloc] init];

                 bikeStation.stationName= dict[@"stationName"];

                 bikeStation.availableBikes= dict[@"availableBikes"];

                 bikeStation.latitude = [dict[@"latitude"] doubleValue];

                 bikeStation.longitude = [dict[@"longitude"] doubleValue];

                 CLLocation *bikeStationLocation = [[CLLocation alloc]initWithLatitude:bikeStation.latitude longitude:bikeStation.longitude];

                 bikeStation.distance = [bikeStationLocation distanceFromLocation: self.manager.location];

                 [self.stationBeanArray addObject:bikeStation];

                 [self.tableView reloadData];

                 self.navigationItem.title = @"Bike station info";
             }
         }
     }];
}

- (IBAction)sortDistanceOnButtonPressed:(UIBarButtonItem *)sender
{
    self.stationBeanArray = [[self.stationBeanArray sortedArrayUsingComparator:^NSComparisonResult(ALMapItem *obj1, ALMapItem *obj2){

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
    ALMapItem *mapItem = [self.stationBeanArray objectAtIndex:rowNumber];
    mvc.mapItem = mapItem;
    mvc.currentLocation = self.currentLocation;
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stationBeanArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    ALMapItem *mapItem = self.stationBeanArray [indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"Location: %@", mapItem.stationName];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available: %@, Distance: %f", mapItem.availableBikes, mapItem.distance];

    return cell;
}

@end
