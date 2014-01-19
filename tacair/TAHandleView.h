//
//  TAHandleView.h
//  tacair
//
//  Created by John Bender on 12/24/13.
//
//

#import <UIKit/UIKit.h>

@interface TAHandleView : UIView
{
    UIBezierPath *bgMask;
}

-(void) setCornerRadius:(CGFloat)cornerRadius;

@end
