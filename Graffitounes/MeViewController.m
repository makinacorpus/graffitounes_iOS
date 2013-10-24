//
//  MeViewController.m
//  Graffitounes
//
//  Created by Yahya on 17/09/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "MeViewController.h"
#import "AFJSONRequestOperation.h"
#import "SIAlertView.h"
#import "ImageCellViewController.h"
#import "AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
@interface MeViewController ()

@end

@implementation MeViewController
@synthesize FirstBloc,Myfav,Mypic,Name,Location,ProfilePicture,Scroller,Arrow,Result,Pager,MyPicCollection,SecondBloc,MyFavCollection,ResultFav;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)setHPager
{
    [Pager setContentSize:CGSizeMake(612, 180)];
    Pager.pagingEnabled = YES;
    [Pager setShowsHorizontalScrollIndicator:NO];
}
-(void)viewDidAppear:(BOOL)animated
{
    //Get My Pictures
    Pager.scrollEnabled = NO;
    NSLog(@"%i",activePager);
    if (activePager == 0) {
        NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
        StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                         withString:@"%20"];
        NSLog(@"%@",StringUrl);
        Mypic.userInteractionEnabled = NO;
        [self setHPager];
        [self getData:StringUrl];

    }else
    {
        NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.images.Liked&user_id=%@",[prefs objectForKey:@"user_id"]];
        NSLog(@"%@",StringUrl);
        Myfav.userInteractionEnabled = YES;
        [self setHPager];
        [self getFav:StringUrl];

    }
   }
- (void)viewDidLoad
{
    [super viewDidLoad];
    activePager = 0;
    Pager.delegate = self;
    [self.MyPicCollection registerClass:[ImageCellViewController class] forCellWithReuseIdentifier:@"Cellule"];
    [self.MyPicCollection registerNib:[UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cellule"];
    
    [self.MyFavCollection registerClass:[ImageCellViewController class] forCellWithReuseIdentifier:@"Cellule"];
    [self.MyFavCollection registerNib:[UINib nibWithNibName:@"ImageCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cellule"];
    //Border
    FirstBloc.layer.cornerRadius = 5;
    SecondBloc.layer.cornerRadius = 5;
    MyPicCollection.layer.cornerRadius = 5;
    MyFavCollection.layer.cornerRadius = 5;
    //Set Informations
    prefs = [NSUserDefaults standardUserDefaults];
    Name.text = [prefs objectForKey:@"name"];
    Location.text = [prefs objectForKey:@"location"];
    //Set Picture
    NSArray *domains = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *baseDir= [domains objectAtIndex:0];
	NSString *result = [baseDir stringByAppendingPathComponent:@"profilePicture.png"];
    UIImage *Picture = [UIImage imageWithContentsOfFile:result];
    ProfilePicture.image = Picture;
    
}
-(void)resizeViewFav:(int)numbreItem
{
    float height;
    float margin;
    margin = (numbreItem/2) * 12;
    height = 135 * (numbreItem/2);
    if (numbreItem %2 == 0) {
        CGRect framep = Pager.frame;
        framep.size.height = height + margin;
        Pager.frame = framep;
        CGRect frame = MyFavCollection.frame;
        frame.size.height = height + margin;
        MyFavCollection.frame = frame;
        [Scroller setContentSize:CGSizeMake(320,height + margin + 186)];
    }else
    {
        NSLog(@"test");
        CGRect framep = Pager.frame;
        framep.size.height = height + margin + 147;
        Pager.frame = framep;
        CGRect frame = MyFavCollection.frame;
        frame.size.height = height + margin + 150;
        MyFavCollection.frame = frame;
        [Scroller setContentSize:CGSizeMake(320,height + margin + 186 + 150)];
    }
    
}
-(void)resizeView:(int)numbreItem
{
    float height;
    float margin;
    margin = (numbreItem/2) * 12;
    height = 135 * (numbreItem/2);
    if (numbreItem %2 == 0) {
        CGRect framep = Pager.frame;
        framep.size.height = height + margin;
        Pager.frame = framep;
        CGRect frame = MyPicCollection.frame;
        frame.size.height = height + margin;
        MyPicCollection.frame = frame;
        [Scroller setContentSize:CGSizeMake(320,height + margin + 186)];
    }else
    {
        NSLog(@"test");
        CGRect framep = Pager.frame;
        framep.size.height = height + margin + 147;
        Pager.frame = framep;
        CGRect frame = MyPicCollection.frame;
        frame.size.height = height + margin + 150;
        MyPicCollection.frame = frame;
        [Scroller setContentSize:CGSizeMake(320,height + margin + 186 + 160)];
    }
}
-(void)getData:(NSString *)StringUrl
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Result = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        [MyPicCollection reloadData];
        [self resizeView:[Result count]];
        activePager = 0;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];
}
-(void)getFav:(NSString *)StringUrl
{
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    NSURL *url = [NSURL URLWithString:StringUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        ResultFav = [[[JSON objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        //NSLog(@"%@",Result);
        [MyFavCollection reloadData];
        [self resizeViewFav:[ResultFav count]];
        activePager = 1;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", [error description]);
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"impossible de se connecter aux serveurs " andMessage:nil];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  NSLog(@"Button1 Clicked");
                              }];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleSlideFromTop];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [alertView show];
    }];
    
    [operation start];
}
#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if (view == MyFavCollection) {
        return [ResultFav count];
    }else
    {
        return [Result count]; 
    }
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"yahya");
    static NSString *cellIdentifier = @"Cellule";
    ImageCellViewController *cell = (ImageCellViewController *)[cv dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cv == MyFavCollection) {
        [cell.ImageView setImageWithURL:[NSURL URLWithString:[[[ResultFav[indexPath.row] objectForKey:@"derivatives"] objectForKey:@"square"] objectForKey:@"url"]]];
        cell.ParentView.hidden = YES;
    }else
    {
        [cell.ImageView setImageWithURL:[NSURL URLWithString:[[[Result[indexPath.row] objectForKey:@"derivatives"] objectForKey:@"square"] objectForKey:@"url"]]];
        cell.ParentView.hidden = YES;
    }
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(135 ,135);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Detail" sender:collectionView];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Detail"]) {
        NSArray *indexPaths = [sender indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        DetailImageViewController *destViewController = segue.destinationViewController;
        if (sender==MyPicCollection) {
            destViewController.idIgm = [Result[index.row] objectForKey:@"id"];
            destViewController.SegueID = @"Detail";
        }else
        {
            destViewController.idIgm = [ResultFav[index.row] objectForKey:@"id"];
            destViewController.SegueID = @"";

        }
        
    }
    
}
- (IBAction)toMyPic:(id)sender {
    [Pager setContentOffset:CGPointMake(0,0) animated:YES];
    [UIView animateWithDuration:0.2
                     animations:^{
                         Arrow.frame = CGRectMake(71, 170, 16, 10);
                     }
                     completion:^(BOOL finished){
                         Mypic.imageView.image = [UIImage imageNamed:@"mesphotos_on.png"];
                         Mypic.userInteractionEnabled = NO;
                         Myfav.userInteractionEnabled = YES;
                         Myfav.imageView.image = [UIImage imageNamed:@"meslike_off.png"];
                         NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
                         StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                                          withString:@"%20"];
                         [Scroller setContentOffset:CGPointZero animated:YES];

                         [self getData:StringUrl];
                     }];
    
}

