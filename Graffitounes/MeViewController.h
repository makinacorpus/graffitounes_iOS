//
//  MeViewController.h
//  Graffitounes
//
//  Created by Yahya on 17/09/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailImageViewController.h"
@interface MeViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
{
    NSUserDefaults *prefs;
    UICollectionView *MypicCollection;
    int activePager;
}
@property (weak, nonatomic) IBOutlet UIImageView *ProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Location;
@property (weak, nonatomic) IBOutlet UIButton *Mypic;
@property (weak, nonatomic) IBOutlet UIButton *Myfav;
@property (weak, nonatomic) IBOutlet UIScrollView *Scroller;
@property (weak, nonatomic) IBOutlet UIImageView *Arrow;
@property (weak, nonatomic) IBOutlet UIView *FirstBloc;
@property (weak, nonatomic) IBOutlet UIView *SecondBloc;
//@property (weak, nonatomic) UICollectionView *MypicCollection;
@property (weak, nonatomic) IBOutlet UIScrollView *Pager;
@property (weak, nonatomic) IBOutlet UICollectionView *MyPicCollection;
@property (weak, nonatomic) IBOutlet UICollectionView *MyFavCollection;

@property (nonatomic,retain) NSArray *Result;
@property (nonatomic,retain) NSArray *ResultFav;

- (IBAction)toMyPic:(id)sender;
- (IBAction)toMyFav:(id)sender;

@end
