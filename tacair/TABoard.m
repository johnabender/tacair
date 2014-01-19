//
//  TABoard.m
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TABoard.h"
#import "TABoardViewController.h"

static const NSInteger MAXROW = 34;
static const NSInteger MAXCOLd = 52;

@implementation TABoard

int instr( char string[], char tofind[] )
{
    int i, use_i, use_j;
    int _str = (int)strlen( string );
    int _tof = (int)strlen( tofind );
    
    for( i = 0; i < _str - _tof + 1; i++ ) {
        
        if( string[i] == tofind[0] ) {
            use_i = i;
            use_j = 0;
        }
        while( string[i] == tofind[0] &&
              use_i < _str &&
              string[use_i] == tofind[use_j] ) {
            if( use_j == _tof - 1) return i;
            else {
                use_i++;
                use_j++;
            }
        }
    }
    return -1;
}


#pragma mark - Initialization

-(void) initHex:(TAHex*)hex withNeighbor:(TAHex*)neighbor inDirection:(TAHexDirection)direction
{
    if( neighbor.elev != 0 ) {
        [hex makeNeighbor:neighbor inDirection:direction];
        if( [hex.riverString rangeOfString:[neighbor name]].location != NSNotFound )
            [hex makeRiverInDirection:direction];
        if( [hex.roadString rangeOfString:[neighbor name]].location != NSNotFound )
            [hex makeRoadInDirection:direction];
        if( hex.country != neighbor.country )
            [hex makeBorderInDirection:direction];
    }
}


