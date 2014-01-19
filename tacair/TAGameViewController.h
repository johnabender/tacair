//
//  TAGameViewControllerViewController.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAGame.h"
#import "TAUnitViewController.h"
#import "TATankPlacementViewController.h"
#import "TABoardViewController.h"
#import "TAAirAllocationViewController.h"

@interface TAGameViewController : UIViewController <TAUnitViewTouchTarget>
{
    BOOL shouldBeginSetup;

    IBOutlet UILabel *sideLabel;
    IBOutlet UILabel *phaseLabel;

    NSMutableSet *combatVCs;
}

@property (nonatomic, strong) TABoardViewController *boardVC;
@property (nonatomic, readonly) TAGame *game;
@property (nonatomic, readonly) TATankPlacementViewController *tankPlacementVC;
@property (nonatomic, readonly) TAAirAllocationViewController *airAllocationVC;

@property (nonatomic, readonly) id <TAUnitViewTouchTarget> unitMoveTarget;

+(TAGameViewController*)gameVC;

-(void) beginSetupWhenAvailable;

-(void) placeUnit:(TAUnit*)unit inHex:(TAHex*)hex;
-(void) airAllocationFinished;

-(void) resolveCombat:(TACombat*)combat;

-(IBAction) doneButtonPressed;

@end
