//
//  AboutViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-09-17.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
	return YES;
}

- (IBAction)struSoft:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.strusoft.com"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}

- (IBAction)lundLogo:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.byggmek.lth.se"];
    
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}
@end
