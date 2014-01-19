//
//  TABoardViewController.h
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TABoard.h"
#import "TAHexView.h"
@class TAViewController;


@interface TABoardViewController : UIViewController
{
    TAViewController *mainVC;
}

@property (nonatomic, readonly) TABoard *board;

-(id) initWithBoard:(TABoard*)initBoard controller:(TAViewController*)mainViewController;

-(TAHex*) hexAtPoint:(CGPoint)point;

-(void) highlightHex:(TAHex*)hex color:(TAHexHighlightColor)color;
-(void) highlightHexesAround:(TAHex*)hex
                       range:(NSInteger)range
                     country:(TACountry)country
                       color:(TAHexHighlightColor)color;
-(void) highlightHexesAroundHexNamed:(NSString*)name
                               range:(NSInteger)range 
                             country:(TACountry)country
                               color:(TAHexHighlightColor)color;

-(void) stopHighlightingHexes;
-(void) stopHighlightingHexesOfColor:(TAHexHighlightColor)color;

-(void) scrollHexOntoScreen:(TAHex*)hex;

-(void) drawUnit:(TAUnit*)unit;

-(void) doMovementOverlayForUnit:(TAUnit*)unit;

-(void) highlightPossibleAttacksForUnit:(TAUnit*)unit;

@end
