//
//  PhotoViewController.m
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "PhotoViewController.h"


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 180;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT2 = 220;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize dateField,titleField,commentField,locationField,TokenImage,managerLocation,geocoder,ScrlPage,Taglabel,Result,ResultTemp,spinnerAdress,ViewForTagLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [ScrlPage setContentOffset:CGPointMake(0, 0) animated:YES];
    ResultTempID = [[NSMutableArray alloc] init];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"d/M/Y"];
    NSString *dateString = [dateFormat stringFromDate:date];
    [dateField setText:dateString];
    //Set location Manager
    managerLocation = [[CLLocationManager alloc] init];
    [managerLocation setDelegate:self];
    [managerLocation setDistanceFilter:kCLDistanceFilterNone];
    [managerLocation setDesiredAccuracy:kCLLocationAccuracyBest];
    [managerLocation startUpdatingLocation];
    
    NSLog(@"%f",managerLocation.location.coordinate.latitude);
    [spinnerAdress startAnimating];
    CLLocation *location = [[CLLocation alloc] init];
    location = managerLocation.location;
    [managerLocation stopUpdatingLocation];
    Longitude = location.coordinate.longitude;
    Latitude = location.coordinate.latitude;
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       
                       // Make sure the geocoder did not produce an error
                       // before continuing
                       if(!error){
                           
                           // Iterate through all of the placemarks returned
                           // and output them to the console
                           for(CLPlacemark *placemark in placemarks){
                               [locationField setText:[placemark name]];
                               [spinnerAdress stopAnimating];
                               spinnerAdress.hidden = YES;
                           }
                       }
                       else{
                           // Our geocoder had an error, output a message
                           // to the console
                           NSLog(@"There was a reverse geocoding error\n%@",
                                 [error localizedDescription]);
                       }
                   }
     ];
    //search Tag
    /*[AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *urll = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.tags.getList"];
    NSURLRequest *request = [NSURLRequest requestWithURL:urll];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *arr = [[JSON objectForKey:@"result"] objectForKey:@"tags"];
        for (int i = 0; i < [[[JSON objectForKey:@"result"] objectForKey:@"tags"] count]; i++) {
            [ResultTemp addObject:[arr[i] objectForKey:@"name"]];
            [ResultTempID addObject:[arr[i] objectForKey:@"id"]];
        }
        //NSLog(@"%@",ResultTempID);
        Result = ResultTemp;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  //NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];*/

}
- (void)showContactsPicker:(id)sender {
	[_tokenFieldView removeFromSuperview];
    NSMutableString *Tags = [[NSMutableString alloc] init];
    for (int i =0; i < [ListOfNewTag count]; i++) {
        [Tags appendFormat:@" %@",[ListOfNewTag objectAtIndex:i]];
    }
    for (int i =0; i < [ListOfTag count]; i++) {
        [Tags appendFormat:@" %@",[ListOfTag objectAtIndex:i]];
    }
    Taglabel.text = Tags;
	// Show some kind of contacts picker in here.
	// For now, here's how to add and customize tokens.
	
	/*NSArray * names = [Names listOfNames];
	
	TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
	[token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
	// If the size of the token might change, it's a good idea to layout again.
	[_tokenFieldView.tokenField layoutTokensAnimated:YES];
	
	NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
	[token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];*/
}
- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token
{
    if (![ResultTemp containsObject:token.title]) {
        [ListOfNewTag addObject:token.title];
    }else{
        [ListOfTag addObject:token.title];
        [ListOfTagID addObject:[ResultTempID objectAtIndex:[Result indexOfObject:token.title]]];
    }
    
    
    
    
}
- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	_keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
	[_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
	[_messageView setFrame:_tokenFieldView.contentView.bounds];
}

