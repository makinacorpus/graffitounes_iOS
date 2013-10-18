//
//  CommetaireViewController.h
//  Graffitounes
//
//  Created by Yahya on 31/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
#import "SIAlertView.h"
@interface CommetaireViewController : UIViewController<UITextViewDelegate>
{
    CGFloat animatedDistance;
    NSUserDefaults *prefs;

}
@property (weak, nonatomic) IBOutlet UITextView *commentText;
- (IBAction)share:(id)sender;
- (IBAction)CancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageFull;
@property (nonatomic,retain) UIImage *full;
@property (weak, nonatomic) IBOutlet UIButton *Cancel;
@property (weak, nonatomic) NSString *idimage;

@end
