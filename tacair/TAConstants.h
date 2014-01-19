//
//  TAConstants.h
//  tacair
//
//  Created by John Bender on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef tacair_TAConstants_h
#define tacair_TAConstants_h

typedef enum {
    TASideNone=0,
    TASideNATO=1,
    TASidePACT=2,
    TASideBoth=(TASideNATO & TASidePACT)
} TASide;

static const CGFloat kHexWidth = 100.;
#define kHexHeight (sqrtf(3.)*kHexWidth/2.)

static const CGFloat layoutMargin = 20.;

#endif
