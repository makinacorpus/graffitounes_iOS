//
//  AppDelegate.h
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
@property (strong, nonatomic) UIWindow *window;
extern NSString *const FBSessionStateChangedNotification;
@end
