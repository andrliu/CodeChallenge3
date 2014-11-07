//
//  MapViewController.h
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ALMapItem.h"

@interface MapViewController : UIViewController
@property ALMapItem *mapItem;
@property CLLocation *currentLocation;

@end
