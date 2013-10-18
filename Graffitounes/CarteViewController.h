//
//  CarteViewController.h
//  Graffitounes
//
//  Created by Yahya on 10/09/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "SIAlertView.h"
@interface CarteViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationCoordinate2D position;
    CLLocationManager *managerL;
}
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (nonatomic,retain) NSArray *Result;
@end
