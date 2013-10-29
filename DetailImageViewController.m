//
//  DetailImageViewController.m
//  Graffitounes
//
//  Created by Yahya on 30/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "DetailImageViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 165;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
@interface DetailImageViewController ()

@end

@implementation DetailImageViewController
@synthesize idIgm,date_available,author,image,arrayComment,name,nb_comments,nb_likes,CommentsList,ScrollView,ImageSwitch,CommentArea,ViewCommentArea,ButtonShareComment,LikeButton,geoButton,heart,SpinnerLike,FaceookBtn,GhostButton,Token,SegueID,deleteBtn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
-(void)makeFull
{
    [self performSegueWithIdentifier:@"fullScreen" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBar.hidden = YES;
    //Scale Pictures
    image.contentMode = UIViewContentModeScaleAspectFit;

    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *urlToken = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.session.getStatus",BaseURL]];
    NSURLRequest *requestToken = [NSURLRequest requestWithURL:urlToken];
    AFJSONRequestOperation *operationToken = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestToken success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Token = [[JSON objectForKey:@"result"] objectForKey:@"pwg_token"];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    [operationToken start];
    
    //Check if my Picture
    if (![SegueID isEqualToString:@"Detail"])
    {
        deleteBtn.hidden = YES;
    }
    SpinnerLike.hidden=YES;
    Longitude = [[NSString alloc] init];
    Latitude = [[NSString alloc] init];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Chargement";
    [hud show:YES];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSString *StringURL = [NSString stringWithFormat:@"%@/ws.php?format=json&method=pwg.images.getInfo&image_id=%@",BaseURL,idIgm];
    NSURL *url = [NSURL URLWithString:StringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //Show picture infos
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        author.text = [[JSON objectForKey:@"result"] objectForKey:@"author"];
        date_available.text = [self GetFrenshFormatForDate:[[JSON objectForKey:@"result"] objectForKey:@"date_metadata_update"]];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[[[JSON objectForKey:@"result"] objectForKey:@"derivatives"] objectForKey:@"xsmall"] objectForKey:@"url"]]]];
        urlPicto = [[NSString alloc] initWithFormat:@"%@",[[[[JSON objectForKey:@"result"] objectForKey:@"derivatives"] objectForKey:@"xsmall"] objectForKey:@"url"]];
        image.image = img;
        NSLog(@"%@",[[JSON objectForKey:@"result"] objectForKey:@"ghost"]);
        if ([[[JSON objectForKey:@"result"] objectForKey:@"ghost"] intValue]==1) {
            GhostButton.enabled = NO;
        }
        [image setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeFull)];
        [tap setNumberOfTouchesRequired:1];
        [image addGestureRecognizer:tap];
        name = [[JSON objectForKey:@"result"] objectForKey:@"name"];
        self.title =name;
        Longitude = [[JSON objectForKey:@"result"] objectForKey:@"lon"];
        Latitude = [[JSON objectForKey:@"result"] objectForKey:@"lat"];
        link = [[NSString alloc] initWithString:[[JSON objectForKey:@"result"] objectForKey:@"page_url"]];
        nb_comments.text = [NSString stringWithFormat:@"%@",[[[JSON objectForKey:@"result"] objectForKey:@"comments"] objectForKey:@"nb_comments"]];
        LocalNbComment = [nb_comments.text intValue];
        arrayComment = [[NSArray alloc] initWithArray:[[[JSON objectForKey:@"result"] objectForKey:@"comments"] objectForKey:@"_content"]];
        CommentsList.frame = CGRectMake(0, 465, 280,[arrayComment count]*70);
        CommentsList.hidden = NO;
        ScrollView.contentSize = CGSizeMake(320,490+[arrayComment count]*70);
        [CommentsList reloadData];
        if ([arrayComment count]==0) {
            CommentsList.hidden = YES;
        }
        [hud hide:YES];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //Doo not connect to server
        
        NSLog(@"%@", [error description]);
    }];
    [operation start];
    
    //Init comment button
    ButtonShareComment.enabled = NO;
    prefs = [NSUserDefaults standardUserDefaults];
    //check if user like it
    [self GetLikeIt];
    //number of likes
    [self numberOfLike];
    
    //init frame
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    

    ScrollView.frame = CGRectMake(0,0,screenRect.size.width,screenRect.size.height);
    
    ScrollView.bounces = NO;
    CommentsList.hidden = YES;
    CommentArea.delegate=self;
    //Set border
    LikeButton.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    LikeButton.layer.borderWidth = 1.0f;
    
    geoButton.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    geoButton.layer.borderWidth = 1.0f;
    
    FaceookBtn.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    FaceookBtn.layer.borderWidth = 1.0f;
    
    GhostButton.layer.borderColor = [[UIColor colorWithRed:(39/255.0) green:(205/255.0) blue:(222/255.0) alpha:1] CGColor];
    GhostButton.layer.borderWidth = 1.0f;
}
-(void)numberOfLike
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSString *StringURL = [NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.get.likes.count&id_image=%@",idIgm];
    NSURL *url = [NSURL URLWithString:StringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"%@",JSON);
        nb_likes.text = [NSString stringWithFormat:@"%@",[JSON objectForKey:@"result"]] ;
        //if ([[JSON objectForKey:@"result"] intValue]==1) {
          //  LikeButton.enabled = NO;
        //}
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
    }];
    [operation start];

}
- (IBAction)delete:(id)sender {
    NSLog(@"Delete");
    NSLog(@"%@ %@", idIgm,Token);
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@",idIgm], @"image_id",
                                  [NSString stringWithFormat:@"%@",Token], @"pwg_token", nil];
    
    NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/ws.php?format=json&method=pwg.images.delete" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [self.navigationController popViewControllerAnimated:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapsView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *viewIdentifier = @"annotationView";
       MKAnnotationView *annotationView = (MKAnnotationView *) [mapsView dequeueReusableAnnotationViewWithIdentifier:viewIdentifier];
    if (annotationView == nil) {
    	annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewIdentifier];
    }
    
    annotationView.image = [UIImage imageNamed:@"marqueur_graffi.png"];
    return annotationView;
    
}
-(void)RefreshData
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSString *StringURL = [NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.images.getInfo&image_id=%@",idIgm];
    NSURL *url = [NSURL URLWithString:StringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        arrayComment = [[NSArray alloc] initWithArray:[[[JSON objectForKey:@"result"] objectForKey:@"comments"] objectForKey:@"_content"]];
        CommentsList.frame = CGRectMake(0, 465, 280,[arrayComment count]*70);
        CommentsList.hidden = NO;
        [self ResizeView:[arrayComment count]];
        
        [CommentsList reloadData];
        CGPoint bottomOffset = CGPointMake(0, ScrollView.contentSize.height - ScrollView.bounds.size.height);
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:[arrayComment count]-1 inSection:0];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [CommentsList reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationLeft];
        [ScrollView setContentOffset:bottomOffset animated:YES];
        if ([arrayComment count]==0) {
            CommentsList.hidden = YES;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
    }];
    [operation start];
}
-(void)GetLikeIt
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSString *StringURL = [NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.GetFavorit&id_image=%@&user_id=%@",idIgm,[prefs objectForKey:@"user_id"]];
    NSURL *url = [NSURL URLWithString:StringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"%@",JSON);
        if ([[JSON objectForKey:@"result"] intValue]==1) {
            //LikeButton.enabled = NO;
            heart.image = [UIImage imageNamed:@"ic_coeurbrise.png"];
            Liked = 1;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
    }];
    [operation start];
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [arrayComment count];
    //count number of row from counting array hear cataGorry is An Array
    //return 5;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
       NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
       cell = [nib objectAtIndex:0];
    }
    
    if ([arrayComment count]<indexPath.row) {
        cell.dateComment.text = @"test";
        cell.personComment.text = @"test";
        cell.commentText.text = @"test";
        return cell;
    }else
    {
        //NSLog(@"%@",[[arrayComment objectAtIndex:indexPath.row] objectForKey:@"date"]);
        NSRange range = NSMakeRange(0, 10);
        NSString *subString = [[[arrayComment objectAtIndex:indexPath.row] objectForKey:@"date"] substringWithRange:range];
        
        cell.dateComment.text = [self GetFrenshFormatForDate:subString]; ;
        cell.personComment.text = [[arrayComment objectAtIndex:indexPath.row] objectForKey:@"author"];
        cell.commentText.text = [[arrayComment objectAtIndex:indexPath.row] objectForKey:@"content"];
        //NSLog(@"http://graffitounes.makina-corpus.net/upload/profile_picture/%@-picture.jpg",[[arrayComment objectAtIndex:indexPath.row] objectForKey:@"id_user"]);
        [cell.personImageComment setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/upload/profile_picture/%@-picture.jpg",[[arrayComment objectAtIndex:indexPath.row] objectForKey:@"id_user"]]]];
        //[cell.ImageView setImageWithURL:[NSURL URLWithString:[[[Result[indexPath.row] objectForKey:@"derivatives"] objectForKey:@"square"] objectForKey:@"url"]]];

        CGRect frame;
        frame = cell.commentText.frame;
        frame.size.height = [cell.commentText contentSize].height;
        cell.commentText.frame = frame;
        return cell;
    }
        //;
    
    
}

