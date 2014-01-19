//
//  TAUnitView.m
//  tacair
//
//  Created by John Bender on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TAUnitView.h"
#import "TAUnitViewController.h"

@implementation TAUnitView

@synthesize controller;
@synthesize highlightColor;


-(TAUnit*) unit
{
    return controller.unit;
}


-(void) setHighlightColor:(TAUnitHighlightColor)newColor
{
    if( newColor != highlightColor ) {
        if( !highlightView ) {
            highlightView = [[UIView alloc] initWithFrame:self.bounds];
            [self addSubview:highlightView];
        }

        highlightColor = newColor;
        highlightView.frame = CGRectMake( -self.frame.size.width/8.,
                                          -self.frame.size.height/8.,
                                          5.*self.frame.size.width/4.,
                                          5.*self.frame.size.height/4. );
        highlightView.layer.cornerRadius = 5.*self.frame.size.width/8.;
        highlightView.hidden = FALSE;

        switch( highlightColor ) {
            case TAUnitHighlightColorNone:
                highlightView.hidden = TRUE;
                break;
            case TAUnitHighlightColorPendingCombat:
                highlightView.backgroundColor = [UIColor colorWithRed:1. green:0. blue:0. alpha:0.33];
                break;
            case TAUnitHighlightColorPendingDamage:
                highlightView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:1. alpha:0.33];
                break;
        }
    }
}


-(void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [controller touchesBegan:touches withEvent:event];
}

-(void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [controller touchesMoved:touches withEvent:event];
}

-(void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [controller touchesEnded:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [controller touchesCancelled:touches withEvent:event];
}

@end