- (BOOL)tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
	
	if ([token.title isEqualToString:@"Tom Irving"]){
		return NO;
	}
	
	return YES;
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
	// There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
	[tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
	[self textViewDidChange:_messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	//NSLog(@"%@",textView.text);
	if (!(textView == commentField)) {
        CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height;
        CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
        
        CGRect newTextFrame = textView.frame;
        newTextFrame.size = textView.contentSize;
        newTextFrame.size.height = newHeight;
        
        CGRect newFrame = _tokenFieldView.contentView.frame;
        newFrame.size.height = newHeight;
        
        if (newHeight < oldHeight){
            newTextFrame.size.height = oldHeight;
            newFrame.size.height = oldHeight;
        }
        
        [_tokenFieldView.contentView setFrame:newFrame];
        [textView setFrame:newTextFrame];
        [_tokenFieldView updateContentSize];
    }
    
}
- (void)ShowTokenView
{
    //Token
    _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[_tokenFieldView setSourceArray:Result];
    [self.view addSubview:_tokenFieldView];
    
    [_tokenFieldView.tokenField setDelegate:self];
	//[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:TITokenFieldControlEventFrameDidChange];
	[_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]];
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
	[_tokenFieldView.tokenField setRightView:addButton];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
	[_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
	//[_tokenFieldView.tokenField addTokenWithTitle:@"yahya"];

	//_messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
    
	[_messageView setScrollEnabled:NO];
	[_messageView setAutoresizingMask:UIViewAutoresizingNone];
	[_messageView setDelegate:self];
	[_messageView setFont:[UIFont systemFontOfSize:15]];
	[_messageView setText:@"Certaines tags existent déjà, vous pouvez ajouter d'autres en tapant sur (+)"];
	//[_tokenFieldView.contentView addSubview:_messageView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view on the field.
	// They both do the same thing.
	[_tokenFieldView becomeFirstResponder];
    
    //Token
}



- (void)viewDidLoad
{
    dateField.hidden = YES;
    //locationField.hidden = YES;
    //spinnerAdress.hidden = YES;

    //Get data for default picture
    cover = [UIImage imageNamed:@"ajout_photo.png"];
    coverData = UIImagePNGRepresentation(cover);

    
    //Set delegates
    commentField.delegate = self;
    titleField.delegate = self;
    
    
    //Declare Arrays
    ResultTemp = [[NSMutableArray alloc] init];
    ListOfTag = [[NSMutableArray alloc] init];
    ListOfNewTag = [[NSMutableArray alloc] init];
    JsonToSend = [[NSMutableString alloc] init];
    ListOfNewTagId = [[NSMutableArray alloc] init];
    ListOfExistingTagId = [[NSMutableArray alloc] init];
    ListOfTagID = [[NSMutableArray alloc] init];;
    //Setting UX
    TokenImage.userInteractionEnabled = YES;
    //Taglabel.frame.origin.x = 10;    
    ViewForTagLabel.layer.borderWidth = 1.0f;
    titleField.layer.borderWidth = 1.0f;
    locationField.layer.borderWidth = 1.0f;
    dateField.layer.borderWidth = 1.0f;
    //dateField.textColor = [UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:0.5];
    //locationField.textColor = [UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:0.5];
    //titleField.textColor = [UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:0.5];
    ViewForTagLabel.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    titleField.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    locationField.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    dateField.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    commentField.layer.borderWidth = 1.0f;
    commentField.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    [ScrlPage setContentSize:CGSizeMake(320, 530)];
    [ScrlPage setBounces:NO];
    [dateField setEnabled:NO];
    [locationField setEnabled:NO];
    //locationField.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //Login for add comments;
    prefs = [NSUserDefaults standardUserDefaults];
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    //NSLog(@"%@",[prefs objectForKey:@"username"]);
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [prefs objectForKey:@"username"], @"username",
                                  @" ", @"password",
                                  nil];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.session.login" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
    
    
    
    //Tap for get picture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Getphoto)];
    [TokenImage addGestureRecognizer:tapRecognizer];
    
    
    //Tap for add tag
    Taglabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(ShowTokenView)];
    
    [Taglabel addGestureRecognizer:tap];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _tokenFieldView.tokenField) {
        //NSLog(@"%@",_tokenFieldView.tokenField.text);
        
    }else
    {
        [textField resignFirstResponder];
    }
    return NO;
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations

