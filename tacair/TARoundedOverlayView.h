//
//  TATankPlacementView.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAArrowView;
@class TAHandleView;

@interface TARoundedOverlayView : UIView
{
    UIColor *defaultColor;
    UIColor *highlightColor;

    TAArrowView *arrowView;
    TAHandleView *handleView;
}

@property (nonatomic, assign) BOOL highlighted;

-(void) showHandle:(BOOL)showHandle;

-(void) drawArrowToPoint:(CGPoint)point;

@end
