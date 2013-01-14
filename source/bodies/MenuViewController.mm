//
//  MenuViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-27.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize tensionMode;
@synthesize showDisplacements;
@synthesize showMoment;
@synthesize showNormal;
@synthesize showGrid;
@synthesize orthoMode;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


}

- (void)viewDidUnload
{
    [self setShowDisplacements:nil];
    [self setShowMoment:nil];
    [self setShowNormal:nil];
    [self setShowGrid:nil];
    [self setOrthoMode:nil];
    [self setTensionMode:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (IBAction)switchChanged:(id)sender {
    [delegate menuUpdate:self];
}

- (IBAction)tensionSwitched:(id)sender {
    [delegate menuUpdate:self];
    if (tensionMode.on)
    {
        showNormal.enabled = NO;
        showMoment.enabled = NO;
    } else {
        showNormal.enabled = YES;
        showMoment.enabled = YES;
    }
}


- (IBAction)showGrid:(id)sender {
}

- (IBAction)orthoMode:(id)sender {
}

- (void)dealloc {
    [showDisplacements release];
    [showMoment release];
    [showNormal release];
    [showGrid release];
    [orthoMode release];
    [tensionMode release];


    [super dealloc];
}
@end
