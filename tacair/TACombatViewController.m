//
//  TACombatViewController.m
//  tacair
//
//  Created by John Bender on 11/30/13.
//
//

#import "TACombatViewController.h"
#import "TAGameViewController.h"
#import "TAUnitViewController.h"
#import "TARoundedOverlayView.h"
#import "TAHexView.h"

@implementation TACombatViewController

@synthesize combat;

- (id)initWithCombat:(TACombat*)combat_
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        combat = combat_;
        combat.viewController = self;

        unitVCs = [NSMutableSet new];
    }
    return self;
}


-(void) viewDidLoad
{
    [super viewDidLoad];

    attackButton.layer.cornerRadius = self.view.layer.cornerRadius;

    [(TARoundedOverlayView*)self.view showHandle:YES];

    [self updateLayout];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGRect frame = self.view.frame;
    frame.origin.y = combat.defender.viewController.view.frame.origin.y + combat.defender.viewController.view.frame.size.height/2.;
    frame.origin.x = combat.defender.viewController.view.frame.origin.x - frame.size.width;
    self.view.frame = frame;
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CGPoint dest = [self.view.superview convertPoint:combat.defender.location.viewer.center
                                            fromView:combat.defender.location.viewer.superview];
    assert( combat.defender.location.viewer.superview.superview == self.view.superview );
    [(TARoundedOverlayView*)self.view drawArrowToPoint:dest];
}


-(void) updateLayout
{
    __block CGRect frame;

    differentialLabel.text = [NSString stringWithFormat:@"%+d", [combat differential]];
    // http://stackoverflow.com/questions/1992950/nsstring-sizewithattributes-content-rect
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:differentialLabel.text];
    [textStorage addAttribute:NSFontAttributeName value:differentialLabel.font
                        range:NSMakeRange(0, [textStorage length])];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake( 1000., 1000. )];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    CGSize usedSize = [layoutManager usedRectForTextContainer:textContainer].size;
    DLog( @"%@", NSStringFromCGSize( usedSize ) ); // TODO: this is right, but displayed size isn't
    frame = differentialLabel.frame;
    frame.size = usedSize;
    differentialLabel.frame = frame;

    for( NSInteger a = 0; a < [combat.attackers count]; a++ ) {
        TAUnit *attacker = [combat.attackers allObjects][a];
        if( !attacker.duplicateViewController ) {
            id vc = [[TAUnitViewController alloc] initAsDuplicateForUnit:attacker];
            [unitVCs addObject:vc];
        }
        TAUnitViewController *unitVC = attacker.duplicateViewController;

        unitVC.view.center = [scrollView convertPoint:unitVC.view.center fromView:unitVC.view.superview];

        [scrollView addSubview:unitVC.view];
    }

    [UIView animateWithDuration:0.1 animations:^{
        for( NSInteger a = 0; a < [combat.attackers count]; a++ ) {
            NSInteger row = a/2;
            NSInteger col = a % 2;
            TAUnit *attacker = [combat.attackers allObjects][a];
            TAUnitViewController *unitVC = attacker.duplicateViewController;

            frame = unitVC.view.frame;
            frame.origin.x = col*frame.size.height + (col + 1)*layoutMargin;
            frame.origin.y = row*frame.size.height + (row + 2)*layoutMargin;
            unitVC.view.frame = frame;
        }
    }];

    scrollView.contentSize = CGSizeMake( 1., CGRectGetMaxY( frame ) + layoutMargin );
}


-(IBAction) pressedAttackButton
{
    [[TAGameViewController gameVC] resolveCombat:combat];
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( isMoving ) return;

    CGPoint touchPosition = [[touches anyObject] locationInView:self.view.superview];
    touchOffset = CGPointMake( touchPosition.x - self.view.center.x,
                               touchPosition.y - self.view.center.y );
    isMoving = TRUE;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !isMoving ) return;

    CGPoint touchPosition = [[touches anyObject] locationInView:self.view.superview];
    self.view.center = CGPointMake( touchPosition.x - touchOffset.x,
                                    touchPosition.y - touchOffset.y );

    CGPoint dest = [self.view.superview convertPoint:combat.defender.location.viewer.center
                                            fromView:combat.defender.location.viewer.superview];
    assert( combat.defender.location.viewer.superview.superview == self.view.superview );
    [(TARoundedOverlayView*)self.view drawArrowToPoint:dest];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !isMoving ) return;

    isMoving = FALSE;
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !isMoving ) return;

    isMoving = FALSE;
}

@end
