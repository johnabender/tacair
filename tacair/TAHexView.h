//
//  TAHexView.h
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAHex.h"

typedef enum {
    TAHexHighlightColorNone       = 0,
    TAHexHighlightColorHighlight  = 1 << 0,
    TAHexHighlightColorAvailable  = 1 << 1,
    TAHexHighlightColorInRange    = 1 << 2,
    TAHexHighlightColorSpecific   = 1 << 3,
} TAHexHighlightColor;

static const CGFloat kHexLineWidth = 1.;

@interface TAHexView : UIView
{
    UIBezierPath *border;
    UIBezierPath *riverPath;
    UIBezierPath *roadPath;
    UIBezierPath *countryBorderPath;
    UIImageView *terrainImageView;
    CGFloat terrainRotationAngle;
    
    UIImage *hexImage;
    UIImageView *hexImageView;
    NSOperationQueue *drawQueue;
}

@property (nonatomic, strong) TAHex *hex;
@property (nonatomic, assign) TAHexHighlightColor highlightColor;
@property (nonatomic, strong) UIColor *specifiedHighlightColor;

// this is used by board view controller during route display
@property (nonatomic, assign) CGFloat tempPtsValue;

-(id) initWithHex:(TAHex*)myHex;

-(void) addRoads;

@end
