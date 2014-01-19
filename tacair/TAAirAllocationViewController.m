//
//  TAAirAllocationViewController.m
//  tacair
//
//  Created by John Bender on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAAirAllocationViewController.h"
#import "TAGameViewController.h"
#import "TAPlaneViewController.h"


@implementation TAAirAllocationViewController

-(id) initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)bundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:bundleOrNil];
    if( self ) {
        refuelingPlanes = [NSMutableDictionary dictionary];
        readyPlanes = [NSMutableDictionary dictionary];
        ACPlanes = [NSMutableDictionary dictionary];
        CASPlanes = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [refuelingPlanes setObject:[NSMutableArray array] forKey:@"planeArray"];
    [refuelingPlanes setObject:refuelView forKey:@"containerView"];
    [refuelingPlanes setObject:refuelScrollView forKey:@"scrollView"];
    [readyPlanes setObject:[NSMutableArray array] forKey:@"planeArray"];
    [readyPlanes setObject:readyView forKey:@"containerView"];
    [readyPlanes setObject:readyScrollView forKey:@"scrollView"];
    [ACPlanes setObject:[NSMutableArray array] forKey:@"planeArray"];
    [ACPlanes setObject:ACView forKey:@"containerView"];
    [ACPlanes setObject:ACScrollView forKey:@"scrollView"];
    [CASPlanes setObject:[NSMutableArray array] forKey:@"planeArray"];
    [CASPlanes setObject:CASView forKey:@"containerView"];
    [CASPlanes setObject:CASScrollView forKey:@"scrollView"];

    [self placeReadyPlanes];
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSArray *dicts = [NSArray arrayWithObjects:refuelingPlanes, readyPlanes, ACPlanes, CASPlanes, nil];
    for( NSDictionary *dict in dicts ) {
        NSMutableArray *planeArray = [dict objectForKey:@"planeArray"];
        for( TAPlane *plane in planeArray )
            [plane.viewController.view removeFromSuperview];
        [planeArray removeAllObjects];
    }
}


-(void) layoutPlanes:(NSDictionary*)planes
{
    __block CGRect frame;
    NSArray *planeArray = [planes objectForKey:@"planeArray"];
    UIScrollView *scrollView = [planes objectForKey:@"scrollView"];
    
    for( NSInteger p = 0; p < [planeArray count]; p++ ) {
        TAPlane *plane = [planeArray objectAtIndex:p];
        TAPlaneViewController *planeVC = (TAPlaneViewController*)(plane.viewController);
        if( planeVC == nil )
            planeVC = [[TAPlaneViewController alloc] initWithPlane:plane];

        planeVC.view.center = [scrollView convertPoint:planeVC.view.center fromView:planeVC.view.superview];

        [scrollView addSubview:planeVC.view];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        for( NSInteger p = 0; p < [planeArray count]; p++ ) {
            NSInteger row = p/2;
            NSInteger col = p % 2;
            TAPlane *plane = [planeArray objectAtIndex:p];
            TAPlaneViewController *planeVC = (TAPlaneViewController*)(plane.viewController);

            frame = planeVC.view.frame;
            frame.origin.x = col*frame.size.height + (col + 1)*layoutMargin;
            frame.origin.y = row*frame.size.height + (row + 2)*layoutMargin;
            planeVC.view.frame = frame;
        }
    }];
    
    scrollView.contentSize = CGSizeMake( 1., CGRectGetMaxY( frame ) + layoutMargin );
}

-(void) placeReadyPlanes
{
    TAGame *game = [TAGameViewController gameVC].game;
    NSArray *planes = [game offboardPlanesForSide:game.phasingSide];
    [[readyPlanes objectForKey:@"planeArray"] removeAllObjects];
    for( TAPlane *plane in planes )
        if( plane.readiness == TAPlaneStateReady )
            [[readyPlanes objectForKey:@"planeArray"] addObject:plane];
    [self layoutPlanes:readyPlanes];
}


#pragma mark - Unit touch target

-(BOOL) shouldUnitViewStartMoving:(TAUnitView*)unitView
{
    return TRUE;
}

-(void) unitViewStartedMoving:(TAUnitView*)unitView
{
    CGRect frame = unitView.frame;
    CGPoint offset = [self.view convertPoint:frame.origin fromView:unitView.superview];
    frame.origin = offset;
    unitView.frame = frame;
    
    [self.view addSubview:unitView];
}

-(void) unitViewMoving:(TAUnitView*)unitView
{
    // legal views to drop this unit in
    NSArray *planes;
    if( unitView.unit.movementType == TAUnitMovementTypeFastAir )
        planes = [NSArray arrayWithObjects:ACPlanes, CASPlanes, nil];
    else
        planes = [NSArray arrayWithObjects:CASPlanes, nil];
    
    for( NSDictionary *planeDict in planes ) {
        TARoundedOverlayView *v = [planeDict objectForKey:@"containerView"];
        CGPoint testPoint = [v convertPoint:unitView.center fromView:self.view];
        v.highlighted = [v pointInside:testPoint withEvent:nil];
    }
}

-(void) unitViewDoneMoving:(TAUnitView*)unitView
{
    // legal views to drop this unit in
    NSArray *planes;
    if( unitView.unit.movementType == TAUnitMovementTypeFastAir )
        planes = [NSArray arrayWithObjects:ACPlanes, CASPlanes, nil];
    else
        planes = [NSArray arrayWithObjects:CASPlanes, nil];
    
    for( NSDictionary *planeDict in planes ) {
        TARoundedOverlayView *v = [planeDict objectForKey:@"containerView"];
        CGPoint testPoint = [v convertPoint:unitView.center fromView:self.view];
        if( [v pointInside:testPoint withEvent:nil] ) {
            TAPlane *plane = (TAPlane*)unitView.unit;
            [[readyPlanes objectForKey:@"planeArray"] removeObject:plane];
            [[planeDict objectForKey:@"planeArray"] addObject:plane];
            plane.readiness = TAPlaneStateAllocated;
            plane.orders = 0;
            [self layoutPlanes:planeDict];
            v.highlighted = FALSE;
        }
    }

    if( [[readyPlanes objectForKey:@"planeArray"] count] == 0 )
        [[TAGameViewController gameVC] airAllocationFinished];
    else
        [self layoutPlanes:readyPlanes];
}

@end
