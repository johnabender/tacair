//
//  TATankViewController.m
//  tacair
//
//  Created by John Bender on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TATankViewController.h"
#import "TAGameViewController.h"

@implementation TATankViewController

-(id) initWithTank:(TATank*)tank
{
    self = [super initWithUnit:tank];
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
