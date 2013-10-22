//
//  CustomMapViewController.m
//  Graffitounes
//
//  Created by Yahya on 22/10/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "CustomMapViewController.h"

@interface CustomMapViewController ()

@end

@implementation CustomMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
