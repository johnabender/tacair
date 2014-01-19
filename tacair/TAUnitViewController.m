//
//  TAUnitViewController.m
//  tacair
//
//  Created by John Bender on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUnitViewController.h"
#import "TAGameViewController.h"

#define backgroundColorNATO [UIColor colorWithRed:0.6 green:0.8 blue:0.4 alpha:1.]
#define backgroundColorPACT [UIColor colorWithRed:0.8 green:0.7 blue:0.3 alpha:1.]

@implementation TAUnitViewController

@synthesize unit;


+(NSString*) stringForMovementType:(TAUnitMovementType)movementType
{
    switch( movementType ) {
        case TAUnitMovementTypeNone:
            return @"/";
        case TAUnitMovementTypeFoot:
            return @"+";
        case TAUnitMovementTypeWheel:
            return @":";
        case TAUnitMovementTypeTrack:
            return @"-";
        case TAUnitMovementTypeHelicopter:
            return @"*";
        case TAUnitMovementTypeSlowAir:
            return @"%";
        case TAUnitMovementTypeFastAir:
            return @"#";
        default:
            return @"?";
    }
}


- (id)initWithUnit:(TAUnit*)myUnit duplicate:(BOOL)dupe
{
    self = [super initWithNibName:@"TAUnitViewController" bundle:nil];
    if (self) {
        unit = myUnit;
        if( dupe )
            unit.duplicateViewController = self;
        else
            unit.viewController = self;

        if( unit.team == TASideNATO )
            self.view.backgroundColor = backgroundColorNATO;
        else if( unit.team == TASidePACT )
            self.view.backgroundColor = backgroundColorPACT;
        self.view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.view.layer.borderWidth = 1.;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 2;
        [tap addTarget:self action:@selector(tapHandler)];
        [self.view addGestureRecognizer:tap];
    }
    return self;
}

-(id)initWithUnit:(TAUnit*)myUnit
{
    return [self initWithUnit:myUnit duplicate:NO];
}

-(id) initAsDuplicateForUnit:(TAUnit*)myUnit
{
    return [self initWithUnit:myUnit duplicate:YES];
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    [self updateUnitViews];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(BOOL) isDuplicate
{
    return (unit.duplicateViewController == self);
}


-(void) updateUnitViews
{
    aLabel.text = [NSString stringWithFormat:@"%d", unit.A];
    bLabel.text = [NSString stringWithFormat:@"%d", unit.B];
    movementLabel.text = [TAUnitViewController stringForMovementType:unit.movementType];

    if( unit.disruptionLevels == 0 )
        disruptionLabel.hidden = TRUE;
    else {
        disruptionLabel.hidden = FALSE;
        disruptionLabel.text = [NSString stringWithFormat:@"%d", unit.disruptionLevels];
    }
}


#pragma mark - Touch handlers

-(void) pickUpView
{
    [UIView animateWithDuration:0.1 animations:^{
        self.view.transform = CGAffineTransformMakeScale( 1.1, 1.1 );
        self.view.alpha = 0.7;
    }];
}


-(void) dropView
{
    [UIView animateWithDuration:0.1 animations:^{
        self.view.transform = CGAffineTransformMakeScale( 1., 1. );
        self.view.alpha = 1.;
    }];
}


-(void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if( isViewMoving )
        return;
    if( ![[TAGameViewController gameVC].unitMoveTarget shouldUnitViewStartMoving:(TAUnitView*)self.view] )
        return;
    
    CGPoint touchPosition = [[touches anyObject] locationInView:self.view.superview];
    touchOffset = CGPointMake( touchPosition.x - self.view.center.x,
                               touchPosition.y - self.view.center.y );
    [self pickUpView];
    isViewMoving = TRUE;
    [[TAGameViewController gameVC].unitMoveTarget unitViewStartedMoving:(TAUnitView*)self.view];
}


-(void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    if( !isViewMoving ) return;
    
    CGPoint touchPosition = [[touches anyObject] locationInView:self.view.superview];
    self.view.center = CGPointMake( touchPosition.x - touchOffset.x,
                                    touchPosition.y - touchOffset.y );
    [[TAGameViewController gameVC].unitMoveTarget unitViewMoving:(TAUnitView*)self.view];
}


-(void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if( !isViewMoving ) return;

    [self dropView];
    isViewMoving = FALSE;
    [[TAGameViewController gameVC].unitMoveTarget unitViewDoneMoving:(TAUnitView*)self.view];
}


-(void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    if( !isViewMoving ) return;

    [self dropView];
    isViewMoving = FALSE;
    [[TAGameViewController gameVC].unitMoveTarget unitViewDoneMoving:(TAUnitView*)self.view];
}


#pragma mark - Tap handlers

-(void) tapHandler
{
    TAGame *game = [TAGameViewController gameVC].game;
    if( [game canUnitBeFlipped:unit] && ![unit isAirUnit] ) {
        [(TATank*)unit flip:[game shouldUnitFlippingCostPoints]];
        [self updateUnitViews];
    }
}

@end
