//
//  TATank.h
//  tacair
//
//  Created by John Bender on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAUnit.h"

@interface TATank : TAUnit

-(BOOL) hasMovementPointsToFlip;
-(void) flip:(BOOL)deductPoints;

-(BOOL) hasZoc;

@end
