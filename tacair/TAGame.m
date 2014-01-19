//
//  TAGame.m
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAGame.h"
#import "TAGameViewController.h"
#import "TACombat.h"

@implementation TAGame

@synthesize board;
@synthesize phase;
@synthesize maneuverSubphase;
@synthesize phasingSide;


+(NSInteger) dieRoll
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand( [NSDate timeIntervalSinceReferenceDate] );
    });

    return (NSInteger)round( rand() ) % 6;
}


-(id) initWithController:(TAGameViewController*)viewController
{
    self = [super init];
    if( self ) {
        NATO = [[TATeam alloc] initWithSide:TASideNATO];
        PACT = [[TATeam alloc] initWithSide:TASidePACT];
        board = [[TABoard alloc] init];

#if DEBUG
        NSArray *natoTanks = [NATO unplacedTanks];
        if( [natoTanks count] >= 1 ) {
            TATank *tank = natoTanks[0];
            TAHex *hex = [board hexWithName:@"F3"];
            tank.location = hex;
            hex.groundUnit = tank;
        }
        if( [natoTanks count] >= 2 ) {
            TATank *tank = natoTanks[1];
            TAHex *hex = [board hexWithName:@"E2"];
            tank.location = hex;
            hex.groundUnit = tank;
        }

        NSArray *pactTanks = [PACT unplacedTanks];
        if( [pactTanks count] >= 1 ) {
            TATank *tank = pactTanks[0];
            TAHex *hex = [board hexWithName:@"F2"];
            tank.location = hex;
            hex.groundUnit = tank;
        }
        if( [pactTanks count] >= 2 ) {
            TATank *tank = pactTanks[1];
            TAHex *hex = [board hexWithName:@"G2"];
            tank.location = hex;
            hex.groundUnit = tank;
        }
        if( [pactTanks count] >= 3 ) {
            TATank *tank = pactTanks[2];
            TAHex *hex = [board hexWithName:@"D4"];
            tank.location = hex;
            hex.groundUnit = tank;
        }
#endif
        
        phase = TAGamePhaseSetup;
        if( [[NATO unplacedTanks] count] > 0 )
            phasingSide = TASideNATO;
        else {
            phasingSide = TASidePACT;
            if( [[PACT unplacedTanks] count] == 0 )
                [self advancePhase];
        }

        controller = viewController;
        [controller beginSetupWhenAvailable];
    }
    return self;
}


-(BOOL) canUnitBeFlipped:(TAUnit*)unit
{
    if( [unit isAirUnit] )
        return FALSE;
    if( unit.team != phasingSide )
        return FALSE;
    if( phase == TAGamePhaseCheck )
        return TRUE;
    if( phase == TAGamePhaseManeuver &&
        ![unit isAirUnit] &&
        [(TATank*)unit hasMovementPointsToFlip] )
        return TRUE;
    return FALSE;
}


-(BOOL) shouldUnitFlippingCostPoints
{
    return (phase == TAGamePhaseManeuver);
}


-(void) advancePhase
{
    phasingSide = TASidePACT;

    if( phase == TAGamePhaseSetup ) {
        phase = TAGamePhaseAirAllocation;
    }
    else {
        phase++;

        if( phase == TAGamePhaseManeuver || phase == TAGamePhaseAir )
            combats = [NSMutableArray new];
        else if( phase == TAGamePhaseEndTurn )
            // TODO: advance turn...
            ;

        if( phase == TAGamePhaseManeuver )
            maneuverSubphase = TAManeuverSubphaseMoving;
    }
}


-(TATeam*) teamForSide:(TASide)side
{
    if( side == TASidePACT )
        return PACT;
    return NATO;
}


-(void) getPhasingTeam:(TATeam**)phasingTeam nonphasingTeam:(TATeam**)nonphasingTeam
{
    if( phasingSide == TASidePACT ) {
        *phasingTeam = PACT;
        *nonphasingTeam = NATO;
    }
    else if( phasingSide == TASideNATO ) {
        *phasingTeam = NATO;
        *nonphasingTeam = PACT;
    }
    else {
        *phasingTeam = nil;
        *nonphasingTeam = nil;
    }
}