- (IBAction)toMyFav:(id)sender {
    [Pager setContentOffset:CGPointMake(306,0) animated:YES];
    [UIView animateWithDuration:0.2
                     animations:^{
                         Arrow.frame = CGRectMake(229, 170, 16, 10);
                     }
                     completion:^(BOOL finished){
                         Mypic.imageView.image = [UIImage imageNamed:@"mesphotos_off.png"];
                         Mypic.userInteractionEnabled = YES;
                         Myfav.userInteractionEnabled = NO;
                         Myfav.imageView.image = [UIImage imageNamed:@"meslike_on.png"];
                         NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.images.Liked&user_id=%@",[prefs objectForKey:@"user_id"]];
                         NSLog(@"%@",StringUrl);
                         [Scroller setContentOffset:CGPointZero animated:YES];

                         [self getFav:StringUrl];
                     }];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"yahya");
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"yahya");
    /*static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        previousPage = page;
        if (previousPage == 1) {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 Arrow.frame = CGRectMake(230, 170, 16, 10);
                             }
                             completion:^(BOOL finished){
                                 Mypic.imageView.image = [UIImage imageNamed:@"mesphotos_off.png"];
                                 //Myfav.enabled = NO;
                                 Myfav.imageView.image = [UIImage imageNamed:@"meslike_on.png"];
                                 NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.images.Liked&user_id=%@",[prefs objectForKey:@"user_id"]];
                                 //NSLog(@"%@",StringUrl);
                                 [Scroller setContentOffset:CGPointZero animated:YES];

                                 [self getFav:StringUrl];
                             }];
        }else
        {
            [UIView animateWithDuration:0.2
                             animations:^{
                                 Arrow.frame = CGRectMake(69, 170, 16, 10);
                             }
                             completion:^(BOOL finished){
                                 Mypic.imageView.image = [UIImage imageNamed:@"mesphotos_on.png"];
                                 //Mypic.enabled = NO;
                                 Myfav.imageView.image = [UIImage imageNamed:@"meslike_off.png"];
                                 NSString *StringUrl =[NSString stringWithFormat:@"http://graffitounes.makina-corpus.net/ws.php?format=json&method=pwg.categories.getImages&author=%@",[prefs objectForKey:@"author"]];
                                 StringUrl = [StringUrl stringByReplacingOccurrencesOfString:@" "
                                                                                  withString:@"%20"];
                                 [Scroller setContentOffset:CGPointZero animated:YES];

                                 [self getData:StringUrl];
                             }];
        }
            
    }
    //NSLog(@"%i",previousPage);*/

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}
@end
