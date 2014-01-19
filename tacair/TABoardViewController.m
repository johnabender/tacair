//
//  TABoardViewController.m
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TABoardViewController.h"
#import "TAViewController.h"
#import "TAUnitViewController.h"


@implementation TABoardViewController

@synthesize board;

-(id) initWithBoard:(TABoard*)initBoard controller:(TAViewController*)mainViewController
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        board = initBoard;
        mainVC = mainViewController;
        
        static const CGFloat margin = 20.;
        CGFloat maxX = 0., maxY = 0.;
        for( NSInteger col = 0; col < [board numberOfColumns]; col++ ) {
            for( NSInteger row = 0; row < [board numberOfRowsInColumn:col]; row++ ) {
                TAHex *hex = [board hexAtIndex:CGPointMake( col, row )];
                TAHexView *hexView = [[TAHexView alloc] initWithHex:hex];
                
                CGRect hexFrame = hexView.frame;
                hexFrame.origin.x = col*(0.75*kHexWidth + 0.5*kHexLineWidth) + margin;
                hexFrame.origin.y = row*(kHexHeight + 0.5*kHexLineWidth) + (1 - (col % 2))*0.5*kHexHeight + 2.*margin;
                hexView.frame = hexFrame;
                
                maxX = MAX( maxX, hexFrame.origin.x + hexFrame.size.width );
                maxY = MAX( maxY, hexFrame.origin.y + hexFrame.size.height );
                
                [self.view addSubview:hexView];
            }
        }
        
        for( NSInteger col = 0; col < [board numberOfColumns]; col++ )
            for( NSInteger row = 0; row < [board numberOfRowsInColumn:col]; row++ )
                [[board hexAtIndex:CGPointMake( col, row )].viewer addRoads];
        
        self.view.frame = CGRectMake( 0., 0., maxX, maxY );
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


-(TAHex*) hexAtPoint:(CGPoint)point
{
    for( NSInteger col = 0; col < [board numberOfColumns]; col++ )
        for( NSInteger row = 0; row < [board numberOfRowsInColumn:col]; row++ ) {
            TAHex *hex = [board hexAtIndex:CGPointMake( col, row )];
            CGPoint testPoint = [self.view.superview convertPoint:point toView:hex.viewer];
            if( [hex.viewer pointInside:testPoint withEvent:nil] ) {
                //DLog( @"returning %@ for %@", [hex name], NSStringFromCGPoint( point ) );
                return hex;
            }
        }
    return nil;
}


-(void) highlightHex:(TAHex*)hex color:(TAHexHighlightColor)color
{
    if( color == TAHexHighlightColorNone )
        hex.viewer.highlightColor = color;
    else if( (color & TAHexHighlightColorAvailable) ||
             (hex.viewer.highlightColor & TAHexHighlightColorAvailable) ) {
        hex.viewer.highlightColor |= color;
    }
    else
        hex.viewer.highlightColor = color;
    
    if( color & TAHexHighlightColorHighlight )
        [self scrollHexOntoScreen:hex];
}


-(void) highlightHexesAround:(TAHex*)hex
                       range:(NSInteger)range
                     country:(TACountry)country
                       color:(TAHexHighlightColor)color
{
    NSSet *hexes = [hex hexesInRange:range];
    for( TAHex *neighbor in hexes )
        if( country == TACountryEither || neighbor.country == country )
            [self highlightHex:neighbor color:color];
    [self highlightHex:hex color:color];
}


-(void) highlightHexesAroundHexNamed:(NSString*)name
                               range:(NSInteger)range 
                             country:(TACountry)country
                               color:(TAHexHighlightColor)color
{
    TAHex *hex = [board hexWithName:name];
    [self highlightHexesAround:hex range:range country:country color:color];
}


-(void) stopHighlightingHexes
{
    for( NSInteger col = 0; col < [board numberOfColumns]; col++ )
        for( NSInteger row = 0; row < [board numberOfRowsInColumn:col]; row++ ) {
            TAHex *hex = [board hexAtIndex:CGPointMake( col, row )];
            [self highlightHex:hex color:TAHexHighlightColorNone];
            hex.viewer.tempPtsValue = 0.;
        }
}


-(void) stopHighlightingHexesOfColor:(TAHexHighlightColor)color
{
    for( NSInteger col = 0; col < [board numberOfColumns]; col++ )
        for( NSInteger row = 0; row < [board numberOfRowsInColumn:col]; row++ ) {
            TAHex *hex = [board hexAtIndex:CGPointMake( col, row )];
            // this logic probably doesn't work if "color" has multiple bits set
            if( hex.viewer.highlightColor & color ) {
                hex.viewer.highlightColor = hex.viewer.highlightColor ^ color;

                if( color & TAHexHighlightColorSpecific )
                    hex.viewer.tempPtsValue = 0.;
            }
        }
}


-(void) scrollHexOntoScreen:(TAHex*)hex
{
    [mainVC scrollHexViewOntoScreen:hex.viewer];
}


-(void) drawUnit:(TAUnit*)unit
{
    [self.view addSubview:unit.viewController.view];
    unit.viewController.view.center = CGPointMake( unit.location.viewer.center.x,
                                                   unit.location.viewer.center.y + 4. );
    unit.location.viewer.highlightColor = TAHexHighlightColorNone;
}


-(void)    highlightHex:(TAHex*)hex 
 inMovementColorForUnit:(TAUnit*)unit
remainingMovementPoints:(CGFloat)ptsRemaining
{
    CGFloat ptFrac = ptsRemaining/unit.availMovePts;
    hex.viewer.tempPtsValue = ptsRemaining;
    hex.viewer.specifiedHighlightColor = [UIColor colorWithRed:1. green:0.5 blue:0. alpha:0.6*ptFrac + 0.25];
    hex.viewer.highlightColor = TAHexHighlightColorSpecific;
    for( TAHexDirection direction = 0; direction < 6; direction++ ) {
        TAHex *neighbor = [hex neighborInDirection:direction];
        if( neighbor != nil && neighbor.viewer.tempPtsValue < ptsRemaining ) {
            CGFloat cost = [unit movementPointsToMoveFromHex:hex toHex:neighbor];
            if( cost <= ptsRemaining ) {
                [self highlightHex:neighbor 
            inMovementColorForUnit:unit
           remainingMovementPoints:ptsRemaining - cost];
            }
        }
    }
}


-(void) doMovementOverlayForUnit:(TAUnit*)unit
{
    [self highlightHex:unit.location inMovementColorForUnit:unit remainingMovementPoints:unit.availMovePts];
}


-(void) highlightPossibleAttacksForUnit:(TAUnit*)unit
{
    for( TAHexDirection direction = 0; direction < 6; direction++ ) {
        TAHex *hex = [unit.location neighborInDirection:direction];
        if( hex.groundUnit && hex.groundUnit.team != unit.team )
            [self highlightHex:hex color:TAHexHighlightColorInRange];
    }
}

@end
