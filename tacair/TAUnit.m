//
//  TAUnit.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUnit.h"
#import "TAUnitViewController.h"
#import "TAGameViewController.h"

@implementation TAUnit

@synthesize team;
@synthesize disruptionLevels;
@synthesize hasFired;
@synthesize faceDirection;
@synthesize availMovePts;
@synthesize location;
@synthesize viewController;
@synthesize duplicateViewController;


-(NSString*) description
{
    return [NSString stringWithFormat:@"%@ %d%@%d (side %d) mv. %.1f dis. %d (fired %d), [%@]",
            team == TASideNATO ? @"NATO" : team == TASidePACT ? @"PACT" : @"??",
            self.A, [TAUnitViewController stringForMovementType:self.movementType], self.B,
            self.faceDirection, self.availMovePts, self.disruptionLevels, self.hasFired, self.location];
}


#pragma mark - properties

-(NSInteger) A
{
    if( faceDirection == TAUnitFlipSideMoving )
        return movingA;
    return nonMovingA;
}

-(NSInteger) B
{
    if( faceDirection == TAUnitFlipSideMoving )
        return movingB;
    return nonMovingB;
}

-(TAUnitMovementType) movementType
{
    if( faceDirection == TAUnitFlipSideMoving )
        return _movementType;
    return TAUnitMovementTypeNone;
}


#pragma mark - Initialization

-(id) initWithSide:(TASide)side
           movingA:(NSInteger)mA
        nonMovingA:(NSInteger)nA 
           movingB:(NSInteger)mB 
        nonMovingB:(NSInteger)nB
      movementType:(TAUnitMovementType)mvType
{
    self = [super init];
    if( self ) {
        team = side;
        movingA = mA;
        nonMovingA = nA;
        movingB = mB;
        nonMovingB = nB;
        _movementType = mvType;
        
        faceDirection = TAUnitFlipSideMoving;
        [self resetMovementPoints];
    }
    return self;
}


#pragma mark - General queries

-(BOOL) isPlaced
{
    return !(location == nil && disruptionLevels == 0);
}


-(BOOL) isAirUnit
{
    return NO;
}


#pragma mark - Moving

-(CGFloat) baseMovementPoints
{
    switch( _movementType ) {
        case TAUnitMovementTypeFoot:
            return 1.;
        case TAUnitMovementTypeWheel:
            return 4.;
        case TAUnitMovementTypeTrack:
            return 6.;
        case TAUnitMovementTypeHelicopter:
            return 10.;
        case TAUnitMovementTypeSlowAir:
            return 6.;
        case TAUnitMovementTypeFastAir:
            return 10.;
        default:
            return 0.;
    }
}


-(void) resetMovementPoints
{
    availMovePts = [self baseMovementPoints];
}


-(void) zeroMovementPoints
{
    availMovePts = 0;
}


-(CGFloat) costToEnterTerrainType:(TAHexTerrain)terrain
{
    if( [self isAirUnit] )
        return 1.;
    if( _movementType == TAUnitMovementTypeHelicopter )
        return 1.;
    
    switch( terrain ) {
        case TAHexTerrainClear:
            return 1.;
        case TAHexTerrainWoods:
            return 2.;
        case TAHexTerrainRocky:
            return 3.;
        case TAHexTerrainUrban:
            return 1.;
        case TAHexTerrainLake:
        default:
            return FLT_MAX;
    }
}


-(CGFloat) movementPointsToMoveFromHex:(TAHex*)fromHex toHex:(TAHex*)toHex
{
    if( ![fromHex isNeighborTo:toHex] )
        return FLT_MAX;

    TAHexDirection direction = [fromHex directionToNeighbor:toHex];
    if( direction == TAHexDirectionNone )
        return FLT_MAX;

    if( ![self isAirUnit] && toHex.groundUnit )
        return FLT_MAX;
    
    // air unit or foot unit -- always 1
    if( [self isAirUnit] )
        return 1.;
    
    if( _movementType == TAUnitMovementTypeFoot )
        return 1.;

    // base cost for terrain or road
    CGFloat cost;
    if( [fromHex hasRoadInDirection:direction] ) {
        if( _movementType == TAUnitMovementTypeWheel )
            cost = 0.5;
        else
            cost = 1.;
    }
    else
        cost = [self costToEnterTerrainType:toHex.terrain];

    // adjust for ZOC
    if( (team == TASideNATO && (fromHex.zoc & TASidePACT)) ||
        (team == TASidePACT && (fromHex.zoc & TASideNATO)) )
        cost += 1.;
    if( (team == TASideNATO && (toHex.zoc & TASidePACT)) ||
        (team == TASidePACT && (toHex.zoc & TASideNATO)) )
        cost += 1.;
    
    if( _movementType == TAUnitMovementTypeHelicopter )
        return cost;

    // adjust for elevation difference
    if( fromHex.elev < toHex.elev && ![fromHex hasRoadInDirection:direction] )
        cost += (toHex.elev - fromHex.elev);
    
    // adjust for river crossing
    if( [fromHex hasRiverCrossingInDirection:direction] ) {
        if( [fromHex hasRoadInDirection:direction] )
            cost += 1.;
        else
            cost *= 2.;
    }
    
    return cost;
}


