//
//  PhotoViewController.h
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TITokenField.h"
#import "Base64.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Reachability.h"
#import "SIAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "Names.h"
@interface PhotoViewController : UIViewController<CLLocationManagerDelegate,UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,TITokenFieldDelegate>
{
    CGFloat animatedDistance;
    NSUserDefaults *prefs;
    MBProgressHUD *hud;
    NSData *coverData;
    UIImage *cover;
    TITokenFieldView * _tokenFieldView;
	UITextView * _messageView;
    NSMutableArray *ListOfTagID;
	NSMutableArray *ListOfTag;
    NSMutableArray *ListOfNewTag;
    NSMutableArray *ListOfNewTagId;
    NSMutableArray *ListOfExistingTagId;
	CGFloat _keyboardHeight;
    NSMutableString *JsonToSend;
    NSMutableArray *ResultTempID;
    NSString *PicSource;
    
}

@property (weak, nonatomic) IBOutlet UIView *ViewForTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *Taglabel;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrlPage;
@property (nonatomic,retain) NSArray *Result;
@property (nonatomic,retain) NSMutableArray *ResultTemp;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerAdress;

- (IBAction)Share:(id)sender;
- (void)Getphoto;
@property (weak, nonatomic) IBOutlet UIImageView *TokenImage;
@property (weak, nonatomic) IBOutlet UITextField *dateField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextView *titleField;
@property (weak, nonatomic) IBOutlet UITextView *commentField;
@property (nonatomic,retain) CLLocationManager *managerLocation;
@property (nonatomic,retain) CLGeocoder *geocoder;

@end
