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
@property MKMapItem *userMapItem;
@property CLLocationManager *manager;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.mapItem.latitude, self.mapItem.longitude);
    self.stationAnnotation = [[MKPointAnnotation alloc]init];
    self.stationAnnotation.title = self.mapItem.name;
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

- (void)getDirectionsTo:(MKMapItem *)destinationItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, id error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;
        int i = 1;
        NSMutableString *directionsString = [NSMutableString string];
        for (MKRouteStep *step in route.steps)
        {
            [directionsString appendFormat:@"%d: %@\n", i, step.instructions];
            i++;
        }
        self.myTextView.text = directionsString;
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
