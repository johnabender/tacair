//
//  TAArrowView.m
//  tacair
//
//  Created by John Bender on 12/23/13.
//
//

#import "TAArrowView.h"

@implementation TAArrowView

@synthesize arrowPath;

- (void)drawRect:(CGRect)rect
{
    if( arrowPath ) {
        [[UIColor whiteColor] set];
        [arrowPath stroke];
    }
}

@end
