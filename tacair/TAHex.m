//
//  TAHex.m
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAHex.h"
#import "TAUnit.h"

@implementation TAHex

@synthesize elev, terrain;
@synthesize row, col, colString;
@synthesize roadString, riverString;
@synthesize country;//, zoc, unit, plane, dist;

@synthesize viewer;
@synthesize groundUnit, airUnits;

-(id) init
{
    self = [super init];
    if( self ) {
        _neighbors = [[NSMutableArray alloc] initWithCapacity:6];
        _roads = [[NSMutableArray alloc] initWithCapacity:6];
        _rivers = [[NSMutableArray alloc] initWithCapacity:6];
        _borders = [[NSMutableArray alloc] initWithCapacity:6];
        for( NSInteger i = 0; i < 6; i++ ) {
            [_neighbors addObject:[NSNumber numberWithInt:0]];
            [_rivers addObject:[NSNumber numberWithBool:NO]];
            [_roads addObject:[NSNumber numberWithBool:NO]];
            [_borders addObject:[NSNumber numberWithBool:NO]];
        }
    }
    return self;
}


#pragma mark - Initializing neighbors

-(void) makeNeighbor:(TAHex*)newNeighbor inDirection:(TAHexDirection)direction
{
    [_neighbors replaceObjectAtIndex:direction withObject:newNeighbor];
}

-(void) makeRiverInDirection:(TAHexDirection)direction
{
    [_rivers replaceObjectAtIndex:direction withObject:[NSNumber numberWithBool:YES]];
}

-(void) makeRoadInDirection:(TAHexDirection)direction
{
    [_roads replaceObjectAtIndex:direction withObject:[NSNumber numberWithBool:YES]];
}

-(void) makeBorderInDirection:(TAHexDirection)direction
{
    [_borders replaceObjectAtIndex:direction withObject:[NSNumber numberWithBool:YES]];
}


#pragma mark - Derived properties

-(TASide) zoc
{
    TASide z = TASideNone;
    if( groundUnit != nil )
        z = groundUnit.team;
    for( TAHex *hex in _neighbors )
        if( [hex isKindOfClass:[TAHex class]] )
            z |= hex.groundUnit.team;
    return z;
}


-(NSString*) name
{
    return [NSString stringWithFormat:@"%@%i", colString, row];
}


-(NSString*) description
{
    NSMutableString *string = [NSMutableString stringWithString:self.name];
    [string appendFormat:@": elev:%d ter:%d roads:", elev, terrain];
    for( NSInteger direction = 0; direction < 6; direction++ )
        [string appendFormat:@"%d", [self hasRoadInDirection:direction]];
    [string appendString:@" rivers:"];
    for( NSInteger direction = 0; direction < 6; direction++ )
        [string appendFormat:@"%d", [self hasRiverCrossingInDirection:direction]];
    return string;
}


-(TAHex*) neighborInDirection:(TAHexDirection)direction
{
   if( [[_neighbors objectAtIndex:direction] isKindOfClass:[TAHex class]] )
      return [_neighbors objectAtIndex:direction];
   return nil;
}

-(BOOL) isNeighborTo:(TAHex*)otherHex
{
    return [_neighbors containsObject:otherHex];
}

-(TAHexDirection) directionToNeighbor:(TAHex*)otherHex
{
    for( TAHexDirection direction = 0; direction < 6; direction++ )
        if( otherHex != nil && [self neighborInDirection:direction] == otherHex )
            return direction;
    return TAHexDirectionNone;
}


-(BOOL) hasRiverCrossingInDirection:(TAHexDirection)direction
{
    if( direction == TAHexDirectionNone ) return FALSE;
    return [[_rivers objectAtIndex:direction] boolValue];
}

-(BOOL) hasRoadInDirection:(TAHexDirection)direction
{
    if( direction == TAHexDirectionNone ) return FALSE;
   return [[_roads objectAtIndex:direction] boolValue];
}

-(BOOL) hasBorderCrossingInDirection:(TAHexDirection)direction
{
    if( direction == TAHexDirectionNone ) return FALSE;
   return [[_borders objectAtIndex:direction] boolValue];
}


-(NSSet*) hexesInRange:(NSInteger)range
{
    if( range == 0 )
        return [NSSet setWithObjects:self, nil];
    
    NSMutableSet *set = [NSMutableSet set];
    for( TAHex *neighbor in _neighbors )
        if( [neighbor isKindOfClass:[TAHex class]] )
            for( TAHex *rangedNeighbor in [neighbor hexesInRange:range - 1] )
                [set addObject:rangedNeighbor];
    return set;
}


-(BOOL) canAddUnit:(TAUnit*)unit
{
    if( groundUnit == nil )
        return TRUE;
    if( [unit isAirUnit] )
        return TRUE;
    return FALSE;
}

@end