-(NSString *)GetFrenshFormatForDate:(NSString *)date
{
    NSRange rangeYear = NSMakeRange(0,4);
    NSRange rangeMonth = NSMakeRange(5,2);
    NSRange rangeDay = NSMakeRange(8,2);
    NSString *year = [date substringWithRange:rangeYear];
    NSString *month = [date substringWithRange:rangeMonth];
    NSString *day = [date substringWithRange:rangeDay];
    return [NSString stringWithFormat:@"%@-%@-%@",day,month,year];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fullScreen"]) {
        FullScreenViewController *destViewController = segue.destinationViewController;
        destViewController.full = image.image;
    }
    if ([segue.identifier isEqualToString:@"tomap"]) {
        MapViewController *destViewController = segue.destinationViewController;
        destViewController.lng = Longitude;
        destViewController.lat = Latitude;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchView:(id)sender {
    [self performSegueWithIdentifier:@"tomap" sender:self];
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
        //NSLog(@"test");
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (IBAction)ShareComment:(id)sender {
    NSLog(@"%@",[prefs objectForKey:@"email"]);
        ButtonShareComment.enabled = NO;
        [CommentArea resignFirstResponder];
        NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        httpClient.allowsInvalidSSLCertificate = YES;
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      idIgm,@"image_id",
                                      [prefs objectForKey:@"author"],@"author",
                                      CommentArea.text,@"content",
                                      @"",@"key",
                                      [prefs objectForKey:@"email"],@"email",
                                      nil];
        NSLog(@"%@",entry);
        [httpClient postPath:@"/ws.php?format=json&method=pwg.images.addComment" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"Request Successful, response '%@'", responseStr);
            CommentArea.text=@"";
            LocalNbComment = LocalNbComment +1;
            NSLog(@"%i",LocalNbComment);
            nb_comments.text = [NSString stringWithFormat:@"%i",LocalNbComment];
            
            [self RefreshData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %i", error.code);
            
        }];
        
    
}
-(void)ResizeView:(int)c
{
    ScrollView.contentSize = CGSizeMake(320,500+c*70);
}
- (void)textViewDidChange:(UITextView *)textView
{
    if([textView.text isEqualToString:@""])
    {
        ButtonShareComment.enabled = NO;
    }else
    {
        ButtonShareComment.enabled = YES;
    }
}

