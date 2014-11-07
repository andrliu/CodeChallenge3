//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
@import CoreLocation;

@interface MapViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property MKPointAnnotation *stationAnnotation;
@property MKPointAnnotation *userAnnotation;
@property CLLocationManager *manager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    self.stationAnnotation = [[MKPointAnnotation alloc]init];
    self.stationAnnotation.title = self.stationName;
    self.stationAnnotation.coordinate = center;
    [self.mapView addAnnotation:self.stationAnnotation];

    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.05;
    coordinateSpan.longitudeDelta = 0.05;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];

    self.manager = [[CLLocationManager alloc]init];
    [self.manager requestAlwaysAuthorization];
    [self.manager startUpdatingLocation];
    self.manager.delegate = self;
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

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
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
         self.userAnnotation = [[MKPointAnnotation alloc]init];
         self.userAnnotation.title = @"Current Location";
         self.userAnnotation.coordinate = placemark.location.coordinate;

         [self.mapView addAnnotation:self.userAnnotation];
//         [self findJailNear: placemark.location];
     }];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation
                                                              reuseIdentifier:nil];
    pin.canShowCallout = YES;

    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    if ([annotation isEqual:self.stationAnnotation])
    {
        pin.image = [UIImage imageNamed:@"bikeImage"];
    }

    return pin;
    
}

@end
