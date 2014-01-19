//
//  TACombat.m
//  tacair
//
//  Created by John Bender on 11/30/13.
//
//

#import "TACombat.h"
#import "TAUnit.h"
#import "TAGame.h"

@implementation TACombat

@synthesize defender;
@synthesize attackers;


-(id) initWithDefender:(TAUnit*)defender_
{
    self = [super init];
    if( self ) {
        defender = defender_;
    }
    return self;
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"\ndefender:\n\t%@\nattackers: %@\n", defender, attackers];
}


-(void) addAttacker:(TAUnit*)attacker
{
    NSMutableSet *a = [NSMutableSet setWithSet:self.attackers];
    [a addObject:attacker];
    attackers = [NSSet setWithSet:a];
}

-(void) removeAttacker:(TAUnit*)attacker
{
    if( [attackers containsObject:attacker] ) {
        NSMutableSet *a = [NSMutableSet setWithSet:self.attackers];
        [a removeObject:attacker];
        attackers = [NSSet setWithSet:a];
    }
}


-(NSInteger) differential
{
    NSInteger diff = -defender.B;

    NSInteger maxAttackerElev = 0;
    BOOL allAttackersCrossingRiver = TRUE;
    BOOL anyAttackersCrossingRiver = FALSE;
    BOOL attackContainsHelicopter = FALSE;

    for( TAUnit *attacker in attackers ) {
        diff += attacker.A;

        maxAttackerElev = MAX( maxAttackerElev, attacker.location.elev );

        TAHexDirection attackDirection = [attacker.location directionToNeighbor:defender.location];
        if( [attacker.location hasRiverCrossingInDirection:attackDirection] )
            anyAttackersCrossingRiver = TRUE;
        else
            allAttackersCrossingRiver = FALSE;

        if( attacker.movementType == TAUnitMovementTypeHelicopter )
            attackContainsHelicopter = TRUE;
    }

    if( !attackContainsHelicopter ) {
        diff -= MAX( 0, defender.location.elev - maxAttackerElev );

        if( anyAttackersCrossingRiver && allAttackersCrossingRiver )
            diff -= 1;
    }

    if( defender.location.terrain == TAHexTerrainUrban ||
        defender.location.terrain == TAHexTerrainWoods )
        diff -= 2;
    else if( defender.location.terrain == TAHexTerrainRocky )
        diff -= 1;

    return diff;
}


-(TADamageAllocation) resolve
{
    for( TAUnit *attacker in attackers )
        attacker.hasFired = TRUE;
    defender.hasFired = TRUE;

    NSInteger roll = [TAGame dieRoll];
    NSInteger diff = [self differential];

    switch( roll ) {
        case 0:
            if( diff <= -1 ) return TADamageAllocationD1;
            else if( diff <= 2 ) return TADamageAllocationD2;
            else if( diff <= 5 ) return TADamageAllocationD3;
            else return TADamageAllocationD4;
        case 1:
            if( diff <= -3 ) return TADamageAllocationB1;
            else if( diff <= 0 ) return TADamageAllocationD1;
            else if( diff <= 3 ) return TADamageAllocationD2;
            else if( diff <= 6 ) return TADamageAllocationD3;
            else return TADamageAllocationD4;
        case 2:
            if( diff <= -3 ) return TADamageAllocationA1;
            else if( diff <= -2 ) return TADamageAllocationB1;
            else if( diff <= 1 ) return TADamageAllocationD1;
            else if( diff <= 4 ) return TADamageAllocationD2;
            else if( diff <= 7 ) return TADamageAllocationD3;
            else return TADamageAllocationD4;
        case 3:
            if( diff <= -2 ) return TADamageAllocationA1;
            else if( diff <= -1 ) return TADamageAllocationB1;
            else if( diff <= 2 ) return TADamageAllocationD1;
            else if( diff <= 5 ) return TADamageAllocationD2;
            else return TADamageAllocationD3;
        case 4:
            if( diff <= -1 ) return TADamageAllocationA1;
            else if( diff <= 0 ) return TADamageAllocationB1;
            else if( diff <= 3 ) return TADamageAllocationD1;
            else if( diff <= 6 ) return TADamageAllocationD2;
            else return TADamageAllocationD3;
        case 5:
            if( diff <= 0 ) return TADamageAllocationA1;
            else if( diff <= 1 ) return TADamageAllocationB1;
            else if( diff <= 4 ) return TADamageAllocationD1;
            else if( diff <= 7 ) return TADamageAllocationD2;
            else return TADamageAllocationD3;
        default:
            return TADamageAllocationB1;
    }
}

@end
