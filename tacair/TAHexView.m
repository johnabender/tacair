//
//  TAHexView.m
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAHexView.h"

#define RENDER_IN_BACKGROUND

#define elevation1Color [UIColor colorWithRed:192./255. green:192./255. blue:192./255. alpha:1.]
#define elevation2Color [UIColor colorWithRed:153./255. green:153./255. blue:153./255. alpha:1.]
#define elevation3Color [UIColor colorWithRed:115./255. green:115./255. blue:115./255. alpha:1.]


@implementation TAHexView

@synthesize hex;
@synthesize highlightColor;
@synthesize specifiedHighlightColor;
@synthesize tempPtsValue;


-(id) initWithFrame:(CGRect)frame
{
    assert( FALSE );
    return nil;
}

- (id)initWithHex:(TAHex*)myHex
{
    CGRect frame = CGRectMake( 0., 0., kHexWidth + kHexLineWidth, kHexHeight + kHexLineWidth );
    self = [super initWithFrame:frame];
    if (self) {
        self.hex = myHex;
        hex.viewer = self;
        
#ifdef RENDER_IN_BACKGROUND
        drawQueue = [[NSOperationQueue alloc] init];
        drawQueue.name = @"drawQueue";
#endif
       
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;

        hexImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:hexImageView];

        // border, rivers
        border = [[UIBezierPath alloc] init];
        border.lineWidth = kHexLineWidth;
        countryBorderPath = [[UIBezierPath alloc] init];
        countryBorderPath.lineWidth = kHexLineWidth*2.5;
        riverPath = [[UIBezierPath alloc] init];
        riverPath.lineWidth = kHexLineWidth*5.;

        CGFloat xOffset = -0.5*kHexLineWidth;
        CGFloat yOffset = (kHexWidth - kHexHeight)/2. - 0.5*kHexLineWidth;
        CGFloat rotOffset = M_PI/6.;
        for( NSInteger i = 0; i < 7; i++ ) {
            CGFloat x = kHexWidth/2. * sinf( i*2.*M_PI/6. + rotOffset );
            CGFloat y = kHexWidth/2. * cosf( i*2.*M_PI/6. + rotOffset );
        
            CGPoint pt = CGPointMake( kHexWidth/2. + x - xOffset, 
                                      kHexWidth/2. + y - yOffset );
            if( i == 0 )
                [border moveToPoint:pt];
            else
                [border addLineToPoint:pt];
            
            if( i < 6 ) {
                // this draws each river or border twice, once in each hex
                // better would be to decrease the radius and draw half the river in each hex
                CGFloat lastX = kHexWidth/2. * sinf( (i + 1)*2.*M_PI/6. + rotOffset );
                CGFloat lastY = kHexWidth/2. * cosf( (i + 1)*2.*M_PI/6. + rotOffset );
                CGPoint lastPt = CGPointMake( kHexWidth/2. + lastX - xOffset,
                                              kHexWidth/2. + lastY - yOffset );
                if( [hex hasRiverCrossingInDirection:5 - ((i + 3) % 6)] ) {
                    CGPoint midPoint = CGPointMake( (lastPt.x + pt.x)/2.,
                                                    (lastPt.y + pt.y)/2. );
                    midPoint.x += 10.*(CGFloat)rand()/(CGFloat)RAND_MAX - 5.;
                    midPoint.y += 10.*(CGFloat)rand()/(CGFloat)RAND_MAX - 5.;
                    [riverPath moveToPoint:lastPt];
                    [riverPath addQuadCurveToPoint:pt controlPoint:midPoint];
                }
                if( [hex hasBorderCrossingInDirection:5 - ((i + 3) % 6)] ) {
                    [countryBorderPath moveToPoint:lastPt];
                    [countryBorderPath addLineToPoint:pt];
                }
            }
        }
        
        // terrain image
        if( hex.terrain == TAHexTerrainUnknown )
            terrainImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white.bmp"]];
        else {
            NSString *imgNameStr = nil;
            if( hex.terrain == TAHexTerrainClear )
                imgNameStr = @"clear";
            else if( hex.terrain == TAHexTerrainWoods )
                imgNameStr = @"woods";
            else if( hex.terrain == TAHexTerrainRocky )
                imgNameStr = @"rocky";
            else if( hex.terrain == TAHexTerrainUrban )
                imgNameStr = @"urban";
            NSString *nameStr = [NSString stringWithFormat:@"%@%i.bmp", imgNameStr, hex.elev];
            terrainImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:nameStr]];
            
            if( hex.terrain == TAHexTerrainLake )
                terrainImageView = nil;
        }
        terrainImageView.frame = self.bounds;

        terrainRotationAngle = 0.;
        if( hex.terrain == TAHexTerrainWoods || hex.terrain == TAHexTerrainRocky ) {
            terrainRotationAngle = 2.*M_PI*(float)rand()/(float)RAND_MAX;
        }
        else if( hex.terrain == TAHexTerrainUrban ) {
            terrainRotationAngle = (roundf( 4.*(CGFloat)rand()/(CGFloat)RAND_MAX + 0.5 ) - 1.)*M_PI/2.;
        }

        // number label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 0., 2., kHexWidth, 15. )];
        label.text = [myHex name];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12.];
        [self addSubview:label];
    }
    return self;
}


