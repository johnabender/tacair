//
//  TATeam.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TATeam.h"

@implementation TATeam

-(id) initWithSide:(TASide)side
{
    self = [super init];
    if( self ) {
        tanks = [NSMutableArray array];
        planes = [NSMutableArray array];
        
        if( side == TASideNATO ) {
            [tanks addObject:[[TATank alloc] initWithSide:side movingA:6 nonMovingA:5 movingB:5 nonMovingB:6 movementType:TAUnitMovementTypeTrack]];
            [tanks addObject:[[TATank alloc] initWithSide:side movingA:4 nonMovingA:3 movingB:7 nonMovingB:8 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:4 nonMovingA:3 movingB:7 nonMovingB:8 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:4 nonMovingA:3 movingB:7 nonMovingB:8 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:4 nonMovingA:0 movingB:4 nonMovingB:1 movementType:TAUnitMovementTypeHelicopter]];

//            [planes addObject:[[TAPlane alloc] initWithSide:side AFactor:4 BFactor:4 movementType:TAUnitMovementTypeFastAir]];
//            [planes addObject:[[TAPlane alloc] initWithSide:side AFactor:4 BFactor:4 movementType:TAUnitMovementTypeFastAir]];
//            [planes addObject:[[TAPlane alloc] initWithSide:side AFactor:2 BFactor:4 movementType:TAUnitMovementTypeSlowAir]];
        }
        else if( side == TASidePACT ) {
            [tanks addObject:[[TATank alloc] initWithSide:side movingA:8 nonMovingA:5 movingB:6 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
            [tanks addObject:[[TATank alloc] initWithSide:side movingA:5 nonMovingA:5 movingB:4 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
            [tanks addObject:[[TATank alloc] initWithSide:side movingA:3 nonMovingA:5 movingB:3 nonMovingB:5 movementType:TAUnitMovementTypeWheel]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:6 nonMovingA:5 movingB:5 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:6 nonMovingA:5 movingB:5 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:6 nonMovingA:5 movingB:5 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:3 nonMovingA:2 movingB:4 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:3 nonMovingA:2 movingB:4 nonMovingB:5 movementType:TAUnitMovementTypeTrack]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:3 nonMovingA:2 movingB:3 nonMovingB:2 movementType:TAUnitMovementTypeWheel]];
//            [tanks addObject:[[TATank alloc] initWithSide:side movingA:4 nonMovingA:0 movingB:3 nonMovingB:1 movementType:TAUnitMovementTypeHelicopter]];

//            [planes addObject:[[TAPlane alloc] initWithSide:side AFactor:3 BFactor:1 movementType:TAUnitMovementTypeFastAir]];
//            [planes addObject:[[TAPlane alloc] initWithSide:side AFactor:1 BFactor:3 movementType:TAUnitMovementTypeFastAir]];
        }
    }
    return self;
}


-(NSArray*) onboardTanks
{
    NSMutableArray *array = [NSMutableArray array];
    for( TATank* tank in tanks )
        if( [tank isPlaced] )
            [array addObject:tank];
    return array;
}


-(NSArray*) unplacedTanks
{
    NSMutableArray *array = [NSMutableArray array];
    for( TATank* tank in tanks )
        if( ![tank isPlaced] )
            [array addObject:tank];    
    return array;
}


-(NSArray*) offboardPlanes
{
    NSMutableArray *array = [NSMutableArray array];
    for( TAPlane *plane in planes )
        if( plane.location == nil )
            [array addObject:plane];
    return array;
}

@end
