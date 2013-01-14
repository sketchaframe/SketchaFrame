//
//  ModelExistsViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "ModelExistsViewController.h"
#import "WriteCoreData.h"
#import "SaveAsViewController.h"

@interface ModelExistsViewController ()

@end

@implementation ModelExistsViewController
@synthesize modelDatabase;
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}



- (IBAction)overwriteButton:(id)sender {
    [WriteCoreData saveModelToCore:self.modelDatabase];
    [delegate saveModel:nil]; 
}

@end
