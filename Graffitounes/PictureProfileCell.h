//
//  PictureProfileCell.h
//  Graffitounes
//
//  Created by Yahya on 14/06/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPicture;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Date;

@end
