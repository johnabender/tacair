//
//  TAPlaneViewController.m
//  tacair
//
//  Created by John Bender on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPlaneViewController.h"

@implementation TAPlaneViewController

-(id) initWithPlane:(TAPlane*)plane
{
    self = [super initWithUnit:plane];
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
