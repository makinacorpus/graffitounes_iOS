//
//  CarteViewController.m
//  Graffitounes
//
//  Created by Yahya on 10/09/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "CarteViewController.h"
#import "PointAnnotation.h"
#import "DetailImageViewController.h"
@interface CarteViewController ()

@end

@implementation CarteViewController
@synthesize Result,MapView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations

{
    CLLocation *location = [[CLLocation alloc] init];
    location = [locations lastObject];
    position = location.coordinate;
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
        //((MKPointAnnotation *)annotation).title = adresse;
        //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[Result[((PointAnnotation *)annotation).row] objectForKey:@"derivatives"] objectForKey:@"thumb"] objectForKey:@"url"]]];
        //NSData *data = [NSData dataWithContentsOfURL:url];
        //UIImage *img = [[UIImage alloc] initWithData:data];
        annotationView.image = [UIImage imageNamed:@"marqueur_graffi.png"];
        annotationView.canShowCallout = YES;
        UIImageView *ImageView = [[UIImageView alloc] init];
        [ImageView setFrame:CGRectMake(0, 0, 30, 30)];

        //UIImageView *ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_marker.png"]];
        //NSLog(@"%@",);
        ImageView.contentMode = UIViewContentModeScaleAspectFit;

        [ImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[Result[((PointAnnotation *)annotation).row] objectForKey:@"derivatives"] objectForKey:@"thumb"] objectForKey:@"url"]]]];
        annotationView.leftCalloutAccessoryView = ImageView;

        UIButton *rightCallout = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = rightCallout;
        rightCallout.tag = ((PointAnnotation *)annotation).row;
        [rightCallout addTarget:self action:@selector(ToDetail:) forControlEvents:UIControlEventTouchUpInside];
        //NSLog(@"%i",((PointAnnotation *)annotation).row);
        return annotationView;
    }
}
-(void)ToDetail:(id)sender
{
    NSLog(@"%i",[sender tag]);
    [self performSegueWithIdentifier:@"mapToDetails" sender:sender];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"mapToDetails"]) {
        DetailImageViewController *destViewController = segue.destinationViewController;
        destViewController.idIgm = [Result[[sender tag]] objectForKey:@"id"];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    managerL = [[CLLocationManager alloc] init];
    [managerL setDelegate:self];
    [managerL setDistanceFilter:kCLDistanceFilterNone];
    [managerL setDesiredAccuracy:kCLLocationAccuracyBest];
    [managerL startUpdatingLocation];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        [self addAnnotation];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];
	// Do any additional setup after loading the view.
}
-(void)addAnnotation
{
    for (int i  = 0; i<[Result count]; i++) {
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude =[[Result[i] objectForKey:@"lat"] doubleValue] ;
        //[Lat doubleValue];
        annotationCoord.longitude = [[Result[i] objectForKey:@"lon"] doubleValue];
        
        PointAnnotation *annotationPoint = [[PointAnnotation alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.title = [Result[i] objectForKey:@"name"];
        annotationPoint.row = i;
        //annotationPoint set
        [MapView addAnnotation:annotationPoint];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (position, 5000, 5000);
        [MapView setRegion:region animated:YES];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
