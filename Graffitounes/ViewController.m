//
//  ViewController.m
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "SIAlertView.h"
#import "AppDelegate.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"Server"]);

    //Check iOS Version
    float currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    //Switch iOS design
    if (currentVersion >= 7.0) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1]];
    }

    
    //Change default font of navigation bar
    /*[[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      NSForegroundColorAttributeName,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"kshandwrt" size:15.7],
      UITextAttributeFont,
      nil]];*/
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)FacebookConnect:(id)sender {
    //Check internet connection
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Pas de connexion" andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    } else {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        // The person using the app has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        UIFont* myboldFont = [UIFont boldSystemFontOfSize:14];
        hud.labelText = @"Synchronisation";
        hud.labelFont = myboldFont;
        [hud show:YES];
    }        
}
    

@end
