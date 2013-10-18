//
//  ProfileViewController.m
//  Graffitounes
//
//  Created by Yahya on 11/06/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "ProfileViewController.h"
#import "AFJSONRequestOperation.h"
#import "PictureProfileCell.h"
#import "DetailImageViewController.h"
#import "SIAlertView.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageCellViewController.h"
#import "Press.h"
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize ProfileName,ProfilePictureView,Result,FirstBloc,secondBloc,MyLikes,MyPictures,arrow,thirdBloc,Location,GalleryList,Scroll;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
/*-(void)handleGesture
{
    NSLog(@"yahya");
}*/
-(void)viewDidAppear:(BOOL)animated
{
    
}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    Result = [[NSArray alloc] init];
    prefs = [NSUserDefaults standardUserDefaults];
    ProfileName.text = [prefs objectForKey:@"name"];
    //ProfileName.font = [UIFont fontWithName:@"GraffCaps" size:15.5];
    Location.text = [prefs objectForKey:@"location"];
    //NSLog(@"%@",[UIFont fontNamesForFamilyName:@"Sprayerz"]);
    //Location.font.familyName  = [UIFont fontNamesForFamilyName:@"Sprayerz.ttf"];
    //Location.font= [UIFont fontWithName:@"Sprayerz" size:14];
    NSArray *domains = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *baseDir= [domains objectAtIndex:0];
	NSString *result = [baseDir stringByAppendingPathComponent:@"profilePicture.png"];
    UIImage *Picture = [UIImage imageWithContentsOfFile:result];
    ProfilePictureView.image = Picture;
    //NSLog(@"%@",[prefs objectForKey:@"author"]);
    NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
    StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"%20"];
    [self getData:StringUrl];
    //[self.view addGestureRecognizer:_pullDownGestureRecognizer];
    //animate in within some method called when loading starts
    
    [self.GalleryList registerClass:[ImageCellViewController class] forCellWithReuseIdentifier:@"Cellule"];
    [self.GalleryList registerNib:[UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cellule"];
    //[self.GalleryList registerNib:[UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]]];
    
    FirstBloc.layer.cornerRadius = 5;
    secondBloc.layer.cornerRadius = 5;
    GalleryList.layer.cornerRadius = 5;
    ProfilePictureView.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    ProfilePictureView.layer.borderWidth = 1;
    ProfileName.textColor = [UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1];
    token = [[NSString alloc] init];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.session.getStatus"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"%@",[[JSON objectForKey:@"result"] objectForKey:@"pwg_token"]);
        token = [[JSON objectForKey:@"result"] objectForKey:@"pwg_token"];
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
-(void)getData:(NSString *)StringUrl
{
    CGRect mainframe = CGRectMake(7, 175, 306, 180);

    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"%@",JSON);
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        [GalleryList reloadData];
        float nbRow;
        float h;
        float margin;
        float t;
        if ([Result count]%2==0) {
            nbRow = [Result count]/2;
        }else
        {
            nbRow = ([Result count]/2)+1;
        }
        h = (nbRow *125)-180;
        margin = nbRow *23;
        t = margin+h;
        GalleryList.frame = mainframe;
        CGRect newFramee = GalleryList.frame;
        newFramee.size.height += t;
        GalleryList.frame = newFramee;
        [Scroll setContentSize:CGSizeMake(320, FirstBloc.frame.size.height + secondBloc.frame.size.height + t + 220)];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"DetailImageProfile"]) {
        NSArray *indexPaths = [GalleryList indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        DetailImageViewController *destViewController = segue.destinationViewController;
        destViewController.idIgm = [Result[index.row] objectForKey:@"id"];
    }
    
}


