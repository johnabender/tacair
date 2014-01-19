//
//  TAUnitView.h
//  tacair
//
//  Created by John Bender on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TAUnit;
@class TAUnitViewController;


typedef enum {
    TAUnitHighlightColorNone,
    TAUnitHighlightColorPendingCombat,
    TAUnitHighlightColorPendingDamage
} TAUnitHighlightColor;


@interface TAUnitView : UIView
{
    UIView *highlightView;
}

@property (nonatomic, strong) IBOutlet TAUnitViewController *controller;
@property (nonatomic, readonly) TAUnit *unit;

@property (nonatomic, assign) TAUnitHighlightColor highlightColor;

@end