-(NSArray*) onboardTanks
{
    NSMutableArray *tanks = [NSMutableArray new];

    [tanks addObjectsFromArray:[PACT onboardTanks]];
    [tanks addObjectsFromArray:[NATO onboardTanks]];

    return [NSArray arrayWithArray:tanks];
}


-(NSArray*) unplacedTanksForSide:(TASide)side
{
    if( side == TASideNATO )
        return [NATO unplacedTanks];
    else
        return [PACT unplacedTanks];
}


-(void) sideFinishedPlacingTanks:(TASide)side
{
    if( side == TASideNATO )
        phasingSide = TASidePACT;
    else
        [self advancePhase];
}


-(NSArray*) offboardPlanesForSide:(TASide)side
{
    if( side == TASideNATO )
        return [NATO offboardPlanes];
    else
        return [PACT offboardPlanes];
}


-(void) sideFinishedAirAllocation:(TASide)side
{
    if( side == TASidePACT )
        phasingSide = TASideNATO;
    else
        [self advancePhase];
}


-(void) sideFinishedCheckPhase:(TASide)side
{
    if( side == TASidePACT )
        phasingSide = TASideNATO;
    else
        [self advancePhase];
}


#pragma mark - Maneuver phase (combats)

-(void) sideFinishedMoving:(TASide)side
{
    maneuverSubphase = TAManeuverSubphaseCombat;
    
    for( TATank *tank in [[self teamForSide:side] onboardTanks] )
        [tank zeroMovementPoints];

    [self determineValidCombatPatterns];
}


-(NSMutableArray*) copyCombatsFrom:(NSArray*)combatArray
{
    NSMutableArray *newCombats = [NSMutableArray new];
    for( TACombat *combat in combatArray ) {
        TACombat *copy = [[TACombat alloc] initWithDefender:combat.defender];
        for( TATank *a in combat.attackers )
            [copy addAttacker:a];
        [newCombats addObject:copy];
    }
    return newCombats;
}


-(void) addValidPatternsWithAttackers:(NSArray*)attackers
                            toPattern:(NSArray*)currentPattern
                     withStorageArray:(NSMutableArray*)patterns
{
    if( [attackers count] == 0 ) return;
    TATank *attacker = attackers[0];

    if( ![attacker canAttack] ) {
        NSMutableArray *newAttackers = [NSMutableArray arrayWithArray:attackers];
        [newAttackers removeObject:attacker];
        [self addValidPatternsWithAttackers:newAttackers toPattern:currentPattern withStorageArray:patterns];
        return;
    }

    //DLog( @"adding from %@ to %@", attackers, currentPattern );

    for( TAHexDirection direction = 0; direction < 6; direction++ ) {
        TAHex *neighboringHex = [attacker.location neighborInDirection:direction];
        if( neighboringHex.groundUnit && neighboringHex.groundUnit.team != attacker.team ) {

            // add attacker or new combat to pattern copy
            NSMutableArray *newPattern = [self copyCombatsFrom:currentPattern];
            BOOL new = TRUE;
            for( TACombat *combat in newPattern )
                if( combat.defender == neighboringHex.groundUnit ) {
                    [combat addAttacker:attacker];
                    new = FALSE;
                    break;
                }

            if( new ) {
                TACombat *combat = [[TACombat alloc] initWithDefender:neighboringHex.groundUnit];
                [combat addAttacker:attacker];
                [newPattern addObject:combat];
            }

            [patterns addObject:newPattern];

            // recurse
            NSMutableArray *newAttackers = [NSMutableArray arrayWithArray:attackers];
            [newAttackers removeObject:attacker];
            [self addValidPatternsWithAttackers:newAttackers toPattern:newPattern withStorageArray:patterns];
        }
    }
}