#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //NSLog(@"%i",[Result count]);
    return [Result count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"yahya");
    static NSString *cellIdentifier = @"Cellule";
    ImageCellViewController *cell = (ImageCellViewController *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell.ImageView setImageWithURL:[NSURL URLWithString:[[[Result[indexPath.row] objectForKey:@"derivatives"] objectForKey:@"thumb"] objectForKey:@"url"]]];
    cell.ParentView.hidden = YES;
    //if (MyLikes.enabled == NO) {
        Press *longPressGesture = [[Press alloc] initWithTarget:self action:@selector(handleGesture:)];
        longPressGesture.minimumPressDuration = 1;
        longPressGesture.CellIndex = indexPath.row;
        [cell addGestureRecognizer:longPressGesture];
    //}
    
    cell.layer.borderColor =[[UIColor colorWithRed:(192/255.0) green:(192/255.0) blue:(192/255.0) alpha:1] CGColor];
    cell.layer.borderWidth = 1;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"DetailImageProfile" sender:self];
}
- (void)handleGesture:(Press *)reconizer {
    NSLog(@"hold");
    if (delBtn) {
        [delBtn removeFromSuperview];
        [cancelBtn removeFromSuperview];
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                         animations:^ {
                             tempView.transform = CGAffineTransformIdentity;
                         }
                         completion:NULL
         ];

    }
    
    delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    delBtn.frame = CGRectMake(85, 85, 50, 50);
    delBtn.tag = reconizer.CellIndex;
    [delBtn setImage:[UIImage imageNamed:@"poubelle.png"] forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(deletePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(90, 0, 40, 40);
    cancelBtn.tag = reconizer.CellIndex;
    [cancelBtn setImage:[UIImage imageNamed:@"btn_fermer.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(stopWobble:) forControlEvents:UIControlEventTouchUpInside];
    
    tempView = [[UIView alloc] init];
    
    
    
    [reconizer.view addSubview:delBtn];
    [reconizer.view addSubview:cancelBtn];
    [UIView animateWithDuration:0.01
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         reconizer.view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(2));
                     }
                     completion:^(BOOL finished){
                         
                         tempView = reconizer.view;
                     
                     }];
}
- (void)stopWobble:(Press *)reconizer {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         tempView.transform = CGAffineTransformIdentity;
                         NSArray *viewsToRemove = [tempView subviews];
                         //NSLog(@"%@",viewsToRemove);
                         for (UIView *v in viewsToRemove) {
                             //[v removeFromSuperview];
                             if ([v isKindOfClass:[UIButton class]]) {
                                 [v removeFromSuperview];
                             }
                         }
                     }
                     completion:NULL
     ];
}
-(void)deletePicture:(id)sender
{
    //NSLog(@"%@",[Result[indexPath.row] objectForKey:@"id"]);
    
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@",[Result[[sender tag]] objectForKey:@"id"]], @"image_id",
                                  [NSString stringWithFormat:@"%@",token], @"pwg_token", nil];
    
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.images.delete" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
        StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                         withString:@"%20"];
        [self getData:StringUrl];
        for (UIView *v in GalleryList.visibleCells) {
            //[v removeFromSuperview];
            if ([v isKindOfClass:[UIButton class]]) {
                [v removeFromSuperview];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}
-(void)move:(id)sender {
    
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        
		firstX = [[sender view] center].x;
		firstY = [[sender view] center].y;
	}
    
	translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
	[[sender view] setCenter:translatedPoint];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
		
    }
}
-(void)pane:(id)sender
{
    /*[sender view].layer.cornerRadius = 50;
    CGRect fr = [sender view].frame;
    fr.size = CGSizeMake(100, 100);
    [sender view].frame = fr;
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[sender view]];
    //[thirdBloc bringSubviewToFront:];
    [thirdBloc addSubview:[sender view]];*/

    //[thirdBloc bri]
    //[self.view.subviews lastObject];
    
    //[sender view].layer.zPosition = 1;
    
    //thirdBloc.layer.zPosition = -1;
    // First, get the view embedding the grandchildview to front.
    //[self.view bringSubviewToFront:[[sender view] superview]];
    // Now, inside that container view, get the "grandchildview" to front.
    //[[[sender view]  superview] bringSubviewToFront:[sender view]];
    //NSLog(@"%@",sender);
    //[[sender view] didMoveToSuperview];
    //[thirdBloc bringSubviewToFront:[sender view]];
    //[ bringSubviewToFront:[self.view superview]];
    //[self.view bringSubviewToFront:[GalleryList bringSubviewToFront:[sender view]]];
    //[[sender view] br]
    /*CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    [[sender view] setCenter:translatedPoint];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        //CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
        NSLog(@"finish");
         
        
        CGFloat finalX = translatedPoint.x + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
		CGFloat finalY = translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            if (finalX < 0) {
                //finalX = 0;
            } else if (finalX > 768) {
                //finalX = 768;
            }
            
            if (finalY < 0) {
                finalY = 0;
            } else if (finalY > 1024) {
                finalY = 1024;
            }
        } else {
            if (finalX < 0) {
                //finalX = 0;
            } else if (finalX > 1024) {
                //finalX = 768;
            }
            
            if (finalY < 0) {
                finalY = 0;
            } else if (finalY > 768) {
                finalY = 1024;
            }
        }
        
        //CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        //NSLog(@"the duration is: %f", animationDuration);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.35];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
    }*/
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
#pragma mark - 
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesBegan:touches withEvent:event];
    [self.view touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.view touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.view touchesCancelled:touches withEvent:event];
}
#pragma mark -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"yahy");
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"hamza");
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GetMyPitures:(id)sender {
    NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
    StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                     withString:@"%20"];
    [self getData:StringUrl];
    [UIView animateWithDuration:0.2
                     animations:^{
                         arrow.frame = CGRectMake(71, 162, 16, 10);
                     }
                     completion:^(BOOL finished){
                         MyPictures.imageView.image = [UIImage imageNamed:@"mesphotos_on.png"];
                         MyLikes.imageView.image = [UIImage imageNamed:@"meslike_off.png"];
                     }];
}
- (IBAction)GetMyLikes:(id)sender {
     NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.images.Liked&user_id=%@",[prefs objectForKey:@"user_id"]];
    NSLog(@"%@",StringUrl);
    [self getData:StringUrl];
    [UIView animateWithDuration:0.2
                     animations:^{
                         arrow.frame = CGRectMake(232, 162, 16, 10);
                     }
                     completion:^(BOOL finished){
                         MyPictures.imageView.image = [UIImage imageNamed:@"mesphotos_off.png"];
                         MyLikes.imageView.image = [UIImage imageNamed:@"meslike_on.png"];
                     }];
}
@end
