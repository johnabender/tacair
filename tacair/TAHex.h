//
//  TAHex.h
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TAHexDirectionNone = -1,
    // 0 = north, going clockwise
    TAHexDirectionNorth = 0,
    TAHexDirectionNortheast,
    TAHexDirectionSoutheast,
    TAHexDirectionSouth,
    TAHexDirectionSouthwest,
    TAHexDirectionNorthwest
} TAHexDirection;

typedef enum {
    TAHexTerrainUnknown,
    TAHexTerrainClear,
    TAHexTerrainWoods,
    TAHexTerrainRocky,
    TAHexTerrainUrban,
    TAHexTerrainLake
} TAHexTerrain;

typedef enum {
    TACountryEastGermany,
    TACountryWestGermany,
    TACountryEither
} TACountry;


@class TAHexView;
@class TAUnit;
@interface TAHex : NSObject
{
    NSMutableArray *_neighbors, *_rivers, *_roads, *_borders;
}

@property (nonatomic, assign) NSInteger elev;
@property (nonatomic, assign) TAHexTerrain terrain;
@property (nonatomic, assign) NSInteger row; // row is 1-based
@property (nonatomic, assign) NSInteger col;
@property (nonatomic, strong) NSString *colString;
@property (nonatomic, assign) TACountry country;
@property (nonatomic, readonly) TASide zoc;

@property (nonatomic, weak) TAHexView *viewer;
@property (nonatomic, strong) TAUnit *groundUnit;
@property (nonatomic, strong) NSArray *airUnits;

// this is used by units during route calculation
@property (nonatomic, assign) CGFloat dist;

-(TAHex*) neighborInDirection:(TAHexDirection)direction;
-(BOOL) isNeighborTo:(TAHex*)otherHex;
-(TAHexDirection) directionToNeighbor:(TAHex*)otherHex;
-(BOOL) hasRiverCrossingInDirection:(TAHexDirection)direction;
-(BOOL) hasRoadInDirection:(TAHexDirection)direction;
-(BOOL) hasBorderCrossingInDirection:(TAHexDirection)direction;
-(BOOL) canAddUnit:(TAUnit*)unit;

-(NSSet*) hexesInRange:(NSInteger)range;

// only during initialization
@property (nonatomic, strong) NSString *riverString;
@property (nonatomic, strong) NSString *roadString;
-(void) makeNeighbor:(TAHex*)newNeighbor inDirection:(TAHexDirection)direction;
-(void) makeRiverInDirection:(TAHexDirection)direction;
-(void) makeRoadInDirection:(TAHexDirection)direction;
-(void) makeBorderInDirection:(TAHexDirection)direction;

-(NSString*)name;

@end