{
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        //NSLog(@"test");
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
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
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION +0.15];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //[ScrlPage setContentSize:CGSizeMake(320,690)];
    
    //CGRect frame = self.view.frame;
    //frame.origin.y = -100;
    //[self.view setFrame:frame];
    //self.view.bounds.origin.y += 200;
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
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT2 * heightFraction);
        
    }else{
        
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    NSLog(@"%f",animatedDistance);
    viewFrame.origin.y -= animatedDistance - 52;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION+0.15];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION- 0.15];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    [ScrlPage setContentSize:CGSizeMake(320,530)];
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance - 52;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION - 0.15];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)SendNewTags
{
    [JsonToSend appendString:@"{\"tags\":["];
    for (int j = 0; j < [ListOfNewTag count]; j++) {
        if (j == [ListOfNewTag count]-1 ) {
            [JsonToSend appendFormat:@"\"%@\"",ListOfNewTag[j]];
        }else
        {
            [JsonToSend appendFormat:@"\"%@\",",ListOfNewTag[j]];
        }
    }
    [JsonToSend appendString:@"]}"];
    //NSLog(@"%@",JsonToSend);
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    //NSLog(@"%@",[prefs objectForKey:@"username"]);
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@",JsonToSend], @"json",nil];
    [httpClient postPath:@"/addNewTags.php" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              options:kNilOptions
                              error:&error];
        NSLog(@"%i",[[json objectForKey:@"result"] count]);
        for (int k = 0 ; k < [[json objectForKey:@"result"] count]; k++) {
            [ListOfNewTagId addObject:[[[[json objectForKey:@"result"] objectAtIndex:k] objectForKey:@"result"] objectForKey:@"id"]];
        }
        
        //NSLog(@"%@",ListOfNewTagId);
        [self SendChunks];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];

}
-(void)SendChunks
{
     NSData *imageData = UIImageJPEGRepresentation(TokenImage.image, 0.1f);
     NSString *DataString = [imageData base64EncodedString];
     int nbportion = DataString.length/65000;
     double reste = fmod(DataString.length, 65000.0);
     NSString *random = [[NSString alloc] initWithString:[self shuffledAlphabet]];
     //NSLog(@"%@",random);
     double j = 0;
     __block int k = 0;
     int i;
     for (i = 0; i<nbportion; i++) {
     NSString *Portion = [[NSString alloc] initWithString:[DataString substringWithRange:NSMakeRange(j,65000)]] ;
     //NSLog(@"Portion: %@", Portion);
     NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
     
     NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithString:Portion], @"data",
     [NSString stringWithString:random], @"original_sum",
     @"file", @"type",
     [NSNumber numberWithInt:i], @"position",
     nil];
     
     [httpClient postPath:@"/ws.php?format=json&method=pwg.images.addChunk" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
     //NSLog(@"Request Successful, response '%@' Finish", responseStr);
     k = k +1;
     //NSLog(@"%i",k);
     if (k == nbportion + 1) {
     [self ValidateShare:random];
     }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];
     j = j + 65000;
     }
     NSString *PortionLast = [[NSString alloc] initWithString:[DataString substringWithRange:NSMakeRange(j,reste)]] ;
     NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithString:PortionLast], @"data",
     [NSString stringWithString:random], @"original_sum",
     @"file", @"type",
     [NSNumber numberWithInt:i+1], @"position",
     nil];
     NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
     [httpClient postPath:@"/ws.php?format=json&method=pwg.images.addChunk" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
     k = k+1;
     //NSLog(@"%i",k);
     if (k == nbportion + 1) {
     [self ValidateShare:random];
     }
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
     }];

}
- (IBAction)Share:(id)sender {
    [self.view endEditing:YES];
    if ([titleField.text isEqualToString:@""]) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Veuillez ajouter un titre" andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  //NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
        
    }else
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        UIFont* myboldFont = [UIFont boldSystemFontOfSize:14];
        hud.labelText = @"Chargement";
        hud.labelFont = myboldFont;
        [hud show:YES];
        //[self SendNewTags];
        [self SendChunks];
    }
    
}
-(void)ValidateShare:(NSString *)Sum
{
    NSData *imageData = UIImagePNGRepresentation(TokenImage.image);
    if ([imageData isEqualToData:coverData]) {
        [hud hide:YES];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Veuillez ajouter une photo" andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  //NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
        
    }else{
        NSMutableString *tag_ids = [[NSMutableString alloc] init];
        for (int n =0; n < [ListOfTagID count]; n ++) {
            [tag_ids appendFormat:@"%@,",ListOfTagID[n]];
        }
        NSLog(@"Liste of all tags:%@",tag_ids);
        for (int l=0; l<[ListOfNewTagId count]; l++) {
            if (l == [ListOfNewTagId count]-1) {
                [tag_ids appendFormat:@"%@",ListOfNewTagId[l]];
            }else
            {
                [tag_ids appendFormat:@"%@,",ListOfNewTagId[l]];
            }
        }
        
        //NSLog(@"Liste of all tags:%@",tag_ids);
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSString stringWithString:Sum], @"file_sum",
                                      [NSString stringWithString:Sum], @"original_sum",
                                      @"1", @"categories",
                                      [prefs objectForKey:@"author"],@"author",
                                      [NSNumber numberWithDouble:Latitude],@"lat",
                                      [NSNumber numberWithDouble:Longitude],@"lon",
                                      titleField.text,@"name",
                                      commentField.text,@"comment",
                                      [NSString stringWithFormat:@"%@",tag_ids],@"tag_ids",
                                      nil];
        NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        [httpClient postPath:@"/ws.php?format=json&method=pwg.images.add" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError* error;
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:responseObject
                                  
                                  options:kNilOptions 
                                  error:&error];
            //NSLog(@"%@",[[json objectForKey:@"result"] objectForKey:@"image_id"]);
            //NSString *image_id = [NSString stringWithFormat:@"%@",[[json objectForKey:@"result"] objectForKey:@"image_id"]];
            //[self sendTag:image_id];
            [hud hide:YES];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Votre photo a été ajoutée avec succès!" andMessage:nil];
            [self.tabBarController setSelectedIndex:0];
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                      [ScrlPage setContentOffset:CGPointMake(0, 0) animated:YES];
                                      //NSLog(@"Button1 Clicked");
                                  }];
            [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
            [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
            [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
            [alertView show];
            TokenImage.image = cover;
            commentField.text = nil;
            titleField.text = nil;
            [ListOfNewTag removeAllObjects];
            [ListOfExistingTagId removeAllObjects];
            [ListOfNewTagId removeAllObjects];
            [ListOfTag removeAllObjects];
            [ListOfTagID removeAllObjects];
            Taglabel.text = @"";
            //add new Tag to database
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];

    }
}

