//
//  ProfileViewController.h
//  Graffitounes
//
//  Created by Yahya on 11/06/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
    NSString *token;
    float firstX;
    float firstY;
    UIView *tempView;
    UIButton *delBtn;
    UIButton *cancelBtn;
    NSUserDefaults *prefs;
}
//@property (nonatomic, strong) UIPanGestureRecognizer *pullDownGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIScrollView *Scroll;
@property (weak, nonatomic) IBOutlet UICollectionView *GalleryList;
@property (weak, nonatomic) IBOutlet UIView *thirdBloc;
@property (weak, nonatomic) IBOutlet UILabel *Location;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
- (IBAction)GetMyLikes:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *MyLikes;
- (IBAction)GetMyPitures:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *MyPictures;
@property (weak, nonatomic) IBOutlet UIView *secondBloc;
@property (weak, nonatomic) IBOutlet UIView *FirstBloc;
@property (weak, nonatomic) IBOutlet UIImageView *ProfilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *ProfileName;
@property (nonatomic,retain) NSArray *Result;
-(void)getData:(NSString *)StringUrl;
@end
