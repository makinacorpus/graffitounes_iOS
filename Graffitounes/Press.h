//
//  Press.h
//  Graffitounes
//
//  Created by Yahya on 29/08/13.
//  Copyright (c) 2013 Makina-corpus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Press : UILongPressGestureRecognizer
{
    int CellIndex;
}
@property(nonatomic,assign) int CellIndex;
@end
