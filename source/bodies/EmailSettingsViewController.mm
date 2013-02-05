//
//  EmailSettingsViewController.m
//  Sketch a Frame
//
//  Created by Daniel Åkesson on 2/1/13.
//  Copyright (c) 2013 Lund University. All rights reserved.
//

#import "EmailSettingsViewController.h"
#import "GenerateXMLData.h"
#import "DrawImages.h"

@interface EmailSettingsViewController ()

@end


@implementation EmailSettingsViewController
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendEmail:(id)sender {
    [delegate sendEmail:self];
}
@end
