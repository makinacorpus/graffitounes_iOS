//
//  PictureProfileCell.m
//  Graffitounes
//
//  Created by Yahya on 14/06/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "PictureProfileCell.h"

@implementation PictureProfileCell
@synthesize ImageViewPicture;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
