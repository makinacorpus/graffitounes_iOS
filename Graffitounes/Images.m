//
//  Images.m
//  Graffitounes
//
//  Created by Yahya on 17/05/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import "Images.h"

@implementation Images


-(NSArray *)GetImagesUrl:(NSURL*)Url
{
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:Url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    NSMutableArray *Array = [[NSMutableArray alloc] init];

    if (error == nil)
    {
        // Parse data here
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions 
                              error:&error];
        NSArray *arrayimages;
        arrayimages = [[[json objectForKey:@"result"] objectForKey:@"images"] objectForKey:@"_content"];
        for (int i = 0; i<[arrayimages count];i++)
        {
            NSDictionary *arrayContent = [arrayimages objectAtIndex:i];
            [Array addObject:[arrayContent objectForKey:@"element_url"]];
        }
    }
   return Array; 
}
@end
