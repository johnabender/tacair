//
//  TAUnit.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHex.h"
@class TAUnitViewController;

typedef enum {
    TAUnitFlipSideNonMoving=0,
    TAUnitFlipSideMoving=1
} TAUnitFlipSide;

typedef enum {
    TAUnitMovementTypeNone,
    TAUnitMovementTypeAny=TAUnitMovementTypeNone,
    TAUnitMovementTypeFoot,
    TAUnitMovementTypeWheel,
    TAUnitMovementTypeTrack,
    TAUnitMovementTypeHelicopter,
    TAUnitMovementTypeSlowAir,
    TAUnitMovementTypeFastAir
} TAUnitMovementType;

@interface TAUnit : NSObject
{
    NSInteger movingA;		/* moving A factor */
    NSInteger nonMovingA;	/* non-moving A factor */
    NSInteger movingB;		/* moving A factor */
    NSInteger nonMovingB;	/* non-moving B factor */

    TAUnitMovementType _movementType;

    TAUnitFlipSide faceDirection;
    CGFloat availMovePts;
}

@property (nonatomic, readonly) TASide team;
@property (nonatomic, readonly) NSInteger A;
@property (nonatomic, readonly) NSInteger B;
@property (nonatomic, readonly) TAUnitMovementType movementType;
@property (nonatomic, readonly) TAUnitFlipSide faceDirection;
@property (nonatomic, readonly) CGFloat availMovePts;

@property (nonatomic, assign) NSInteger disruptionLevels;
@property (nonatomic, assign) BOOL hasFired;

@property (nonatomic, weak) TAHex *location;
@property (nonatomic, weak) TAUnitViewController *viewController;
@property (nonatomic, weak) TAUnitViewController *duplicateViewController;

-(id) initWithSide:(TASide)side
           movingA:(NSInteger)mA
        nonMovingA:(NSInteger)nA 
           movingB:(NSInteger)mB 
        nonMovingB:(NSInteger)nB
      movementType:(TAUnitMovementType)mvType;

-(BOOL) isPlaced;
-(BOOL) isAirUnit;

-(CGFloat) baseMovementPoints;
-(void) resetMovementPoints;
-(void) zeroMovementPoints;
-(CGFloat) movementPointsToMoveFromHex:(TAHex*)fromHex toHex:(TAHex*)toHex;
-(void) moveToHex:(TAHex*)neighboringHex;

-(NSArray*) cheapestRouteTo:(TAHex*)hex;
-(CGFloat) movementCostForRoute:(NSArray*)route;
-(void) moveAlongRoute:(NSArray*)route;

-(BOOL) hasNeighboringEnemy;
-(BOOL) canAttack;

@end