-(id) init
{
    self = [super init];
    if( self ) {
        NSMutableArray *board = [NSMutableArray arrayWithCapacity:MAXCOLd];
        for( NSInteger i = 0; i < MAXCOLd; i++ ) {
            NSMutableArray *col = [NSMutableArray arrayWithCapacity:MAXROW];
            for( NSInteger j = 0; j < MAXROW; j++ )
                [col addObject:[NSNumber numberWithInt:0]];
            [board addObject:col];
        }
        
        /* 'a'=97 'A'=65 '1'=49 */
        char bufferPing[64], bufferPong[64];
        int ccol, crow; /* digits for row, col */
        int ong, n;
        strcpy( bufferPing, "" );

        /* read raw data from file */
        NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"board" ofType:@"dat"];
        if( !fullPath )
            NSLog( @"couldn't find board data" );
        NSError *error = nil;
        NSString *boardData = [NSString stringWithContentsOfFile:fullPath encoding:NSASCIIStringEncoding error:&error];
        if( error )
            NSLog( @"error reading board data: %@", error );

        for( NSString *line in [boardData componentsSeparatedByString:@"\n"] ) {
            [line getCString:bufferPing maxLength:64 encoding:NSASCIIStringEncoding];

            ccol = bufferPing[0] - 65;
            if( bufferPing[1] > 57 ) { // two-char row name
                ccol += 26;
                strcpy( bufferPong, &bufferPing[2] );
            }
            else strcpy( bufferPong, &bufferPing[1] );
            
            crow = atoi( bufferPong ) - 1;
            
            // get other info
            if( ccol < MAXCOLd && crow < MAXROW ) {
                TAHex *hex = [[TAHex alloc] init];

                // numbers
                hex.col = ccol;
                hex.row = crow + 1;
                // name
                char colS[3];
                if( ccol < 26 ) {
                    colS[0] = ccol + 65;
                    colS[1] = 0;
                }
                else colS[0] = colS[1] = ccol - 26 + 65;
                colS[2] = 0;
                hex.colString = [[NSString alloc] initWithCString:colS encoding:NSASCIIStringEncoding];
                strcpy( bufferPing, &bufferPong[instr( bufferPong, "." ) + 1] );
                
                // elevation
                hex.elev = atoi( bufferPing );
                strcpy( bufferPong, &bufferPing[instr( bufferPing, "." ) + 1] );
                
                // terrain
                char ter = bufferPong[0];
                if( ter == 'c' )
                    hex.terrain = TAHexTerrainClear;
                else if( ter == 'w' )
                    hex.terrain = TAHexTerrainWoods;
                else if( ter == 'u' )
                    hex.terrain = TAHexTerrainUrban;
                else if( ter == 'k' )
                    hex.terrain = TAHexTerrainRocky;
                else if( ter == 'l' )
                    hex.terrain = TAHexTerrainLake;
                
                // roads, rivers
                char roadstr[48];
                if( instr( bufferPong, ".R[" ) > 0 || hex.terrain == TAHexTerrainUrban ) {
                    strcpy( roadstr, &bufferPong[instr( bufferPong, "[" )] );
                    roadstr[instr( roadstr, "]" ) + 1] = 0;
                    strcpy( bufferPing, &bufferPong[instr( bufferPong, "]" ) + 1] );
                    strcpy( bufferPong, bufferPing );
                }
                else strcpy( roadstr, "[]" );
                hex.roadString = [[NSString alloc] initWithCString:roadstr encoding:NSASCIIStringEncoding];
                
                char rivstr[48];
                strcpy( bufferPing, &bufferPong[instr( bufferPong, "[" )] );
                strcpy( rivstr, bufferPing );
                rivstr[instr( rivstr, "]") + 1] = 0;
                hex.riverString = [[NSString alloc] initWithCString:rivstr encoding:NSASCIIStringEncoding];
                
                // country
                hex.country = bufferPing[instr( bufferPing, "." ) + 1] - '0';
                
                [[board objectAtIndex:ccol] replaceObjectAtIndex:crow withObject:hex];
            }
        }

        
        /* check to see if each hex was read correctly */
        for( crow = 0; crow < MAXROW; crow++ ) {
            for( ccol = 0; ccol < MAXCOLd; ccol++ ) {
                TAHex *hex = (TAHex*)[[board objectAtIndex:ccol] objectAtIndex:crow];
                BOOL goodHex = YES;
                
                if( ![hex isKindOfClass:[TAHex class]] ) {
                    hex = [[TAHex alloc] init];
                    goodHex = NO;
                }
                else {
                    if( hex.terrain == 0 ||
                        hex.row <= 0 || hex.row > MAXROW )
                        goodHex = NO;
                }
                
                if( !goodHex ) {
                    hex.elev = 0;
                    hex.terrain = TAHexTerrainUnknown;
                    hex.col = ccol + 65;
                    hex.row = crow + 1;
                }
            }
        }
        
        
        /* process neighbors */
        for( crow = 0; crow < MAXROW; crow++ ) {
            for( ccol = 0; ccol < MAXCOLd; ccol++ ) {
                TAHex *hex = (TAHex*)[[board objectAtIndex:ccol] objectAtIndex:crow];
                TAHex *neighbor = nil;
                
                if( hex.elev != 0 ) {
                    ong = ccol % 2;
                    n = 0;
                    
                    if( crow > 0 ) {
                        neighbor = (TAHex*)[[board objectAtIndex:ccol] objectAtIndex:crow - 1];
                        [self initHex:hex withNeighbor:neighbor inDirection:n];
                        n++;
                    }
                    
                    if( ccol < MAXCOLd - 1 ) {
                        if( ong && crow > 0 ) {
                            neighbor = (TAHex*)[[board objectAtIndex:ccol + 1] objectAtIndex:crow - 1];
                            [self initHex:hex withNeighbor:neighbor inDirection:n];
                            n++;
                        }
                        neighbor = (TAHex*)[[board objectAtIndex:ccol + 1] objectAtIndex:crow];
                        [self initHex:hex withNeighbor:neighbor inDirection:n];
                        n++;
                        if( !ong && crow < MAXROW - 1 ) {
                            neighbor = (TAHex*)[[board objectAtIndex:ccol + 1] objectAtIndex:crow + 1];
                            [self initHex:hex withNeighbor:neighbor inDirection:n];
                            n++;
                        }
                    }
                    
                    if( crow < MAXROW - 1 ) {
                        neighbor = (TAHex*)[[board objectAtIndex:ccol] objectAtIndex:crow + 1];
                        [self initHex:hex withNeighbor:neighbor inDirection:n];
                        n++;
                    }
                    
                    if( ccol > 0 ) {
                        if( !ong && crow < MAXROW - 1 ) {
                            neighbor = (TAHex*)[[board objectAtIndex:ccol - 1] objectAtIndex:crow + 1];
                            [self initHex:hex withNeighbor:neighbor inDirection:n];
                            n++;
                        }
                        neighbor = (TAHex*)[[board objectAtIndex:ccol - 1] objectAtIndex:crow];
                        [self initHex:hex withNeighbor:neighbor inDirection:n];
                        n++;
                        if( ong && crow > 0 ) {
                            neighbor = (TAHex*)[[board objectAtIndex:ccol - 1] objectAtIndex:crow - 1];
                            [self initHex:hex withNeighbor:neighbor inDirection:n];
                            n++;
                        }
                    }
                }
            }
        }

        // make non-mutable versions of hex arrays
        NSMutableArray *nonmutableBoard = [NSMutableArray arrayWithCapacity:MAXCOLd];
        for( NSMutableArray *array in board )
            [nonmutableBoard addObject:[NSArray arrayWithArray:array]];
        hexes = [NSArray arrayWithArray:nonmutableBoard];
    }    
    return self;
}


#pragma mark - Readers

-(NSInteger) numberOfColumns
{
    return [hexes count];
}

-(NSInteger) numberOfRowsInColumn:(NSInteger)col
{
    return [[hexes objectAtIndex:col] count];
}


-(TAHex*) hexAtIndex:(CGPoint)index
{
    return [[hexes objectAtIndex:index.x] objectAtIndex:index.y];
}


-(TAHex*) hexWithName:(NSString*)name
{
    for( NSInteger col = 0; col < [self numberOfColumns]; col++ )
        for( NSInteger row = 0; row < [self numberOfRowsInColumn:col]; row++ )
            if( [[[self hexAtIndex:CGPointMake( col, row )] name] isEqualToString:name] )
                return [self hexAtIndex:CGPointMake( col, row )];
    return nil;
}


-(void) resetDistances
{
    for( NSInteger col = 0; col < [self numberOfColumns]; col++ )
        for( NSInteger row = 0; row < [self numberOfRowsInColumn:col]; row++ ) {
            TAHex *hex = [self hexAtIndex:CGPointMake( col, row )];
            hex.dist = -1.;
        }
}

@end
