//
//  TATankPlacementView.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TARoundedOverlayView.h"
#import "TAGameViewController.h"
#import "TAArrowView.h"
#import "TAHandleView.h"

@implementation TARoundedOverlayView

@synthesize highlighted;

-(void) doInit
{
    defaultColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.3];
    highlightColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];

    self.backgroundColor = defaultColor;

    self.layer.cornerRadius = 20.;
    self.layer.borderWidth = 2.;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self doInit];
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    [self doInit];
}


-(void) setHighlighted:(BOOL)toHighlight
{
    if( highlighted != toHighlight ) {
        highlighted = toHighlight;

        if( highlighted )
            self.backgroundColor = highlightColor;
        else
            self.backgroundColor = defaultColor;
    }
}


-(void) drawArrowToPoint:(CGPoint)point
{
    [arrowView removeFromSuperview];

    CGPoint dest = [self convertPoint:point fromView:self.superview];

    CGFloat rad2 = self.layer.cornerRadius*self.layer.cornerRadius;
    CGFloat inset = sqrt( rad2 + rad2 ) - self.layer.cornerRadius;

    CGFloat left = MIN( 0., dest.x );
    CGFloat right = MAX( self.frame.size.width, dest.x );
    CGFloat top = MIN( 0., dest.y );
    CGFloat bottom = MAX( self.frame.size.height, dest.y );

    arrowView = [[TAArrowView alloc] initWithFrame:CGRectMake( left, top, right - left, bottom - top )];
    arrowView.backgroundColor = [UIColor clearColor];
    arrowView.userInteractionEnabled = FALSE;
    [self insertSubview:arrowView atIndex:0];

    UIBezierPath *arrowPath = [UIBezierPath new];
    arrowPath.lineWidth = self.layer.borderWidth;

    [arrowPath moveToPoint:CGPointMake( self.frame.size.width - left - inset, -top + inset )];

    [arrowPath addLineToPoint:CGPointMake( dest.x - left, dest.y - top )];

    arrowView.arrowPath = arrowPath;
}


-(void) showHandle:(BOOL)showHandle
{
    if( showHandle ) {
        handleView = [[TAHandleView alloc] initWithFrame:CGRectMake( 0., self.frame.size.height - 44.,
                                                                     self.frame.size.width, 44. )];
        [handleView setCornerRadius:self.layer.cornerRadius];
        [self addSubview:handleView];
    }
    else {
        [handleView removeFromSuperview];
        handleView = nil;
    }
}

@end
