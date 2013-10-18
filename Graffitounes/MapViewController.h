//
//  MapViewController.h
//  Graffitounes
//
//  Created by Yahya on 27/08/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface MapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
{
    CLLocationCoordinate2D destination;
    CLLocationCoordinate2D position;
    CLLocationManager *managerL;
    CLGeocoder *geocoder;
    NSString *adresse;
}
@property(nonatomic,retain) NSString *lng;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,retain) NSString *lat;
- (IBAction)close:(id)sender;
- (IBAction)GetDirection:(id)sender;
@end