-(NSInteger) countZOCAttacksIn:(NSArray*)combatPattern
{
    NSInteger currentZOCAttacks = 0;
    for( TACombat *combat in combatPattern )
        if( [(TATank*)combat.defender hasZoc] )
            currentZOCAttacks++;

    return currentZOCAttacks;
}


-(NSInteger) countMaxZOCAttacksWithAttackers:(NSArray*)attackers andAttacks:(NSArray*)attacks
{
    NSMutableArray *allPatterns = [NSMutableArray new];
    [self addValidPatternsWithAttackers:attackers
                              toPattern:attacks
                       withStorageArray:allPatterns];

    NSInteger maxZOCAttacks = 0;
    for( NSArray *pattern in allPatterns ) {
        NSMutableArray *newPattern = [self copyCombatsFrom:pattern];
        for( TACombat *oldAttack in attacks ) {
            TACombat *newAttack = [self combatForDefender:oldAttack.defender inArray:newPattern];
            if( newAttack )
                [newPattern removeObject:newAttack];
        }

        maxZOCAttacks = MAX( maxZOCAttacks, [self countZOCAttacksIn:newPattern] );
    }

    DLog( @"with attackers %@, %d new ZOC attacks in %@", attackers, maxZOCAttacks, allPatterns );

    return maxZOCAttacks;
}


-(void) determineValidCombatPatterns
{
    TATeam *phasingTeam;
    TATeam *nonphasingTeam;
    [self getPhasingTeam:&phasingTeam nonphasingTeam:&nonphasingTeam];

    requiredZOCAttacks = [self countMaxZOCAttacksWithAttackers:[phasingTeam onboardTanks]
                                                    andAttacks:@[]];
}


-(BOOL) sideHasOutstandingManeuverCombats:(TASide)side
{
    TATeam *team = PACT;
    TASide zocCheck = TASideNATO;
    if( side == TASideNATO ) {
        team = NATO;
        zocCheck = TASidePACT;
    }

    for( TATank *tank in [team onboardTanks] )
        if( [tank canAttack] && (tank.location.zoc & zocCheck) ) {
            DLog( @"%@", tank );
            return TRUE;
        }

    return FALSE;
}


-(NSArray*) unitsWithPossibleManeuverCombats
{
    TATeam *phasingTeam = PACT;
    TASide phasingZoc = TASidePACT;
    TATeam *nonphasingTeam = NATO;
    TASide nonphasingZoc = TASideNATO;
    if( phasingSide == TASideNATO ) {
        phasingTeam = NATO;
        phasingZoc = TASideNATO;
        nonphasingTeam = PACT;
        nonphasingZoc = TASidePACT;
    }

    NSMutableSet *combatUnits = [NSMutableSet new];

    for( TATank *nonphasingTank in [nonphasingTeam onboardTanks] )
        if( [nonphasingTank hasZoc] && (nonphasingTank.location.zoc & phasingZoc) )
            [combatUnits addObject:nonphasingTank];

    for( TATank *phasingTank in [phasingTeam onboardTanks] )
        if( [phasingTank canAttack] )
            for( TAHexDirection direction = 0; direction < 6; direction++ ) {
                TAHex *neighboringHex = [phasingTank.location neighborInDirection:direction];
                if( neighboringHex.groundUnit && neighboringHex.groundUnit.team == nonphasingZoc ) {
                    [combatUnits addObject:phasingTank];
                    [combatUnits addObject:neighboringHex.groundUnit];
                }
            }

    return [NSArray arrayWithArray:[combatUnits allObjects]];
}


-(TACombat*) combatForDefender:(TAUnit*)defender inArray:(NSArray*)combatArray
{
    for( TACombat *combat in combatArray )
        if( combat.defender == defender )
            return combat;
    return nil;
}

-(TACombat*) combatForDefender:(TAUnit*)defender
{
    return [self combatForDefender:defender inArray:combats];
}


-(TACombat*) combatForAttacker:(TAUnit*)attacker inArray:(NSArray*)combatArray
{
    for( TACombat *combat in combatArray )
        if( [combat.attackers containsObject:attacker] )
            return combat;
    return nil;
}

