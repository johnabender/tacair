//
//  TATankPlacementViewController.m
//  tacair
//
//  Created by John Bender on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TATankPlacementViewController.h"
#import "TAGameViewController.h"

@implementation TATankPlacementViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(void) layoutTanks
{
    __block CGRect frame;
    
    [UIView animateWithDuration:0.1 animations:^{
        NSInteger t = 0;
        for( UIView *subview in scrollView.subviews )
            if( [subview isKindOfClass:[TAUnitView class]] ) {
                frame = subview.frame;
                frame.origin.y = layoutMargin;
                frame.origin.x = t*frame.size.width + (t + 1)*layoutMargin;
                subview.frame = frame;
            
                t++;
            }
    }];

    scrollView.contentSize = CGSizeMake( CGRectGetMaxX( frame ) + layoutMargin, 1. );
}

-(void) addTank:(TATank*)tank
{
    TATankViewController *tankVC = (TATankViewController*)(tank.viewController);
    if( tankVC == nil )
        tankVC = [[TATankViewController alloc] initWithTank:tank];    
    
    [scrollView addSubview:tankVC.view];
    
    [self layoutTanks];
}

-(void) removeTank:(TATank*)tank
{
    if( tank.viewController.view.superview == scrollView )
        [tank.viewController.view removeFromSuperview];
    
    [self layoutTanks];
}


#pragma mark - Unit touch target

-(BOOL) shouldUnitViewStartMoving:(TAUnitView*)unitView
{
    return TRUE;
}

-(void) unitViewStartedMoving:(TAUnitView*)unitView
{
    if( unitView.superview != scrollView )
        return;
    
    [self.view addSubview:unitView];
    [self removeTank:(TATank*)unitView.unit];
}

-(void) unitViewMoving:(TAUnitView*)unitView
{
    TABoardViewController *boardVC = [TAGameViewController gameVC].boardVC;

    [boardVC stopHighlightingHexesOfColor:TAHexHighlightColorHighlight];

    if( ![self.view pointInside:unitView.center withEvent:nil] ) {
        CGPoint testPoint = [self.view convertPoint:unitView.center toView:boardVC.view.superview];
        TAHex *hex = [boardVC hexAtPoint:testPoint];
        if( hex != nil )
            [boardVC highlightHex:hex color:TAHexHighlightColorHighlight];
    }
}

-(void) unitViewDoneMoving:(TAUnitView*)unitView
{
    TABoardViewController *boardVC = [TAGameViewController gameVC].boardVC;
    
    [boardVC stopHighlightingHexesOfColor:TAHexHighlightColorHighlight];

    // place view if legal
    if( ![self.view pointInside:unitView.center withEvent:nil] ) {
        CGPoint testPoint = [self.view convertPoint:unitView.center toView:boardVC.view];
        TAHex *hex = [boardVC hexAtPoint:testPoint];
        if( hex != nil && (hex.viewer.highlightColor & TAHexHighlightColorAvailable) )
            [[TAGameViewController gameVC] placeUnit:unitView.unit inHex:hex];
    }
    
    // if not placed, return view to placement queue
    if( unitView.superview == self.view )
        [UIView animateWithDuration:0.25 animations:^{
            unitView.center = CGPointMake( self.view.bounds.size.width,
                                           self.view.bounds.size.height/2. );
        } completion:^(BOOL completed) {
            [self addTank:(TATank*)unitView.unit];
        }];
}

@end