-(void) addRoads
{
    roadPath = [[UIBezierPath alloc] init];
    roadPath.lineWidth = kHexLineWidth*3.;
    
    for( NSInteger direction = 0; direction < 6; direction++ )
        if( [hex hasRoadInDirection:direction] ) {
            TAHexView *other = [hex neighborInDirection:direction].viewer;
            CGPoint selfCenter = CGPointMake( kHexWidth/2. + kHexLineWidth/2.,
                                              kHexHeight/2. + kHexLineWidth/2. );
            [roadPath moveToPoint:selfCenter];
            CGPoint otherCenter = CGPointMake( selfCenter.x + other.center.x - self.center.x,
                                               selfCenter.y + other.center.y - self.center.y );
            [roadPath addLineToPoint:otherCenter];
        }
}


-(void) setHighlightColor:(TAHexHighlightColor)newColor
{
    if( newColor != highlightColor ) {
        highlightColor = newColor;
        hexImage = nil;
        [self setNeedsDisplay];
    }
}


-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    return [border containsPoint:point];
}


-(UIColor*) baseColor
{
    UIColor *baseColor = [UIColor blackColor];    
    if( hex.terrain == TAHexTerrainLake )
        baseColor = [UIColor blueColor];
    else if( hex.elev == 1 )
        baseColor = elevation1Color;
    else if( hex.elev == 2 )
        baseColor = elevation2Color;
    else if( hex.elev == 3 )
        baseColor = elevation3Color;
    return baseColor;
}


-(UIColor*) highlitColor
{
    if( highlightColor & TAHexHighlightColorSpecific )
        return specifiedHighlightColor;
    
    // collect all highlight colors
    NSMutableArray *colors = [NSMutableArray array];
    if( highlightColor & TAHexHighlightColorAvailable )
        [colors addObject:[UIColor cyanColor]];
    if( highlightColor & TAHexHighlightColorInRange )
        [colors addObject:[UIColor yellowColor]];
    if( highlightColor & TAHexHighlightColorHighlight )
        [colors addObject:[UIColor magentaColor]];

    if( [colors count] == 0 )
        return nil;

    // average them together
    CGFloat r_sum=0, g_sum=0, b_sum=0;
    for( UIColor *color in colors ) {
        CGFloat r,g,b,a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        r_sum += r;
        g_sum += g;
        b_sum += b;
    }
    r_sum /= [colors count];
    g_sum /= [colors count];
    b_sum /= [colors count];

    return [UIColor colorWithRed:r_sum green:g_sum blue:b_sum alpha:0.25];
}


- (void)drawRect:(CGRect)rect
{
    if( hexImage == nil ) {
        __weak TAHexView *weakSelf = self;
        __weak UIBezierPath *weakBorder = border;
        __weak UIBezierPath *weakRiver = riverPath;
        __weak UIBezierPath *weakCountry = countryBorderPath;
        __weak UIBezierPath *weakRoad = roadPath;
        CGImageRef terrainImage = terrainImageView.image.CGImage;
        
#ifdef RENDER_IN_BACKGROUND
        NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
#endif
            UIGraphicsBeginImageContextWithOptions( self.bounds.size, NO, 0 );
            
            [[weakSelf baseColor] set];
            [weakBorder fill];
            
            // draw terrain image, rotated as appropriate
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextAddPath( context, weakBorder.CGPath );
            CGContextSaveGState( context );
            CGContextClip( context );
            
            // http://www.catamount.com/forums/viewtopic.php?f=21&t=967
            UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width, self.bounds.size.height)];
            CGAffineTransform t = CGAffineTransformMakeRotation(terrainRotationAngle);
            rotatedViewBox.transform = t;
            CGSize rotatedSize = rotatedViewBox.frame.size;
            
            CGContextTranslateCTM( context, rotatedSize.width/2, rotatedSize.height/2 );
            CGContextRotateCTM( context, terrainRotationAngle );
            CGContextDrawImage( context, 
                                CGRectMake( -rotatedSize.width/2., 
                                            -rotatedSize.height/2., 
                                            rotatedSize.width,
                                            rotatedSize.height ),
                                terrainImage );
            
            CGContextRestoreGState( context );
            
            // other drawing -- roads, borders, etc.
            [[UIColor blackColor] set];
            [weakBorder stroke];
            
            [[UIColor blueColor] set];
            [weakRiver stroke];
            
            [[UIColor blackColor] set];
            [weakCountry stroke];
            
            [[UIColor brownColor] set];
            [weakRoad stroke];
            
            UIColor *hgc = [weakSelf highlitColor];
            if( hgc != nil ) {
                [hgc set];
                [weakBorder fill];
            }
            
            UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
#ifdef RENDER_IN_BACKGROUND
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
#endif
                hexImage = i;
                if( hexImage != nil )
                    hexImageView.image = i;
#ifdef RENDER_IN_BACKGROUND
            }];
        }];
        
        [drawQueue addOperation:block];
#endif
    }
}

@end
