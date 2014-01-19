//
//  TACombatViewController.h
//  tacair
//
//  Created by John Bender on 11/30/13.
//
//

#import <UIKit/UIKit.h>
#import "TACombat.h"

@interface TACombatViewController : UIViewController
{
    __weak IBOutlet UILabel *differentialLabel;
    __weak IBOutlet UIButton *attackButton;

    __weak IBOutlet UIScrollView *scrollView;

    NSMutableSet *unitVCs;

    CGPoint touchOffset;
    BOOL isMoving;
}

@property (nonatomic, strong) TACombat *combat;

-(id) initWithCombat:(TACombat*)combat_;

-(void) updateLayout;

-(IBAction) pressedAttackButton;

@end
