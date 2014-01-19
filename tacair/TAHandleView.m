//
//  TAHandleView.m
//  tacair
//
//  Created by John Bender on 12/24/13.
//
//

#import "TAHandleView.h"

@implementation TAHandleView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self ) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void) setCornerRadius:(CGFloat)cornerRadius
{
    bgMask = [UIBezierPath new];

    CGPoint pt = CGPointZero;
    [bgMask moveToPoint:pt];

    pt.x = self.frame.size.width;
    [bgMask addLineToPoint:pt];

    pt.y = self.frame.size.height - cornerRadius;
    [bgMask addLineToPoint:pt];

    pt.x -= cornerRadius;
    [bgMask addArcWithCenter:pt radius:cornerRadius startAngle:0. endAngle:M_PI/2. clockwise:YES];

    pt.x = cornerRadius;
    [bgMask addArcWithCenter:pt radius:cornerRadius startAngle:M_PI/2. endAngle:M_PI clockwise:YES];

    pt.x -= cornerRadius;
    pt.y = 0.;
    [bgMask addLineToPoint:pt];
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithRed:1. green:1. blue:1. alpha:0.5] set];
    [bgMask fill];
}

@end
