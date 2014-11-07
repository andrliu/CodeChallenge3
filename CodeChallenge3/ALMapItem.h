//
//  ALMapItem.h
//  CodeChallenge3
//
//  Created by Andrew Liu on 11/7/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ALMapItem : MKMapItem
@property NSString *stationName;
@property NSString *availableBikes;
@property double latitude;
@property double longitude;
@property double distance;

@end
