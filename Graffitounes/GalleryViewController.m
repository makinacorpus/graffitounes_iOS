//
//  GalleryViewController.m
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "GalleryViewController.h"
@interface GalleryViewController ()

@end

@implementation GalleryViewController
@synthesize Segment,GalleryList,ArrayLatest,Result,LoadingSpinner;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
            
        if ([segue.identifier isEqualToString:@"DetailImage"]) {
            NSArray *indexPaths = [GalleryList indexPathsForSelectedItems];
            NSIndexPath *index = [indexPaths objectAtIndex:0];
            DetailImageViewController *destViewController = segue.destinationViewController;
            destViewController.idIgm = [Result[index.row] objectForKey:@"id"];
            destViewController.SegueID = @"";

        }
}
-(void)GetUserID
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.GetuserID&username=%@",BaseURL,[prefs objectForKey:@"username"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [prefs setObject:[JSON objectForKey:@"result"] forKey:@"user_id"];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];
}

-(void)getData:(NSString *)StringUrl
{
    [LoadingSpinner startAnimating];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        [GalleryList reloadData];
        [LoadingSpinner stopAnimating];
        LoadingSpinner.hidden = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    location = [[CLLocation alloc] init];
    location = [locations lastObject];
    [managerL stopUpdatingLocation];
}
-(void)viewDidAppear:(BOOL)animated
{
    //Refersh data when view is loaded
    NSInteger selectedSegment = Segment.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [self getData:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 1:
            [self getDataByLike:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 2:
            [self getDataByProximity:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        default:
            break;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Graffitounes_navbar.png"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *header = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    header.image = [UIImage imageNamed:@"Graffitounes_navbar.png"];
    [self.navigationController.navigationBar.topItem setTitleView:header];
    //Check version
    float currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    //Change Design of segement
    if (currentVersion >= 7.0) {
        [Segment setTintColor:[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1]];
    }
    
    //Activate Location service
    managerL = [[CLLocationManager alloc] init];
    [managerL setDelegate:self];
    [managerL setDistanceFilter:kCLDistanceFilterNone];
    [managerL setDesiredAccuracy:kCLLocationAccuracyBest];
    [managerL startUpdatingLocation];
    
    //Get user ID
    prefs = [NSUserDefaults standardUserDefaults];
    [self GetUserID];
    
    //init Array for data
    Result = [[NSArray alloc] init];
    [self getData:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
    //Set Config of gallery list
    [self.GalleryList registerClass:[ImageCellViewController class] forCellWithReuseIdentifier:@"Cellule"];
    [self.GalleryList registerNib:[UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cellule"];
    
    
    //Pull to refresh
    UIRefreshControl *refreshControl = UIRefreshControl.alloc.init;
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.GalleryList addSubview:refreshControl];
    	// Do any additional setup after loading the view.
}
-(double)GetDistance:(double)lng lat:(double)lat
{
    CLLocation *loc1 = [[CLLocation alloc]  initWithLatitude:lat longitude:lng];
    CLLocationDistance distance = [loc1 distanceFromLocation:location];
    return distance/1000;
}

-(void)getDataByProximity:(NSString *)StringUrl
{
    ArrayByLocation = [[NSMutableArray alloc] init];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        for (int i=0; i<[Result count]; i++) {
            if (i==0) {
                [ArrayByLocation addObject:Result[i]];
            }else
            {
                [ArrayByLocation addObject:Result[i]];
                for (int j = i; j> 0; j--) {
                    if ([self GetDistance:[[ArrayByLocation [j] objectForKey:@"lon"] doubleValue] lat:[[ArrayByLocation [j] objectForKey:@"lat"] doubleValue]]>[self GetDistance:[[ArrayByLocation [j-1] objectForKey:@"lon"] doubleValue] lat:[[ArrayByLocation [j-1] objectForKey:@"lat"] doubleValue]]) {
                        
                        id obj1 = ArrayByLocation[j];
                        id obj2 = ArrayByLocation[j-1];
                        [ArrayByLocation removeObjectAtIndex:j];
                        [ArrayByLocation removeObjectAtIndex:j-1];
                        [ArrayByLocation insertObject:obj1 atIndex:j-1];
                        [ArrayByLocation insertObject:obj2 atIndex:j];
                    }else
                    {
                        //NSLog(@"Ok");
                    }
                }
            }
        }
        Result = [[ArrayByLocation reverseObjectEnumerator] allObjects];
        [GalleryList reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                            }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    [operation start];
}
-(void)getDataByLike:(NSString *)StringUrl
{
    ArrayByLocation = [[NSMutableArray alloc] init];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        for (int i=0; i<[Result count]; i++) {
            if (i==0) {
                [ArrayByLocation addObject:Result[i]];
            }else
            {
                [ArrayByLocation addObject:Result[i]];
                for (int j = i; j> 0; j--) {
                    if ([[[[ArrayByLocation[j] objectForKey:@"categories"]objectAtIndex:0] objectForKey:@"nbLike"] intValue]>[[[[ArrayByLocation[j-1] objectForKey:@"categories"]objectAtIndex:0]objectForKey:@"nbLike"] intValue]) {
                        
                        id obj1 = ArrayByLocation[j];
                        id obj2 = ArrayByLocation[j-1];
                        [ArrayByLocation removeObjectAtIndex:j];
                        [ArrayByLocation removeObjectAtIndex:j-1];
                        [ArrayByLocation insertObject:obj1 atIndex:j-1];
                        [ArrayByLocation insertObject:obj2 atIndex:j];
                    }else
                    {
                        //NSLog(@"Ok");
                    }
                }
            }
        }
        Result = ArrayByLocation;
        [GalleryList reloadData];
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
}


- (void)refreshView:(UIRefreshControl *)sender {
    //check active segement when refresh
    NSInteger selectedSegment = Segment.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [self getData:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 1:
            [self getDataByLike:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 2:
            [self getDataByProximity:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            NSLog(@"Seg3");
            break;
        default:
            break;
    }
    [sender endRefreshing];
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [Result count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cellule";
    ImageCellViewController *cell = (ImageCellViewController *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //Set Picture cell
    [cell.ImageView setImageWithURL:[NSURL URLWithString:[[[Result[indexPath.row] objectForKey:@"derivatives"] objectForKey:@"square"] objectForKey:@"url"]]];
    //Set number of likes
    cell.LikeCount.text = [[[Result[indexPath.row] objectForKey:@"categories"] objectAtIndex:0] objectForKey:@"nbLike"];
    //Set distance
    double dist = [self GetDistance:[[Result[indexPath.row] objectForKey:@"lon"] doubleValue] lat:[[Result[indexPath.row] objectForKey:@"lat"] doubleValue]];
    
    //check if ghost
    if ([[Result[indexPath.row] objectForKey:@"ghost"] intValue] != 1) {
        cell.ghost.hidden = YES;
    }else
    {
        cell.ghost.hidden = NO;
    }
    
    //Set distance apearence
    if (dist<100) {
        cell.Distance.text = [NSString stringWithFormat:@"%ikm",(int)dist];
    }
    if (dist>100) {
        cell.Distance.text = [NSString stringWithFormat:@"%i..km",(int)(dist/100)];
    }
    if (dist>1000) {
        cell.Distance.text = [NSString stringWithFormat:@"%i..km",(int)(dist/1000)];
    }
    //Change row opacity
    cell.ParentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"DetailImage" sender:self];
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return CGSizeMake(135, 135);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SwitchSegment:(id)sender {
    //switch Segement
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [self getData:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 1:
            [self getDataByLike:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            break;
        case 2:
            [self getDataByProximity:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.categories.getImages",BaseURL]];
            NSLog(@"Seg3");
            break;
        default:
            break;
    }
}
@end