-(void) moveToHex:(TAHex*)neighboringHex
{
    CGFloat cost = [self movementPointsToMoveFromHex:location toHex:neighboringHex];
    if( cost <= availMovePts && neighboringHex.groundUnit == nil ) {
        availMovePts -= cost;
        if( ![self isAirUnit] ) {
            location.groundUnit = nil;
            neighboringHex.groundUnit = self;
        }
        location = neighboringHex;
    }
}


#pragma mark - Routing

-(void) fillRoutesFrom:(TAHex*)hex remainingMovementPoints:(CGFloat)ptsRemaining
{
    //DLog( @"pts remaining to %@ %x: %.1f", hex, hex, ptsRemaining );
    hex.dist = ptsRemaining;

    for( TAHexDirection direction = 0; direction < 6; direction++ ) {
        TAHex *neighbor = [hex neighborInDirection:direction];
        if( neighbor != nil ) {
            CGFloat cost = [self movementPointsToMoveFromHex:hex toHex:neighbor];
            //NSLog( @"cost to move to %@: %.1f (remaining %.1f) prev. best %.1f", neighbor.name, cost, ptsRemaining, neighbor.dist );
            if( cost <= ptsRemaining && neighbor.dist < ptsRemaining - cost ) {
                [self fillRoutesFrom:neighbor remainingMovementPoints:ptsRemaining - cost];
            }
        }
    }
}

-(NSArray*) cheapestRouteTo:(TAHex*)hex
{
    [[TAGameViewController gameVC].boardVC.board resetDistances];
    [self fillRoutesFrom:self.location remainingMovementPoints:availMovePts];

    //DLog( @"pts remaining for move to %@ %x: %.1f", hex, hex, hex.dist );
    if( hex.dist < 0. ) return nil;

    NSMutableArray *reverseRoute = [NSMutableArray arrayWithObject:hex];
    TAHex *currentHex = hex;
    while( currentHex != self.location ) {
        CGFloat highCost = -1.;
        TAHexDirection highDirection = 7;
        for( TAHexDirection direction = 0; direction < 6; direction++ ) {
            TAHex *neighbor = [currentHex neighborInDirection:direction];
            if( neighbor.dist > highCost ) {
                highCost = neighbor.dist;
                highDirection = direction;
            }
        }
        assert( highCost > -1. );
        currentHex = [currentHex neighborInDirection:highDirection];
        [reverseRoute addObject:currentHex];
    }

    //DLog( @"best route: %@", reverseRoute );
    return [[reverseRoute reverseObjectEnumerator] allObjects];
}

-(CGFloat) movementCostForRoute:(NSArray*)route
{
    if( route == nil ) return FLT_MAX;

    CGFloat cost = 0.;
    for( NSInteger i = 1; i < [route count]; i++ )
        cost += [self movementPointsToMoveFromHex:route[i - 1] toHex:route[i]];
    return cost;
}

-(void) moveAlongRoute:(NSArray*)route
{
    DLog( @"chosen route: %@", route );
    assert( route[0] == self.location );
    for( NSInteger i = 1; i < [route count]; i++ )
        [self moveToHex:route[i]];
    DLog( @"points remaining: %.1f", self.availMovePts );
}


-(BOOL) hasNeighboringEnemy
{
    for( TAHexDirection direction = 0; direction < 6; direction++ ) {
        TAHex *neighboringHex = [self.location neighborInDirection:direction];
        if( neighboringHex.groundUnit && neighboringHex.groundUnit.team != self.team )
            return TRUE;
    }

    return FALSE;
}


-(BOOL) canAttack
{
    return (!self.hasFired && self.disruptionLevels == 0 && self.A > 0);
}

@end
