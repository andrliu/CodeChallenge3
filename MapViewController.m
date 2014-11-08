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
@property NSMutableString *direction;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.direction = [NSMutableString string];
    [self getDirectionsFrom:self.currentLocation.coordinate.latitude :self.currentLocation.coordinate.longitude To:self.mapItem.latitude :self.mapItem.longitude];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.mapItem.latitude, self.mapItem.longitude);
    self.stationAnnotation = [[MKPointAnnotation alloc]init];
    self.stationAnnotation.title = self.mapItem.stationName;
    self.stationAnnotation.coordinate = center;
    [self.mapView addAnnotation:self.stationAnnotation];

    self.userAnnotation = [[MKPointAnnotation alloc]init];
    self.userAnnotation.title = @"Current Location";
    self.userAnnotation.coordinate = self.currentLocation.coordinate;
    [self.mapView addAnnotation:self.userAnnotation];

    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = 0.05;
    coordinateSpan.longitudeDelta = 0.05;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MKPointAnnotation *annotation = view.annotation;

    if ([annotation isEqual:self.stationAnnotation])
    {
        [self directionAlert:self.direction];
    }
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

- (void)getDirectionsFrom:(CLLocationDegrees)sourceLatitude :(CLLocationDegrees)sourceLongitude To:(CLLocationDegrees)destinationLatitude :(CLLocationDegrees)destinationLongitude
{
    CLLocationCoordinate2D currentCoordinate = CLLocationCoordinate2DMake(sourceLatitude, sourceLongitude);
    MKPlacemark *currentPlacemark = [[MKPlacemark alloc]initWithCoordinate:currentCoordinate addressDictionary:nil];
    MKMapItem *currentMapItem = [[MKMapItem alloc]initWithPlacemark:currentPlacemark];

    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(destinationLatitude, destinationLongitude);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc]initWithCoordinate:destinationCoordinate addressDictionary:nil];
    MKMapItem *destinationMapItem = [[MKMapItem alloc]initWithPlacemark:destinationPlacemark];

    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = currentMapItem;
    request.destination = destinationMapItem;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error)
        {
            [self Error:error];
        }
        else
        {
            NSArray *routes = response.routes;
            MKRoute *route = routes.firstObject;

            int i = 1;
            for (MKRouteStep *step in route.steps)
            {
                [self.direction appendFormat:@"%d: %@\n", i, step.instructions];
                i++;
            }
        }
    }];
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

- (void) directionAlert:(NSString *)message
{

    UIAlertController *direction = [UIAlertController alertControllerWithTitle:@"Direction"
                                                                       message: message
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [direction addAction:okButton];
    [self presentViewController: direction animated:YES completion:nil];
    
}

@end
