//
//  TAViewController.h
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TAHexView;

@interface TAViewController : UIViewController <UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *scrollView;
}

-(void) scrollHexViewOntoScreen:(TAHexView*)hexView;

@end
