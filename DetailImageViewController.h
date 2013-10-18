//
//  DetailImageViewController.h
//  Graffitounes
//
//  Created by Yahya on 30/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFJSONRequestOperation.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CommetaireViewController.h"
#import "FullScreenViewController.h"
#import "AFNetworking.h"
#import "Constants.h"
@interface DetailImageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,MKMapViewDelegate>
{
    NSString *idImg;
    CGFloat animatedDistance;
    NSUserDefaults *prefs;
    int LocalNbComment;
    NSString *Longitude;
    NSString *Latitude;
    int Liked;
    NSString *link;
    NSString *urlPicto;
}
- (IBAction)DoGhost:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *GhostButton;
- (IBAction)FacebookShare:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *FaceookBtn;
@property (weak, nonatomic) IBOutlet UIButton *geoButton;
- (IBAction)Like:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *LikeButton;
@property (weak, nonatomic) IBOutlet UIButton *ButtonShareComment;
- (IBAction)ShareComment:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
//- (IBAction)Popup:(id)sender;
- (IBAction)switchView:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ViewCommentArea;
@property (weak, nonatomic) IBOutlet UIImageView *ImageSwitch;
@property (weak, nonatomic) IBOutlet UITableView *CommentsList;
@property (weak, nonatomic) IBOutlet UILabel *nb_comments;
@property (weak, nonatomic) IBOutlet UITextView *CommentArea;
@property (weak, nonatomic) IBOutlet UILabel *nb_likes;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *date_available;
@property (weak, nonatomic) IBOutlet UIImageView *heart;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *SpinnerLike;
@property (nonatomic,weak) NSString *idIgm;
@property (nonatomic,weak) NSString *SegueID;
@property (nonatomic,weak) NSString *name;
@property (nonatomic,retain) NSArray *arrayComment;
@property (nonatomic,retain) NSString *Token;
- (IBAction)delete:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@end
