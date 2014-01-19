//
//  TABoard.h
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAHex.h"
#import "TAUnit.h"
@class TABoardViewController;


@interface TABoard : NSObject
{
    NSArray *hexes;
}

-(NSInteger) numberOfColumns;
-(NSInteger) numberOfRowsInColumn:(NSInteger)col;
-(TAHex*) hexAtIndex:(CGPoint)index;
-(TAHex*) hexWithName:(NSString*)name;

-(void) resetDistances;

@end