/*-(void)AddNewTag
{
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  //[NSString stringWithString:Sum], @"file_sum",
                                  
                                  nil];
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.images.add" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        NSLog(@"%@",[[json objectForKey:@"result"] objectForKey:@"image_id"]);
        NSString *image_id = [NSString stringWithFormat:@"%@",[[json objectForKey:@"result"] objectForKey:@"image_id"]];
        [self sendTag:image_id];
        //NSLog(@"%@ Uploded",responseStr);
        
        [hud hide:YES];
        TokenImage.image = cover;
        //commentField.text = nil;
        //titleField.text = nil;
        //add new Tag to database
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];

}*/


/*-(void)sendTag:(NSString *)image_id
{
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithString:image_id], @"image_id",
                                  [NSArray arrayWithObjects:@"1",@"2", nil], @"tag_ids", nil];
    
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.images.setInfo" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Sucess with tag");
        [hud hide:YES];
        TokenImage.image = cover;
        commentField.text = nil;
        titleField.text = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];

}*/

-(void)Getphoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Choisir source"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Camera",@"Bibliothèque", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];

}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        // all done
    } else if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        // Twitter
    } else if (buttonIndex == 1) {
        // Library
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];

    }
}
- (NSString *)shuffledAlphabet {
    NSString *alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    // Get the characters into a C array for efficient shuffling
    NSUInteger numberOfCharacters = [alphabet length];
    unichar *characters = calloc(numberOfCharacters, sizeof(unichar));
    [alphabet getCharacters:characters range:NSMakeRange(0, numberOfCharacters)];
    
    // Perform a Fisher-Yates shuffle
    for (NSUInteger i = 0; i < numberOfCharacters; ++i) {
        NSUInteger j = (arc4random_uniform(numberOfCharacters - i) + i);
        unichar c = characters[i];
        characters[i] = characters[j];
        characters[j] = c;
    }
    
    // Turn the result back into a string
    NSString *result = [NSString stringWithCharacters:characters length:numberOfCharacters];
    free(characters);
    return result;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    TokenImage.contentMode = UIViewContentModeScaleAspectFit;
    [picker dismissModalViewControllerAnimated:YES];
    TokenImage.backgroundColor = [UIColor clearColor];
    TokenImage.image = image;
}
-(void)closeMap
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    [UIView beginAnimations:@"MoveView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5f];
    CustomMap.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
    [UIView commitAnimations];
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    

    
}
-(void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"dalloc");
    //CustomMap = NULL;
    [CustomMap removeFromSuperview];
    locationField.text = nil;
    TokenImage.image = cover;
    //commentField.text = nil;
    //titleField.text = nil;
    
}
- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[CustomMap dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
         //setPinColor:MKPinAnnotationColorGreen];

    annotationView.image = [UIImage imageNamed:@"marqueur_graffi.png"];
    annotationView.draggable = YES;
    annotationView.annotation = annotation;
    //[CustomMap setCenterCoordinate:nil animated:YES];

    
    return annotationView;
}
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    NSLog(@"yes");
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        CLLocation *theLocation = [[CLLocation alloc]initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        Latitude = droppedAt.latitude;
        Longitude = droppedAt.longitude;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        CLGeocoder *geocode = [[CLGeocoder alloc] init];
        [geocode reverseGeocodeLocation:theLocation
                       completionHandler:^(NSArray *placemarks, NSError *error){
                               if(!error){
                               
                               // Iterate through all of the placemarks returned
                               // and output them to the console
                               for(CLPlacemark *placemark in placemarks){
                                   NSLog(@"%@",[placemark name]);
                                   [locationField setText:[placemark name]];
                               }
                           }
                           else{
                               // Our geocoder had an error, output a message
                               // to the console
                               NSLog(@"There was a reverse geocoding error\n%@",
                                     [error localizedDescription]);
                           }
                       }
         ];
        
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        //CLLocation *theLocation = [[CLLocation alloc]initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        CLLocationCoordinate2D location;
        location.latitude = droppedAt.latitude;
        location.longitude = droppedAt.longitude;
        [point setCoordinate:(location)];
        //[point setTitle:businessName];
        //[CustomMap addAnnotation:view.annotation];
        
        //ITS RIGHT HERE THAT I GET THE ERROR
        //[view removeFromSuperview];
        //[CustomMap addAnnotation:point];
        [view setDragState:MKAnnotationViewDragStateNone];

    }
    
}

