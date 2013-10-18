//
//  CommetaireViewController.m
//  Graffitounes
//
//  Created by Yahya on 31/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "CommetaireViewController.h"
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 180;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
@interface CommetaireViewController ()

@end

@implementation CommetaireViewController
@synthesize imageFull,full,commentText,idimage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }else{
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    imageFull.image = full;
    commentText.delegate = self;
    NSLog(@"%@",idimage);
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSLog(@"%@",[prefs objectForKey:@"username"]);
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [prefs objectForKey:@"username"], @"username",
                                  @"", @"password",
                                  nil];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.session.login" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender {
    
    if ([commentText.text isEqualToString:@""]) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Veuillez Ajouter un commentaire" andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }else
    {
        NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        httpClient.allowsInvalidSSLCertificate = YES;
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  idimage,@"image_id",
                                  [prefs objectForKey:@"author"],@"author",
                                  commentText.text,@"content",
                                  @"",@"key",
                                  nil];
        [httpClient postPath:@"/ws.php?format=json&method=pwg.images.addComment" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Request Successful, response '%@'", responseStr);
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
            
        }];
    
    }
}

- (IBAction)CancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
