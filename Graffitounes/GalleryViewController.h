//
//  GalleryViewController.h
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCellViewController.h"
#import <MapKit/MapKit.h>
#import "Constants.h"
#import "Images.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "DetailImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SIAlertView.h"
@interface GalleryViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate>
{
    NSUserDefaults *prefs;
    CLLocationManager *managerL;
    CLLocation *location;
    NSMutableArray *ArrayByLocation;
    NSMutableArray *tempTable;

    id tempObject;

}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingSpinner;
@property (weak, nonatomic) IBOutlet UICollectionView *GalleryList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *Segment;
@property (nonatomic,retain) NSArray *ArrayLatest;
@property (nonatomic,retain) NSArray *Result;
- (IBAction)SwitchSegment:(id)sender;

@end