- (IBAction)Like:(id)sender {
    if (Liked!=1) {
        LikeButton.enabled = NO;
        heart.image = nil;
        SpinnerLike.hidden = NO;
        [SpinnerLike startAnimating];
        NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        //NSLog(@"%@",[prefs objectForKey:@"username"]);
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [prefs objectForKey:@"user_id"], @"user_id",
                                      [NSString stringWithFormat:@"%@",idIgm], @"id_image",
                                      nil];
        [httpClient postPath:@"/ws.php?format=json&method=pwg.Like" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
            nb_likes.text = [NSString stringWithFormat:@"%i",[nb_likes.text intValue] + 1];
            [SpinnerLike stopAnimating];
            SpinnerLike.hidden=YES;
            LikeButton.enabled = YES;
            
            heart.image = [UIImage imageNamed:@"ic_coeurbrise.png"];
            Liked = 1;
            //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //NSLog(@"Request Successful, response '%@'", responseStr);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];
    }else
    {
        LikeButton.enabled = NO;
        heart.image = nil;
        SpinnerLike.hidden = NO;
        [SpinnerLike startAnimating];
        NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        //NSLog(@"%@",[prefs objectForKey:@"username"]);
        NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [prefs objectForKey:@"user_id"], @"user_id",
                                      [NSString stringWithFormat:@"%@",idIgm], @"id_image",
                                      nil];
        [httpClient postPath:@"/ws.php?format=json&method=pwg.Dislike" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
            nb_likes.text = [NSString stringWithFormat:@"%i",[nb_likes.text intValue] - 1];
            [SpinnerLike stopAnimating];
            SpinnerLike.hidden=YES;
            LikeButton.enabled = YES;
            
            heart.image = [UIImage imageNamed:@"meslike_on.png"];
            Liked = 0;
            //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //NSLog(@"Request Successful, response '%@'", responseStr);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];
    }
    
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (IBAction)FacebookShare:(id)sender {
    
    BOOL facebookInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://requests"]];
    //NSLog(@"%i",facebookInstalled);
    if (facebookInstalled) {
        NSURL* url = [NSURL URLWithString:link];
        
        
        [FBDialogs presentShareDialogWithLink:url
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              NSLog(@"Error: %@", error.description);
                                          } else {
                                              NSLog(@"Success!");
                                              NSLog(@"%@",call);
                                          }
                                      }];
    }else
    {
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         name, @"name",
         link, @"link",
         urlPicto, @"picture",
         nil];
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                     } else {
                         // User clicked the Share button
                         NSString *msg = [NSString stringWithFormat:
                                          @"Posted story, id: %@",
                                          [urlParams valueForKey:@"post_id"]];
                         NSLog(@"%@", msg);
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Result"
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil]
                          show];
                     }
                 }
             }
         }];
    }
}
- (IBAction)DoGhost:(id)sender {
    GhostButton.enabled = NO;
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Confirmez vous que ce graffiti a été effacé?" andMessage:nil];
    
    [alertView addButtonWithTitle:@"Oui"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Button1 Clicked");
                              NSURL *url = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
                              AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
                              NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                            [NSString stringWithFormat:@"%@",idIgm], @"image_id",
                                                            nil];
                              
                              [httpClient postPath:@"/ws.php?format=json&method=pwg.TurnGhost" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                              }];
                          }];
    [alertView addButtonWithTitle:@"Annuler"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              GhostButton.enabled = YES;
                          }];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
    [alertView show];
    
}
@end
