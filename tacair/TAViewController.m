//
//  TAViewController.m
//  tacair
//
//  Created by John Bender on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAViewController.h"
#import "TAGameViewController.h"
#import "TABoardViewController.h"


@implementation TAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TAGameViewController *gameVC = [[TAGameViewController alloc] initWithNibName:@"TAGameViewController" bundle:nil];
    [self.view addSubview:gameVC.view];
    
    TABoardViewController *boardVC = [[TABoardViewController alloc] initWithBoard:gameVC.game.board
                                                                       controller:self];
    [scrollView addSubview:boardVC.view];
    scrollView.contentSize = boardVC.view.frame.size;
    
    gameVC.boardVC = boardVC;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView*)sv
{
    return [scrollView.subviews objectAtIndex:0];
}

-(void) scrollViewDidEndZooming:(UIScrollView*)sv withView:(UIView*)v atScale:(CGFloat)scale
{
}


-(void) scrollHexViewOntoScreen:(TAHexView*)hexView
{
    CGRect testFrame = hexView.frame;
    testFrame.origin.x -= kHexWidth;
    testFrame.origin.y -= kHexHeight;
    testFrame.size.width = 3*kHexWidth;
    testFrame.size.height = 3*kHexHeight;
    [scrollView scrollRectToVisible:testFrame animated:NO];
}


@end
