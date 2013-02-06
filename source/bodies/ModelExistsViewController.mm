//
//  ModelExistsViewController.m
//  SimpleFrame
//
//  Created by Daniel Åkesson on 2012-07-15.
//  Copyright (c) 2012 Lund University. All rights reserved.
//

#import "ModelExistsViewController.h"
#import "SaveAsViewController.h"
#import "GenerateXMLData.h"
#import "DrawImages.h"

@interface ModelExistsViewController ()

@end

@implementation ModelExistsViewController
@synthesize filePath;
@synthesize imagePath;
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
    NSData *modelXMLData = [GenerateXMLData getDataModel];
    [modelXMLData writeToFile:filePath atomically:YES];
    
    //Update icon
    NSData *iconImageData = UIImagePNGRepresentation([DrawImages drawIcon]);
    [iconImageData writeToFile:imagePath atomically:YES];
    
    [delegate saveModel:nil];
}

@end
