//
//  CommentCell.h
//  Graffitounes
//
//  Created by Yahya on 31/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateComment;
@property (weak, nonatomic) IBOutlet UILabel *personComment;
@property (weak, nonatomic) IBOutlet UIImageView *personImageComment;
@property (weak, nonatomic) IBOutlet UITextView *commentText;

@end
