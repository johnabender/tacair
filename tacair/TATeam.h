//
//  TATeam.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TATank.h"
#import "TAPlane.h"

@interface TATeam : NSObject
{
    NSMutableArray *tanks;
    NSMutableArray *planes;
}

-(id) initWithSide:(TASide)side;

-(NSArray*) onboardTanks;

-(NSArray*) unplacedTanks;
-(NSArray*) offboardPlanes;

@end
