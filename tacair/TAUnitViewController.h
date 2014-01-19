//
//  TAUnitViewController.h
//  tacair
//
//  Created by John Bender on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUnit.h"
#import "TAUnitView.h"

@protocol TAUnitViewTouchTarget <NSObject>
@required

-(BOOL) shouldUnitViewStartMoving:(TAUnitView*)unitView;

-(void) unitViewStartedMoving:(TAUnitView*)unitView;
-(void) unitViewMoving:(TAUnitView*)unitView;
-(void) unitViewDoneMoving:(TAUnitView*)unitView;

@end


@interface TAUnitViewController : UIViewController
{
    __weak IBOutlet UILabel *aLabel;
    __weak IBOutlet UILabel *bLabel;
    __weak IBOutlet UILabel *movementLabel;
    __weak IBOutlet UILabel *disruptionLabel;
    
    CGPoint touchOffset;
    BOOL isViewMoving;
}

@property (nonatomic, readonly) TAUnit *unit;
@property (nonatomic, readonly) BOOL isDuplicate;

+(NSString*) stringForMovementType:(TAUnitMovementType)movementType;

-(id) initWithUnit:(TAUnit*)myUnit;
-(id) initAsDuplicateForUnit:(TAUnit*)myUnit;

-(void) updateUnitViews;

-(void) pickUpView;
-(void) dropView;

@end
