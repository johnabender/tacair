//
//  TAGame.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TATeam.h"
#import "TABoard.h"
#import "TACombat.h"
@class TAGameViewController;

typedef enum {
    TAGamePhaseSetup,
    TAGamePhaseDisruptionRemoval,
    TAGamePhaseAirAllocation,
    TAGamePhaseCheck,
    TAGamePhaseManeuver,
    TAGamePhaseAir,
    TAGamePhaseEndTurn
} TAGamePhase;

typedef enum {
    TAManeuverSubphaseMoving,
    TAManeuverSubphaseCombat
} TAManeuverSubphase;

@interface TAGame : NSObject
{
    TATeam *NATO;
    TATeam *PACT;
    
    __weak TAGameViewController *controller;

    NSMutableArray *combats;
    NSInteger requiredZOCAttacks;
}

@property (nonatomic, readonly) TABoard *board;
@property (nonatomic, readonly) TAGamePhase phase;
@property (nonatomic, readonly) TAManeuverSubphase maneuverSubphase;
@property (nonatomic, readonly) TASide phasingSide;

+(NSInteger) dieRoll;

-(id) initWithController:(TAGameViewController*)viewController;

-(BOOL) canUnitBeFlipped:(TAUnit*)unit;
-(BOOL) shouldUnitFlippingCostPoints;

-(NSArray*) onboardTanks;

-(NSArray*) unplacedTanksForSide:(TASide)side;
-(void) sideFinishedPlacingTanks:(TASide)side;

-(NSArray*) offboardPlanesForSide:(TASide)side;
-(void) sideFinishedAirAllocation:(TASide)side;

-(void) sideFinishedCheckPhase:(TASide)side;

-(void) sideFinishedMoving:(TASide)side;
-(BOOL) sideHasOutstandingManeuverCombats:(TASide)side;
-(NSArray*) unitsWithPossibleManeuverCombats;

-(TACombat*) combatForDefender:(TAUnit*)defender;
-(TACombat*) combatForAttacker:(TAUnit*)attacker;
-(BOOL) canAddUnit:(TAUnit*)unit toAttackOn:(TAUnit*)defender;
-(void) addUnit:(TAUnit*)attacker toAttackOn:(TAUnit*)defender;
-(void) deleteCombat:(TACombat*)combat;
-(void) destroyUnit:(TAUnit*)unit;
-(void) sideFinishedManeuverPhase:(TASide)side;

@end
