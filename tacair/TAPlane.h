//
//  TAPlane.h
//  tacair
//
//  Created by John Bender on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUnit.h"

typedef enum {
    TAPlaneStateLanded,
    TAPlaneStateRefueling,
    TAPlaneStateReady,
    TAPlaneStateAllocated,
    TAPlaneStateInFlight
} TAPlaneState;

typedef enum {
    TAPlaneOrdersNone,
    TAPlaneOrdersAirControl,
    TAPlaneOrdersCloseAirSupport
} TAPlaneOrders;


@interface TAPlane : TAUnit

@property (nonatomic, assign) TAPlaneState readiness;
@property (nonatomic, assign) TAPlaneOrders orders;

-(id) initWithSide:(TASide)side
           AFactor:(NSInteger)a
           BFactor:(NSInteger)b
      movementType:(TAUnitMovementType)mvType;

@end
