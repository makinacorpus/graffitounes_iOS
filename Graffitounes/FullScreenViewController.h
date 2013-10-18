//
//  FullScreenViewController.h
//  Graffitounes
//
//  Created by Yahya on 09/09/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenViewController : UIViewController
@property (nonatomic,retain) UIImage *full;
@property (weak, nonatomic) IBOutlet UIImageView *FullImage;
- (IBAction)dismiss:(id)sender;
@end
