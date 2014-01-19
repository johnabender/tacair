//
//  TAAirAllocationViewController.h
//  tacair
//
//  Created by John Bender on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TARoundedOverlayView.h"
#import "TAUnitViewController.h"

@interface TAAirAllocationViewController : UIViewController <TAUnitViewTouchTarget>
{
    __weak IBOutlet TARoundedOverlayView *refuelView;
    __weak IBOutlet TARoundedOverlayView *readyView;
    __weak IBOutlet TARoundedOverlayView *ACView;
    __weak IBOutlet TARoundedOverlayView *CASView;
    __weak IBOutlet UIScrollView *refuelScrollView;
    __weak IBOutlet UIScrollView *readyScrollView;
    __weak IBOutlet UIScrollView *ACScrollView;
    __weak IBOutlet UIScrollView *CASScrollView;
    
    NSMutableDictionary *refuelingPlanes;
    NSMutableDictionary *readyPlanes;
    NSMutableDictionary *ACPlanes;
    NSMutableDictionary *CASPlanes;
}

@end
