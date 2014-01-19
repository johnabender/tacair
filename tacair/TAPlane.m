//
//  TAPlane.m
//  tacair
//
//  Created by John Bender on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPlane.h"

@implementation TAPlane

@synthesize readiness;
@synthesize orders;

-(id) initWithSide:(TASide)side
           AFactor:(NSInteger)a
           BFactor:(NSInteger)b
      movementType:(TAUnitMovementType)mvType
{
    self = [super initWithSide:side movingA:a nonMovingA:b movingB:b nonMovingB:b movementType:mvType];
    if( self ) {
        readiness = TAPlaneStateReady;
    }
    return self;
}


-(BOOL) isAirUnit
{
    return YES;
}


@end