-(void)keyboardDidShow
{
    NSLog(@"YES");
}
- (IBAction)showCustomMap:(id)sender {
    if([titleField isFirstResponder]){
        [titleField resignFirstResponder];
    }
    if ([commentField isFirstResponder]) {
        [commentField resignFirstResponder];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CustomMap = [[MKMapView alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    //CustomMap.showsUserLocation = YES;
    CustomMap.delegate = self;
    [CustomMap setCenterCoordinate:CLLocationCoordinate2DMake(Latitude, Longitude)];
    
    UIButton *closeMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeMapBtn addTarget:self
                    action:@selector(closeMap)
          forControlEvents:UIControlEventTouchDown];
    //[closeMapBtn setTitle:@"Show View" forState:UIControlStateNormal];
    closeMapBtn.frame = CGRectMake(280, 10, 32, 21);
    //closeMapBtn.imageView.image = [UIImage imageNamed:@"fleche.png"];
    //[view addSubview:button];
    [closeMapBtn setImage:[UIImage imageNamed:@"fleche.png"] forState:UIControlStateNormal];
    
    
    [self.view addSubview:CustomMap];
    [CustomMap addSubview:closeMapBtn];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D location;
    location.latitude = Latitude;
    location.longitude = Longitude;
    [point setCoordinate:(location)];
    [CustomMap addAnnotation:point];
    
    
    
    
    [UIView beginAnimations:@"MoveView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5f];
    CustomMap.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    [UIView commitAnimations];
}
@end