-(TACombat*) combatForAttacker:(TAUnit*)attacker
{
    return [self combatForAttacker:attacker inArray:combats];
}


-(BOOL) canAddUnit:(TAUnit*)unit toAttackOn:(TAUnit*)defender
{
    // bug: if unit is currently in an attack, have to remove it before answering
    // bug: if an attack has been resolved, its defender doesn't need to be attacked
    
    //DLog( @"%x %d %d %d", defender, [unit canAttack], unit.team == defender.team, [defender.location isNeighborTo:unit.location] );
    if( defender == nil ) return FALSE;
    if( ![unit canAttack] ) return FALSE;
    if( unit.team == defender.team ) return FALSE;
    if( defender.hasFired ) return FALSE;
    if( ![defender.location isNeighborTo:unit.location] ) return FALSE;

    NSMutableArray *newCombats = [self copyCombatsFrom:combats];

    // remove attacker from any combat
    TACombat *combatForAttacker = [self combatForAttacker:unit inArray:newCombats];
    if( combatForAttacker && [combatForAttacker.attackers count] == 1 ) {
        TACombat *newCombat = [[TACombat alloc] initWithDefender:combatForAttacker.defender];
        for( TAUnit *attacker in combatForAttacker.attackers )
            if( attacker != unit )
                [newCombat addAttacker:attacker];
        [newCombats replaceObjectAtIndex:[newCombats indexOfObject:combatForAttacker] withObject:newCombat];
    }

    // add attacker to requested combat
    TACombat *combatForDefender = [self combatForDefender:defender inArray:newCombats];
    if( combatForDefender )
        [combatForDefender addAttacker:unit];
    else {
        TACombat *newCombat = [[TACombat alloc] initWithDefender:defender];
        [newCombat addAttacker:unit];
        [newCombats addObject:newCombat];
    }

    // find all possible remaining attackers
    NSMutableArray *possibleAttackers = [NSMutableArray arrayWithArray:[[self teamForSide:unit.team] onboardTanks]];
    for( TACombat *combat in newCombats )
        for( TAUnit *attacker in combat.attackers )
            if( [possibleAttackers containsObject:attacker] )
                [possibleAttackers removeObject:attacker];

    // see if attacks with remaining attackers can still make the required attacks
    NSInteger currentZOCAttacks = [self countZOCAttacksIn:newCombats];
    NSInteger possibleMax = [self countMaxZOCAttacksWithAttackers:possibleAttackers
                                                       andAttacks:newCombats];
    DLog( @"current (with requested): %d; max new with remaining: %d; required: %d", currentZOCAttacks, possibleMax, requiredZOCAttacks );
    if( possibleMax + currentZOCAttacks < requiredZOCAttacks )
        return FALSE;

    return TRUE;
}


-(void) addUnit:(TAUnit*)attacker toAttackOn:(TAUnit*)defender
{
    // remove from old attack
    TACombat *combatForAttacker = [self combatForAttacker:attacker];
    if( [combatForAttacker.attackers count] == 1 )
        [combats removeObject:combatForAttacker];
    else
        [combatForAttacker removeAttacker:attacker];

    // add to new attack
    TACombat *combat = [self combatForDefender:defender];
    if( combat == nil ) {
        combat = [[TACombat alloc] initWithDefender:defender];
        [combats addObject:combat];
    }
    [combat addAttacker:attacker];
}


-(void) deleteCombat:(TACombat*)combat
{
    if( [combats containsObject:combat] )
        [combats removeObject:combat];
}


-(void) destroyUnit:(TAUnit*)unit
{
}


-(void) sideFinishedManeuverPhase:(TASide)side
{
    if( ![self sideHasOutstandingManeuverCombats:side] ) {
        if( side == TASidePACT ) {
            phasingSide = TASideNATO;
            maneuverSubphase = TAManeuverSubphaseMoving;
        }
        else
            [self advancePhase];
    }
}

@end
