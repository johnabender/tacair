//
//  TATank.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TATank.h"

@implementation TATank

#pragma mark - Flipping

-(NSInteger) movementPointsToFlip
{
    if( (self.team == TASideNATO && (self.location.zoc & TASidePACT)) ||
        (self.team == TASidePACT && (self.location.zoc & TASideNATO)) )
        return 2;
    return 1;
}


-(BOOL) hasMovementPointsToFlip
{
    if( self.availMovePts >= [self movementPointsToFlip] )
        return TRUE;
    return FALSE;
}


-(void) flip:(BOOL)deductPoints
{
    faceDirection = !faceDirection;
    if( deductPoints )
        availMovePts -= [self movementPointsToFlip];
}


-(BOOL) hasZoc
{
    return (self.disruptionLevels <= 1);
}

@end
