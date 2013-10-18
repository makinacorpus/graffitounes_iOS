//
//  ImageCellViewController.h
//  Graffitounes
//
//  Created by Yahya on 17/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCellViewController : UICollectionViewCell<UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Label;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UILabel *LikeCount;
@property (weak, nonatomic) IBOutlet UILabel *Distance;
@property (weak, nonatomic) NSString *urlMedia;
@property (weak, nonatomic) IBOutlet UIView *ParentView;
@property (nonatomic,retain) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *ghost;
@end
