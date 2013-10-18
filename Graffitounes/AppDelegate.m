//
//  AppDelegate.m
//  Graffitounes
//
//  Created by Yahya on 16/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "AppDelegate.h"
#import "GalleryViewController.h"
#import "AFHTTPClient.h"
#import "AFNetworking.h"

@implementation AppDelegate
NSString *const FBSessionStateChangedNotification =
@"com.example.Login:FBSessionStateChangedNotification";
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSession.activeSession handleDidBecomeActive];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        NSLog(@"OK");
        [self.window.rootViewController performSegueWithIdentifier:@"facebookConnect" sender:self];
    }

    
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    //NSLog(@"test");
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
                if (FBSession.activeSession.isOpen) {
                    [FBRequestConnection
                     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                       id<FBGraphUser> user,
                                                       NSError *error) {
                        
                         if (!error) {
                             NSString *userInfo = @"";
                             userInfo = [userInfo
                                         stringByAppendingString:
                                         [NSString stringWithFormat:@"%@",
                                          user.name]];
                             //NSLog(@"%@",user);
                             NSString *oauth_id = [[NSString alloc] initWithFormat:@"Facebook---%@",user.id];
                             //NSLog(@"%@",oauth_id);
                             /******************* Add facebook user in database ************************************/
                             NSURL *urlString = [NSURL URLWithString:@"http://graffitounes.makina-corpus.net"];
                             AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:urlString];
                             //NSLog(@"%@",userInfo);
                             
                             NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                           user.username, @"username",
                                                           @"", @"password",
                                                           [user objectForKey:@"email"], @"email",
                                                           oauth_id, @"oauth_id",nil];
                             [httpClient postPath:@"/ws.php?format=json&method=pwg.addUser" parameters:entry success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                 NSLog(@"Request Successful, response '%@'", responseStr);
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                             }];
                             
                             /******************** Store users information *********************************************/
                             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                             [prefs setObject:userInfo forKey:@"name"];
                             [prefs setObject:user.username forKey:@"username"];
                             [prefs setObject:[user objectForKey:@"email"] forKey:@"email"];
                             [prefs setObject:user.first_name forKey:@"author"];
                             [prefs setObject:[user.location objectForKey:@"name"] forKey:@"location"];
                             NSLog(@"%@",user.first_name);
                             [prefs setObject:oauth_id forKey:@"oauth_id"];
                             
                             //[prefs setObject:user.fir forKey:@"author"];
                             
                             /******************** Store Profil Picture *********************************************/
                             NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200",user.id]];
                             NSData *data = [NSData dataWithContentsOfURL:url];
                             NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                             path = [path stringByAppendingString:@"/profilePicture.png"];
                             [data writeToFile:path atomically:YES];
                             [self.window.rootViewController performSegueWithIdentifier:@"facebookConnect" sender:self];
                             /******************** Upload Profile Pictures ********************************************/
                             
                             //NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/myImage.png"];
                             //[data writeToFile:imagePath atomically:YES];
                             if (data)
                             {
                                 NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSString stringWithFormat:@"%@-picture",[prefs objectForKey:@"username"]], @"name",
                                                             nil];
                                 AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://graffitounes.makina-corpus.net/"]];
                                 
                                 NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"profile_picture.php" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                     [formData appendPartWithFileData:data name:@"uploadedfile" fileName:[NSString stringWithFormat:@"%@",[prefs objectForKey:@"username"]] mimeType:@"image/jpeg"];
                                 }];
                                 
                                 AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                                 
                                 [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                                  {
                                      
                                      
                                      
                                      NSDictionary *jsons = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                                      NSLog(@"response: %@",jsons);
                                      
                                      
                                      
                                      
                                  }
                                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                  {
                                      if([operation.response statusCode] == 403)
                                      {
                                          NSLog(@"Upload Failed");
                                          return;
                                      }
                                      NSLog(@"error: %@", [operation error]);
                                      
                                  }];
                                 
                                 [operation start];
                             }

                             
                         }
                     }];
                }
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    //NSLog(@"testAllow");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}


@end
