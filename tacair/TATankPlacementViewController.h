//
//  TATankPlacementViewController.h
//  tacair
//
//  Created by John Bender on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TATank.h"
#import "TATankViewController.h"
#import "TAUnitViewController.h"
@class TAGameViewController;

@interface TATankPlacementViewController : UIViewController <TAUnitViewTouchTarget>
{
    IBOutlet UIScrollView *scrollView;
}

-(void) addTank:(TATank*)tank;
-(void) removeTank:(TATank*)tank;

@end
