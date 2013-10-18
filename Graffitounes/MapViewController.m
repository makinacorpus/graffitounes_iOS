//
//  MapViewController.m
//  Graffitounes
//
//  Created by Yahya on 27/08/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize lng,lat,mapView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    managerL = [[CLLocationManager alloc] init];
    [managerL setDelegate:self];
    [managerL setDistanceFilter:kCLDistanceFilterNone];
    [managerL setDesiredAccuracy:kCLLocationAccuracyBest];
    [managerL startUpdatingLocation];

    mapView.delegate = self;
    destination = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    // Do any additional setup after loading the view.
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations

{
    CLLocation *location = [[CLLocation alloc] init];
    location = [locations lastObject];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];
    position = location.coordinate;
    [managerL stopUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       
                       // Make sure the geocoder did not produce an error
                       // before continuing
                       if(!error){
                           
                           // Iterate through all of the placemarks returned
                           // and output them to the console
                           for(CLPlacemark *placemark in placemarks){
                               
                               adresse = [[NSString alloc] initWithFormat:@"%@, %@",[placemark locality],[placemark name]];
                               NSLog(@"%@",adresse);
                               [self addMarker:lng latitude:lat];
                               [self zoomToFitMapAnnotations:mapView];
                               //[self CenterMap];
                           }
                       }
                       else{
                           // Our geocoder had an error, output a message
                           // to the console
                           NSLog(@"There was a reverse geocoding error\n%@",
                                 [error localizedDescription]);
                       }
                   }
     ];
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapVieww {
    if ([mapView.annotations count] == 0) return;
    
    /*CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;*/
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        position.longitude = fmin(position.longitude, annotation.coordinate.longitude);
        position.latitude = fmax(position.latitude, annotation.coordinate.latitude);
        destination.longitude = fmax(destination.longitude, annotation.coordinate.longitude);
        destination.latitude = fmin(destination.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = position.latitude - (position.latitude - destination.latitude) * 0.5;
    region.center.longitude = position.longitude + (destination.longitude - position.longitude) * 0.5;
    region.span.latitudeDelta = fabs(position.latitude - destination.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(destination.longitude - position.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addMarker:(NSString *)Lon latitude:(NSString *)Lat;
{
    CLLocationCoordinate2D annotationCoord;
    
    annotationCoord.latitude = [Lat doubleValue];
    annotationCoord.longitude = [Lon doubleValue];
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    [mapView addAnnotation:annotationPoint];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (annotationCoord, 50, 50);
    [mapView setRegion:region animated:YES];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapsView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        //Don't trample the user location annotation (pulsing blue dot).
        return nil;
    }else
    {
    static NSString *viewIdentifier = @"annotationView";
    MKAnnotationView *annotationView = (MKAnnotationView *) [mapsView dequeueReusableAnnotationViewWithIdentifier:viewIdentifier];
    if (annotationView == nil) {
    	annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewIdentifier];
    }
    
    annotationView.image = [UIImage imageNamed:@"marqueur_graffi.png"];
    annotationView.canShowCallout = YES;
    ((MKPointAnnotation *)annotation).title = adresse;
    return annotationView;
    }
}


- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)GetDirection:(id)sender {
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([lat doubleValue],[lng doubleValue]) addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}
@end
